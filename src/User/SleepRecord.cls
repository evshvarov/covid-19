Class User.SleepRecord Extends (%Persistent, %XML.Adaptor, %ZEN.DataModel.Adaptor)
{

Property Study As User.SleepStudy [ Required ];

Property EventType As User.CT.EventType [ Required ];

Property RecordDate As %Date [ Required ];

Property TimeFrom As %Time [ Required ];

Property TimeTo As %Time;

Property Comments As %String;

Index RecordDateIndex On RecordDate;

ClassMethod AddRecord(pDate As %String, pTimeFrom As %String, pTimeTo As %String) As %Status
{
	
	Set tSC = $System.Status.OK()

	Set tSC = ..CreateRecord(1,1, $zdateh(pDate,4) , $ztimeh(pTimeFrom,2) , $ztimeh(pTimeTo,2) , "")
	
	Quit tSC
}

ClassMethod CreateRecord(pStudyID As %Integer, pEventyTypeId As %Integer, pRecordDate As %Date, pTimeFrom As %Time, pTimeTo As %Time, pComments As %String = "") As %Status
{

	Set tSC = $System.Status.OK()
	Try
	{
	//First let's opend referenced objects
	
	Set oStudy = ##class(User.SleepStudy).%OpenId(pStudyID)
	If '$IsObject(oStudy) {
		w !,"Could not open referenced Study",! 
		Quit
	}
	
	Set oEventType = ##class(User.CT.EventType).%OpenId(pEventyTypeId)
	If '$IsObject(oEventType) {
		w !,"Could not open referenced Event Type",! 
		Quit
	}
	
	//Now we've got everything, let's instance a new object
	Set pNewObj = ..%New()
	Set pNewObj.RecordDate = pRecordDate
	Set pNewObj.TimeFrom = pTimeFrom
	Set pNewObj.TimeTo = pTimeTo
	Set pNewObj.Comments = pComments
	
	Do pNewObj.StudySetObjectId(pStudyID)
	Do pNewObj.EventTypeSetObjectId(pEventyTypeId)
	
	Set tSC = pNewObj.%Save()
	
	}
	Catch (tException)
	{
		Set tSC = tException.AsStatus()
	}
	
	Quit tSC
}

ClassMethod Clean() As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
		k ^User.SleepRecordD
		k ^User.SleepRecordI
		s ^User.SleepRecordD=0
	}
	Catch (oException)
	{
		Set tSC = oException.AsStatus()
	}
	
	Quit tSC
}

Storage Default
{
<Data name="SleepRecordDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>EventType</Value>
</Value>
<Value name="3">
<Value>RecordDate</Value>
</Value>
<Value name="4">
<Value>TimeFrom</Value>
</Value>
<Value name="5">
<Value>TimeTo</Value>
</Value>
<Value name="6">
<Value>Comments</Value>
</Value>
<Value name="7">
<Value>Study</Value>
</Value>
</Data>
<DataLocation>^User.SleepRecordD</DataLocation>
<DefaultData>SleepRecordDefaultData</DefaultData>
<IdLocation>^User.SleepRecordD</IdLocation>
<IndexLocation>^User.SleepRecordI</IndexLocation>
<StreamLocation>^User.SleepRecordS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
