Class User.Utils
{

ClassMethod ImportData() As %Status
{
    set str=$System.SQL.DDLImport("IRIS",$Username,"/irisdev/app/sql/TestData.sql")
    q $$$OK
}

}
