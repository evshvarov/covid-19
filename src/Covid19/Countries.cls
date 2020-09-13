Class Covid19.Countries Extends %Library.Persistent [ Not Abstract, DdlAllowed, Not LegacyInstanceContext, ProcedureBlock ]
{

Property code As %Library.String(MAXLEN = 250) [ SqlColumnNumber = 2 ];

Property name As %Library.String(MAXLEN = 250) [ SqlColumnNumber = 3 ];

Property continent As %Library.String(MAXLEN = 250) [ SqlColumnNumber = 4 ];

Property region As %Library.String(MAXLEN = 250) [ SqlColumnNumber = 5 ];

Property surfacearea As %Library.Integer(MAXVAL = 2147483647, MINVAL = -2147483648) [ SqlColumnNumber = 6, SqlFieldName = surface_area ];

Property independenceyear As %Library.Integer(MAXVAL = 2147483647, MINVAL = -2147483648) [ SqlColumnNumber = 7, SqlFieldName = independence_year ];

Property population As %Library.Integer(MAXVAL = 2147483647, MINVAL = -2147483648) [ SqlColumnNumber = 8 ];

Property lifeexpectancy As %Library.Currency [ SqlColumnNumber = 9, SqlFieldName = life_expectancy ];

Property gnp As %Library.Double [ SqlColumnNumber = 10 ];

Property gnpold As %Library.Integer(MAXVAL = 2147483647, MINVAL = -2147483648) [ SqlColumnNumber = 11, SqlFieldName = gnp_old ];

Property localname As %Library.String(MAXLEN = 250) [ SqlColumnNumber = 12, SqlFieldName = local_name ];

Property governmentform As %Library.String(MAXLEN = 250) [ SqlColumnNumber = 13, SqlFieldName = government_form ];

Property headofstate As %Library.String(MAXLEN = 250) [ SqlColumnNumber = 14, SqlFieldName = head_of_state ];

Property capital As %Library.Integer(MAXVAL = 2147483647, MINVAL = -2147483648) [ SqlColumnNumber = 15 ];

Property code2 As %Library.String(MAXLEN = 250) [ SqlColumnNumber = 16 ];

ClassMethod Import(pSelectMode As %Library.Integer = {$zu(115,5)}, pFileName As %Library.String(MAXLEN=""), pDelimiter As %String = ",", pQuote As %String = """", pHeaders As %Integer = 0, ByRef pRecordCount As %Integer) As %Library.Integer [ SqlProc ]
{
	set tStatementId = $SYSTEM.Util.CreateGUID(), tCounter = 0, pRecordCount = 0
	set tPreparedStatement = ##class(%SQL.DynamicStatement).Prepare(tStatementId,..#ROWTYPE,pDelimiter,pQuote,,,0,"CSV")
	if $Isobject(tPreparedStatement) {
		set tImporter = tPreparedStatement.%New(tPreparedStatement,,pFileName,pDelimiter,pQuote)
		if $Isobject(tImporter) {
			do ..%DeleteExtent(,.tDeleted,.tInstances,1)
				// burn the column headers
			for tPtr = 1:1:pHeaders { do tImporter.%Next() }
			while tImporter.%Next() {
				set tMe = ..%New()
				if 'pSelectMode {
					set tMe.code = tImporter.%GetData(1)
					set tMe.name = tImporter.%GetData(2)
					set tMe.continent = tImporter.%GetData(3)
					set tMe.region = tImporter.%GetData(4)
					set tMe.surfacearea = tImporter.%GetData(5)
					set tMe.independenceyear = tImporter.%GetData(6)
					set tMe.population = tImporter.%GetData(7)
					set tMe.lifeexpectancy = tImporter.%GetData(8)
					set tMe.gnp = tImporter.%GetData(9)
					set tMe.gnpold = tImporter.%GetData(10)
					set tMe.localname = tImporter.%GetData(11)
					set tMe.governmentform = tImporter.%GetData(12)
					set tMe.headofstate = tImporter.%GetData(13)
					set tMe.capital = tImporter.%GetData(14)
					set tMe.code2 = tImporter.%GetData(15)
				}
				elseif pSelectMode = 1 {
					set tMe.code = $s('$system.CLS.IsMthd("codeOdbcToLogical"):tImporter.%GetData(1),1:tMe.codeOdbcToLogical(tImporter.%GetData(1)))
					set tMe.name = $s('$system.CLS.IsMthd("nameOdbcToLogical"):tImporter.%GetData(2),1:tMe.nameOdbcToLogical(tImporter.%GetData(2)))
					set tMe.continent = $s('$system.CLS.IsMthd("continentOdbcToLogical"):tImporter.%GetData(3),1:tMe.continentOdbcToLogical(tImporter.%GetData(3)))
					set tMe.region = $s('$system.CLS.IsMthd("regionOdbcToLogical"):tImporter.%GetData(4),1:tMe.regionOdbcToLogical(tImporter.%GetData(4)))
					set tMe.surfacearea = $s('$system.CLS.IsMthd("surfaceareaOdbcToLogical"):tImporter.%GetData(5),1:tMe.surfaceareaOdbcToLogical(tImporter.%GetData(5)))
					set tMe.independenceyear = $s('$system.CLS.IsMthd("independenceyearOdbcToLogical"):tImporter.%GetData(6),1:tMe.independenceyearOdbcToLogical(tImporter.%GetData(6)))
					set tMe.population = $s('$system.CLS.IsMthd("populationOdbcToLogical"):tImporter.%GetData(7),1:tMe.populationOdbcToLogical(tImporter.%GetData(7)))
					set tMe.lifeexpectancy = $s('$system.CLS.IsMthd("lifeexpectancyOdbcToLogical"):tImporter.%GetData(8),1:tMe.lifeexpectancyOdbcToLogical(tImporter.%GetData(8)))
					set tMe.gnp = $s('$system.CLS.IsMthd("gnpOdbcToLogical"):tImporter.%GetData(9),1:tMe.gnpOdbcToLogical(tImporter.%GetData(9)))
					set tMe.gnpold = $s('$system.CLS.IsMthd("gnpoldOdbcToLogical"):tImporter.%GetData(10),1:tMe.gnpoldOdbcToLogical(tImporter.%GetData(10)))
					set tMe.localname = $s('$system.CLS.IsMthd("localnameOdbcToLogical"):tImporter.%GetData(11),1:tMe.localnameOdbcToLogical(tImporter.%GetData(11)))
					set tMe.governmentform = $s('$system.CLS.IsMthd("governmentformOdbcToLogical"):tImporter.%GetData(12),1:tMe.governmentformOdbcToLogical(tImporter.%GetData(12)))
					set tMe.headofstate = $s('$system.CLS.IsMthd("headofstateOdbcToLogical"):tImporter.%GetData(13),1:tMe.headofstateOdbcToLogical(tImporter.%GetData(13)))
					set tMe.capital = $s('$system.CLS.IsMthd("capitalOdbcToLogical"):tImporter.%GetData(14),1:tMe.capitalOdbcToLogical(tImporter.%GetData(14)))
					set tMe.code2 = $s('$system.CLS.IsMthd("code2OdbcToLogical"):tImporter.%GetData(15),1:tMe.code2OdbcToLogical(tImporter.%GetData(15)))
				}
				elseif pSelectMode = 2 {
					set tMe.code = $s('$system.CLS.IsMthd("codeDisplayToLogical"):tImporter.%GetData(1),1:tMe.codeDisplayToLogical(tImporter.%GetData(1)))
					set tMe.name = $s('$system.CLS.IsMthd("nameDisplayToLogical"):tImporter.%GetData(2),1:tMe.nameDisplayToLogical(tImporter.%GetData(2)))
					set tMe.continent = $s('$system.CLS.IsMthd("continentDisplayToLogical"):tImporter.%GetData(3),1:tMe.continentDisplayToLogical(tImporter.%GetData(3)))
					set tMe.region = $s('$system.CLS.IsMthd("regionDisplayToLogical"):tImporter.%GetData(4),1:tMe.regionDisplayToLogical(tImporter.%GetData(4)))
					set tMe.surfacearea = $s('$system.CLS.IsMthd("surfaceareaDisplayToLogical"):tImporter.%GetData(5),1:tMe.surfaceareaDisplayToLogical(tImporter.%GetData(5)))
					set tMe.independenceyear = $s('$system.CLS.IsMthd("independenceyearDisplayToLogical"):tImporter.%GetData(6),1:tMe.independenceyearDisplayToLogical(tImporter.%GetData(6)))
					set tMe.population = $s('$system.CLS.IsMthd("populationDisplayToLogical"):tImporter.%GetData(7),1:tMe.populationDisplayToLogical(tImporter.%GetData(7)))
					set tMe.lifeexpectancy = $s('$system.CLS.IsMthd("lifeexpectancyDisplayToLogical"):tImporter.%GetData(8),1:tMe.lifeexpectancyDisplayToLogical(tImporter.%GetData(8)))
					set tMe.gnp = $s('$system.CLS.IsMthd("gnpDisplayToLogical"):tImporter.%GetData(9),1:tMe.gnpDisplayToLogical(tImporter.%GetData(9)))
					set tMe.gnpold = $s('$system.CLS.IsMthd("gnpoldDisplayToLogical"):tImporter.%GetData(10),1:tMe.gnpoldDisplayToLogical(tImporter.%GetData(10)))
					set tMe.localname = $s('$system.CLS.IsMthd("localnameDisplayToLogical"):tImporter.%GetData(11),1:tMe.localnameDisplayToLogical(tImporter.%GetData(11)))
					set tMe.governmentform = $s('$system.CLS.IsMthd("governmentformDisplayToLogical"):tImporter.%GetData(12),1:tMe.governmentformDisplayToLogical(tImporter.%GetData(12)))
					set tMe.headofstate = $s('$system.CLS.IsMthd("headofstateDisplayToLogical"):tImporter.%GetData(13),1:tMe.headofstateDisplayToLogical(tImporter.%GetData(13)))
					set tMe.capital = $s('$system.CLS.IsMthd("capitalDisplayToLogical"):tImporter.%GetData(14),1:tMe.capitalDisplayToLogical(tImporter.%GetData(14)))
					set tMe.code2 = $s('$system.CLS.IsMthd("code2DisplayToLogical"):tImporter.%GetData(15),1:tMe.code2DisplayToLogical(tImporter.%GetData(15)))
				}
				set tStatus = tMe.%Save()
				if $$$ISOK(tStatus) { set tCounter = tCounter + 1 }
			}
		}
	}
	set %sqlcontext.%SQLCODE = 0
	set %sqlcontext.%ROWCOUNT = tCounter
	set pRecordCount = tCounter
	quit tCounter
}

Parameter ROWTYPE = "code VARCHAR(250),name VARCHAR(250),continent VARCHAR(250),region VARCHAR(250),surface_area INTEGER,independence_year INTEGER,population INTEGER,life_expectancy MONEY,gnp DOUBLE,gnp_old INTEGER,local_name VARCHAR(250),government_form VARCHAR(250),head_of_state VARCHAR(250),capital INTEGER,code2 VARCHAR(250)";

Storage Default
{
<Data name="CountriesDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>code</Value>
</Value>
<Value name="3">
<Value>name</Value>
</Value>
<Value name="4">
<Value>continent</Value>
</Value>
<Value name="5">
<Value>region</Value>
</Value>
<Value name="6">
<Value>surfacearea</Value>
</Value>
<Value name="7">
<Value>independenceyear</Value>
</Value>
<Value name="8">
<Value>population</Value>
</Value>
<Value name="9">
<Value>lifeexpectancy</Value>
</Value>
<Value name="10">
<Value>gnp</Value>
</Value>
<Value name="11">
<Value>gnpold</Value>
</Value>
<Value name="12">
<Value>localname</Value>
</Value>
<Value name="13">
<Value>governmentform</Value>
</Value>
<Value name="14">
<Value>headofstate</Value>
</Value>
<Value name="15">
<Value>capital</Value>
</Value>
<Value name="16">
<Value>code2</Value>
</Value>
</Data>
<DataLocation>^Covid19.CountriesD</DataLocation>
<DefaultData>CountriesDefaultData</DefaultData>
<IdLocation>^Covid19.CountriesD</IdLocation>
<IndexLocation>^Covid19.CountriesI</IndexLocation>
<StreamLocation>^Covid19.CountriesS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
