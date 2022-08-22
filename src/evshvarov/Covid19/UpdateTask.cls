Class evshvarov.Covid19.UpdateTask Extends %SYS.Task.Definition
{

Method OnTask() As %Status
{
    return ##class(evshvarov.Covid19.Utils).DailyUpdate()
}

}
