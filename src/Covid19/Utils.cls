Class Covid19.Utils
{

Parameter TSConfirmed = "csse_covid_19_time_series/time_series_covid19_confirmed_global.csv";

Parameter TSDeaths = "csse_covid_19_time_series/time_series_covid19_deaths_global.csv";

Parameter TSrecovered = "csse_covid_19_time_series/time_series_covid19_recovered_global.csv";

Parameter TSYesterdayFile = "csse_covid_19_daily_reports/";

ClassMethod ImportData() As %Status
{
  set pfile = "/opt/irisapp/files/covid-"_$tr($zd($h-1),"/","-")_".csv", rc=0 
  set pYesterdayFile=..#TSYesterdayFile_$tr($zd($h-1),"/","-")_".csv"
  
  set streamYesterday=..GetStreamFromRepo(pYesterdayFile)
  do ##class(AnalyzeThis.Generated.covid03162020).ImportFromStream(,streamYesterday,,,1,.rc)
  //do ##class(AnalyzeThis.Generated.covid03162020).Import(,pfile,",", ,1,.rc) 

  write "imported records: "_rc 
  do ##class(%DeepSee.Utils).%BuildCube("covid03162020") 
  do ..ImportDays()
  do ##class(%DeepSee.Utils).%BuildCube("CovidDays")
}

ClassMethod BISetup() As %Status
{
  do ##class(USA.Utils).Setup()
  do ##class(USA.Covid).ImportData()
  do ##class(USA.Covid).GrantSQLAccess()
  do ##class(%DeepSee.Utils).%BuildCube("CovidCube")
}

ClassMethod ImportDays() As %Status
{
    s streamConfirmed=..GetStreamFromRepo(..#TSConfirmed)
    s streamDeaths=..GetStreamFromRepo(..#TSDeaths)
    d ..Import(streamConfirmed,streamDeaths)
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
    set urlcsv="/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/"
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
       set ConfirmedPrev=day.Confirmed
       set DeathsPrev=day.Deaths
       if $$$ISERR(status) do $System.Status.DisplayError(status)
   }
  }
}

}
