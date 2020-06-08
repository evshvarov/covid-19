Class User.SleepStudy Extends (%Persistent, %XML.Adaptor, %ZEN.DataModel.Adaptor)
{

Property MPIID As %String;

Property StartDate As %Date;

Property EndDate As %Date;

Property Status As %String;

Property RequestingID As %String;

Property RequestingFacility As %String;

Property DateRequested As %Date;

Index PatientIndex On MPIID [ Unique ];

Index StartDateIndex On StartDate;

ClassMethod AddTestStudy(pDateFrom As %String, pDateTo As %String) As %Status
{
	
	Set tSC = $System.Status.OK()
	
	Set tSC = ..CreateSleepStudy(1,$zdateh(pDateFrom,4),$zdateh(pDateTo,4), "In Corso", "1", "1", $p($h,","))
	
	Quit tSC
}

ClassMethod CreateSleepStudy(pMPIID As %Integer, pStartDate As %Date, pEndDate As %Date, pStatus As %String, pRequestingID As %String, pRequestingFacility As %String, pDateRequested As %Date) As %Status
{

	Set tSC = $System.Status.OK()
	Try
	{
	//First let's opend referenced objects
	
	// Validate Patient's MPIID >> TBD
	
	//Now we've got everything, let's instance a new object
	Set pNewObj = ..%New()
	Set pNewObj.MPIID = pMPIID
	Set pNewObj.StartDate = pStartDate
	Set pNewObj.EndDate = pEndDate
	Set pNewObj.Status = pStatus
	Set pNewObj.RequestingID = pRequestingID
	Set pNewObj.RequestingFacility = pRequestingFacility
	Set pNewObj.DateRequested = pDateRequested
	
	Set tSC = pNewObj.%Save()
	
	}
	Catch (tException)
	{
		w !,"Error creating SleepStudy object! "_tException,!
		Set tSC = tException.AsStatus()
	}
	
	Quit tSC
}

Storage Default
{
<Data name="SleepStudyDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>MPIID</Value>
</Value>
<Value name="3">
<Value>StartDate</Value>
</Value>
<Value name="4">
<Value>EndDate</Value>
</Value>
<Value name="5">
<Value>Status</Value>
</Value>
<Value name="6">
<Value>RequestingID</Value>
</Value>
<Value name="7">
<Value>RequestingFacility</Value>
</Value>
<Value name="8">
<Value>DateRequested</Value>
</Value>
</Data>
<DataLocation>^User.SleepStudyD</DataLocation>
<DefaultData>SleepStudyDefaultData</DefaultData>
<IdLocation>^User.SleepStudyD</IdLocation>
<IndexLocation>^User.SleepStudyI</IndexLocation>
<StreamLocation>^User.SleepStudyS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
