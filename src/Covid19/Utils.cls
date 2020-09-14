Class Covid19.Utils
{

Parameter TSConfirmed = "csse_covid_19_time_series/time_series_covid19_confirmed_global.csv";

Parameter TSDeaths = "csse_covid_19_time_series/time_series_covid19_deaths_global.csv";

Parameter TSrecovered = "csse_covid_19_time_series/time_series_covid19_recovered_global.csv";

Parameter TSYesterdayFile = "csse_covid_19_daily_reports/";

ClassMethod ImportCountries()
{
  zw ##class(community.csvgen).GenerateFromURL("https://raw.githubusercontent.com/datasciencedojo/datasets/master/WorldDBTables/CountryTable.csv",",","Covid19.Countries")
}

ClassMethod CleanCountriesData()
{
  &sql(Update Covid19.Countries
Set name='Russia'
where name='Russian Federation')
  if SQLCODE < 0 throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE,"Change Russia")


  &sql(Update Covid19.Countries
Set name='United States of America'
where name='united States')
  if SQLCODE < 0 throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE,"Change the USA")
}

ClassMethod UpdatePopulation()
{
  &sql(
  Update AnalyzeThis_Generated.covid03162020 as t1
  SET t1.Population=t2.Population
  FROM AnalyzeThis_Generated.covid03162020 as t1 
  Inner Join Covid19.Countries as t2 on t1.CountryRegion=t2.name)
  if SQLCODE < 0 throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE,"Add Population")
}

ClassMethod DailyUpdate() As %Status
{
  set sc=..ImportData()
  if $$$ISERR(sc) return sc
  set sc=##class(USA.Covid).ImportData()
  if $$$ISERR(sc) return sc
  set sc=##class(%DeepSee.Utils).%BuildCube("CovidCube")
  return sc
}

ClassMethod ImportData() As %Status
{
  set rc=0 
  set pYesterdayFile=..#TSYesterdayFile_$tr($zd($h-1),"/","-")_".csv"
  
  set streamYesterday=..GetStreamFromRepo(pYesterdayFile)
  do ##class(AnalyzeThis.Generated.covid03162020).ImportFromStream(,streamYesterday,,,1,.rc)
  //do ##class(AnalyzeThis.Generated.covid03162020).Import(,pfile,",", ,1,.rc) 

  write "imported records: "_rc 
  do ..ImportCountries()
  do ..CleanCountriesData()
  do ..UpdatePopulation()
  do ##class(%DeepSee.Utils).%BuildCube("covid03162020") 
  do ..ImportDays()
  do ##class(%DeepSee.Utils).%BuildCube("CovidDays")
  return $$$OK
}

ClassMethod BISetup() As %Status
{
  do ##class(USA.Utils).Setup()
  do ##class(USA.Covid).ImportData()
  do ##class(USA.Covid).GrantSQLAccess()
  do ##class(%DeepSee.Utils).%BuildCube("CovidCube")
  return $$$OK
}

ClassMethod ImportDays() As %Status
{
    s streamConfirmed=..GetStreamFromRepo(..#TSConfirmed)
    s streamDeaths=..GetStreamFromRepo(..#TSDeaths)
    d ..Import(streamConfirmed,streamDeaths)
    return $$$OK
}

ClassMethod GetStreamFromRepo(fn As %String) As %CharacterStream
{
    //set SSLConfig="GitHub"   
    //do:'##class(Security.SSLConfigs).Exists(SSLConfig) ##class(Security.SSLConfigs).Create(SSLConfig)
    Set httprequest = ##class(%Net.HttpRequest).%New()
    Set httprequest.Server = "raw.githubusercontent.com"
    Set httprequest.Https = 1
    Set httprequest.SSLConfiguration = "default"
    set urlts="/CSSEGISandData/COVID-19/master/csse_covid_19_data/"
    $$$TOE(sc,httprequest.Get(urlts_fn))
    Set stream = httprequest.HttpResponse.Data
    
    //Reset the HTTP connection, to allow for another connection and not throw a 404 error
    Do httprequest.Reset()

    //TBD check for sc
    return stream
}

ClassMethod GetStreamFromFile(fn As %String) As %Stream
{
    set stream = ##Class(%Stream.FileCharacter).%New()
    set stream.LineTerminator = $Char(13,10)
    $$$TOE(sc,stream.LinkToFile(fn))
    //TBD check for sc
    return stream
}

ClassMethod Import(streamConfirmed As %CharacterStream, streamDeaths As %CharacterStream) As %Status
{
  // loading days
  // format=Province/State,Country/Region,Lat,Long,1/22/20,...
  set status=$$$OK
  do ##class(Day).%KillExtent()
  set line=streamConfirmed.ReadLine()
  set lineDeaths=streamDeaths.ReadLine()
  set day1h=$zdh("1/22/2020")  // day1 in horolog

  while 'streamConfirmed.AtEnd
  {
    set line=streamConfirmed.ReadLine()
   set lineDeaths=streamDeaths.ReadLine()

   set place=##class(Place).%New()
   set place.ProvinceState=$p(line,",",1)
   set place.CountryRegion=$p(line,",",2)
   set place.Latitude=$p(line,",",3)
   set place.Longitude=$p(line,",",4)
   set status=place.%Save()

   if $$$ISERR(status)
  {
   do $System.Status.DisplayError(status)
  } 
   set (ConfirmedPrev,DeathsPrev)=0
   for i=5:1:$L(line,",") {
       set day=##class(Day).%New()
       set day.Day=day1h+i-5
       if day.Day=+$H Quit 
       set day.Place=place 
       set day.Confirmed=$Piece(line,",",i)
       set day.ConfirmedNew=day.Confirmed-ConfirmedPrev
       set day.Deaths=$Piece(lineDeaths,",",i)
       set day.DeathsNew=day.Deaths-DeathsPrev
       
       set status=day.%Save()
       if $$$ISERR(status) do $System.Status.DisplayError(status)
       set ConfirmedPrev=day.Confirmed
       set DeathsPrev=day.Deaths
       
   }
  }
  return status
}

ClassMethod CreateTask() As %Status
{
	Set task=##class(%SYS.Task).%New()
	Set task.Name = "Update data"
	Set task.NameSpace=$Namespace
	Set task.TimePeriod=0 // Daily
	Set task.TimePeriodEvery=1 // Every 1 day
	Set task.DailyFrequency=1 // Run Several times in a day
	Set task.DailyFrequencyTime=0 // Run every x minutes
	Set task.DailyIncrement=60 // # of minutes between runs
	Set task.DailyStartTime = 0 // Start at 00:00:00
	Set task.DailyEndTime = 86399 // End at 23:59:59
	Set task.StartDate = $p($H,",",1) // Start today
	
	Set taskdef = ##class(Covid19.UpdateTask).%New()
	Do task.AssignSettings(taskdef)
	Set task.TaskClass=$classname(taskdef)
	
	Set st = task.%Save()
	Return:$$$ISERR(st) st
	Return ##class(%SYS.Task).RunNow(task.%Id())
}

ClassMethod OpenToPublic()
{
  n $namespace
  s $namespace="%SYS"
  write "Modify MDX2JSON application security...",! 
  set webName = "/mdx2json" 
  set webProperties("AutheEnabled") = 64 
  set webProperties("MatchRoles")=":%DB_IRISAPP" 
  set sc = ##class(Security.Applications).Modify(webName, .webProperties) 
  if 'sc zw sc
  $$$ThrowOnError(sc)
}

}
