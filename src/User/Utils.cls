Class User.Utils
{

ClassMethod Setup()
{
	do ..ImportData()
	do ##class(%DeepSee.Utils).%BuildCube("SleepRecord")
}

ClassMethod ImportData() As %Status
{
    set fn="/opt/irisapp/sql/TestData.sql"
    set str=$System.SQL.DDLImport("IRIS",$Username,fn,"/tmp/sql_err.log",,,";")
    q $$$OK
}

ClassMethod ImportDataClassic() As %Status
{
    set fn="/irisdev/app/sql/TestData.sql"
    set stream=..GetStreamFromFile(fn)

    while 'stream.AtEnd {
        set line=stream.ReadLine()

    }

    set sc = st.%Prepare(sql)
	quit:$$$ISERR(sc) sc
	
	#dim result As %SQL.StatementResult
	set result = st.%Execute(args...)
}

ClassMethod GetStreamFromFile(fn As %String) As %Stream
{
    set stream = ##Class(%Stream.FileCharacter).%New()
    set stream.LineTerminator = $Char(13,10)
    $$$TOE(sc,stream.LinkToFile(fn))
    //TBD check for sc
    return stream
}

}
