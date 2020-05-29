Class Covid19.UpdateTask Extends %SYS.Task.Definition
{

Method OnTask() As %Status
{
    return ##class(Covid19.Utils).DailyUpdate()
}

}
