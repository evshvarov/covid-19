Class User.KPI.SleepRecord Extends %DeepSee.KPI
{

// KPI Class for SleepRecord (Diario Sonno) consolidated widget 

// Author: Federico Coda-Zabetta, 2020

// InterSystems

Parameter RESOURCE;

Parameter CUBE = "SLEEPRECORD";

/// This XData definition defines the KPI.
XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi xmlns="http://www.intersystems.com/deepsee/kpi"
 name="SleepRecord" sourceType="manual" caption="Diario Sonno">

<property name="1" displayName="12" columnNo="1"/>
<property name="2" displayName="13" columnNo="2"/>
<property name="3" displayName="14" columnNo="3"/>
<property name="4" displayName="15" columnNo="4"/>
<property name="5" displayName="16" columnNo="5"/>
<property name="6" displayName="17" columnNo="6"/>
<property name="7" displayName="18" columnNo="7"/>
<property name="8" displayName="19" columnNo="8"/>
<property name="9" displayName="20" columnNo="9"/>
<property name="10" displayName="21" columnNo="10"/>
<property name="11" displayName="22" columnNo="11"/>
<property name="12" displayName="23" columnNo="12"/>
<property name="13" displayName="24" columnNo="13"/>
<property name="14" displayName="1" columnNo="14"/>
<property name="15" displayName="2" columnNo="15"/>
<property name="16" displayName="3" columnNo="16"/>
<property name="17" displayName="4" columnNo="17"/>
<property name="18" displayName="5" columnNo="18"/>
<property name="19" displayName="6" columnNo="19"/>
<property name="20" displayName="7" columnNo="20"/>
<property name="21" displayName="8" columnNo="21"/>
<property name="22" displayName="9" columnNo="22"/>
<property name="23" displayName="10" columnNo="23"/>
<property name="24" displayName="11" columnNo="24"/>


</kpi>
}

/// Notification that this KPI is being executed.
/// This is a good place to override properties, such as range and threshold.
Method %OnExecute() As %Status
{
	
	Set tSC = $System.Status.OK()
	
	Try
	{
		//Set tCurrentFilters = ""
		//Set tFilters = ..%filterValues
		//First let's get the filters already applied at cube level
		//Set tCurrentFilters = ..FilterBuilder()
	    
	    //Parameters setting (to be implemented). Hardcoded in the meantime
	    // Time resolution: Number of minutes for each period (60 for 1 hour period)
	    Set pResolution = 60
	    // DayLong: Number of minutes in a day
	    Set DayLong = 1440
	    // MinLong: Number of seconds in a minute
	    Set MinLong = 60
	    //TotalCols: Number of periods in a day (24 for a 60 min period)
	    Set TotalCols = DayLong / pResolution
	    //Staring hour (will determine TimeOffset)
	    Set StartingHour = $ztimeh("12:00",2)
	    //TimeOffset: Starting hour (expressed in number of periods) for the graph (column headers need to be adjusted as well)
	    Set TimeOffset = StartingHour/(MinLong*pResolution)
	    
	   	//How many rows (dates) the series will have?
	    Set TotalRows = ..GetDateRange(.vDateRange, .tSC)
	    Quit:$System.Status.IsError(tSC)
	    
	    //Main loop
	    For tRow = 1:1:TotalRows 
	    {
		    Set tDate=vDateRange(tRow,"MDXDate")
			//For a given date, get the records times and the corresponding length
			Set TotalRecsForDate = ..GetTimeRecordsForDate(tDate, .TimeRange)
			
			//For each row, label the Series with the DisplayDate
			Set ..%seriesNames(tRow)=vDateRange(tRow)
			
			//Set the rIndex to -1 to ensure to get the first one at the first view
			Set rIndex = -1
			
	   		//For each record, get the corresponding Length of the record
	  		For tRecord=1:1:TotalRecsForDate
	    		{
		    	
		    	Set Length=0
		    	//First, Get the index of the current record
		    	Set rIndex =$o(TimeRange(tDate,rIndex))
		    	//Now, let's get the value of the record for the corresponding index
				Set Length=+$g(TimeRange(tDate,rIndex))
		    	//And then get the column at which belongs according to the resolution
		    	Set tCol=$normalize((rIndex/(MinLong*pResolution)),-1)
				//If the Length is less than zero, that means that the event finishes the following day
				if (Length<0) Set Length = Length + DayLong
				
				
				//Now we can distribute the amount of time to filled in terms of:
				//leadValue for the first column, full value for all the extra columns (totalShift),
				//and the remaining value for the last column
				
				Set tLength = Length
				Set totalShift = 1
				Set extraValue = 0
				//First, let's see how much do we have to fill in the first column
				if (tLength > 0) {
					Set leadValue = ((((tCol+1)*MinLong*pResolution)-rIndex)/MinLong)
					Set tLength=tLength-leadValue
					Set ^Fede3(tRow,tCol)=leadValue
				} 
				//Now fill up the rest
				while (tLength > 0) {
					if (tLength >= pResolution ) {
						Set totalShift = totalShift + 1
						Set tLength = tLength - pResolution
					} Else {
						Set extraValue = tLength
						Set tLength = 0
					}
				}
				//OK, time to fill the cells
				//First cell:			
				If (leadValue>0)
				{
					Set colPointer = tCol-TimeOffset+1
					Set rowShift = 0
					If (colPointer > TotalCols)
					{
						Set colPointer = colPointer - TotalCols
						Set rowShift = 1
					}
					If (colPointer <= 0)
					{
						Set colPointer = colPointer + TotalCols
						Set rowShift = -1
					}
					Set ..%data(tRow+rowShift, colPointer) = $normalize(leadValue/pResolution,2)
				}
				//If we need to fill extra columms:
				//First, let's paint the fully covered columns
				If (totalShift>1) 
				{
					For tColShift=1:1:totalShift-1
					{
						Set colPointer = tCol+tColShift-TimeOffset+1
						Set rowShift = 0
					
						If (colPointer > TotalCols)
						{
							Set colPointer = colPointer - TotalCols
							Set rowShift = 1
						}
						If (colPointer <= 0)
						{
							Set colPointer = colPointer + TotalCols
							Set rowShift = -1
						}
						Set ..%data(tRow+rowShift, colPointer) = 1
						//Set ..%data(tRow+rowShift, colPointer) = "{""value"":1,""tooltip"":""Event: Sleep\nDuration: "_Length_" mins""}"
					}
				}
				//Then, if there is a rest (extraValue), less than a period, assign it to the last cell
				If (extraValue > 0)
				{
					Set colPointer = tCol+totalShift-TimeOffset+1
					If (colPointer > TotalCols)
					{
						Set colPointer = colPointer - TotalCols
						Set rowShift = 1
					}
					If (colPointer <= 0)
					{
						Set colPointer = colPointer + TotalCols
						Set rowShift = -1
					}
					Set ..%data(tRow+rowShift, colPointer) = $normalize(extraValue/pResolution,2)
					//Set ..%data(tRow+rowShift, colPointer) = "{""value:"""_$normalize(extraValue/pResolution,2)_",""tooltip"":""Event: Sleep\nDuration: "_Length_" mins""}"
				}
				
			}
		    
	    }
	    Quit:$System.Status.IsError(tSC)
	    
	}
	Catch (oException)
	{
		Set tSC = oException.AsStatus()
	}
	
	Quit tSC
}

// This method makes the first query and returns an array with the rows (dates) in both Display Value

// and Cachè internal format to be used later on subsequent queries.

// It also  sets the %seriesCount to the correct number

Method GetDateRange(Output pDateRange, Output tSC As %Status) As %Integer
{
	Set tSC = $System.Status.OK()
	
	Try
	{
		
		//Apply filters to the query
		//TBI
		
		Set tMDX = "SELECT [RecordDate].[H1].[RecordDateDay].Members on rows FROM [SleepRecord]"
		
		Set oRS = ##class(%DeepSee.ResultSet).%New()
		
		Set tSC = oRS.%PrepareMDX(tMDX)
		Quit:$System.Status.IsError(tSC)
		
		Set tSC = oRS.%Execute()
		Quit:$System.Status.IsError(tSC)
	
		Set rows = +oRS.%GetRowCount()
		
		Set tLabel = ""
		
		For i=1:1:rows
		{
			Set tSC = oRS.%GetOrdinalLabel(.tLabel,2,i)
			Quit:$System.Status.IsError(tSC)
			
			Set tMDXDate = $zdateh(tLabel(1),6)
			
			//Change here to implement options for different date format labels
			Set tDisplayDate = $zdate(tMDXDate,4)
			
			Set vInternalDateRange(tMDXDate)=tDisplayDate
			Quit:$System.Status.IsError(tSC)
		}
		Quit:$System.Status.IsError(tSC)
		
		Set ..%seriesCount=0
		set tMDXDate=""
		For
		{
			Set tMDXDate=$Order(vInternalDateRange(tMDXDate))
			Quit:tMDXDate=""
			
			Set ^Fede(..%seriesCount)=vInternalDateRange(tMDXDate)
			Set ^Fede(..%seriesCount,"MDXDate")=tMDXDate
			
			Set ..%seriesCount=..%seriesCount+1
			Set pDateRange(..%seriesCount)=vInternalDateRange(tMDXDate)
			Set pDateRange(..%seriesCount,"MDXDate")=tMDXDate
		}
	}
	Catch (oException)
	{
		Set tSC = oException.AsStatus()
	}
	 
	Quit rows
}

// This method makes the first query and returns an array with the time records for a corresponding dates

// It also return the number of records for the given date

Method GetTimeRecordsForDate(pMDXDate As %String, Output pTimeRange, Output tSC As %Status) As %Integer
{
	Set tSC = $System.Status.OK()

	Try
	{
		
		//Apply filters to the query
		//TBI
		
		Set tMDX = "SELECT [Measures].[Length] ON 0, NON EMPTY [TimeFrom].[H1].[TimeFromMin].Members ON 1 FROM [SLEEPRECORD] %FILTER [RecordDate].[H1].[RecordDateDay].&["_pMDXDate_"]"

		Set oRS = ##class(%DeepSee.ResultSet).%New()
		
		Set tSC = oRS.%PrepareMDX(tMDX)
		Quit:$System.Status.IsError(tSC)
		
		Set tSC = oRS.%Execute()
		Quit:$System.Status.IsError(tSC)
	
		Set rows = +oRS.%GetRowCount()
		
		Set tLabel = ""
		k vInternalTimeRange
		k tMDXTime
		k tLength

		
		For i=1:1:rows
		{
			Set tSC = oRS.%GetOrdinalLabel(.tLabel,2,i)
			Quit:$System.Status.IsError(tSC)
			
			//Set tMDXTime = $ztimeh( $e(tLabel(1),0,*-2)_":00"_$e(tLabel(1),*-1,*))
			
			Set tMDXTime = $ztimeh(tLabel(1),2)
			
			Set tLength = oRS.%GetOrdinalValue(1,i)
			
			Set vInternalTimeRange(tMDXTime)=tLength
			
			Quit:$System.Status.IsError(tSC)
		}
		Quit:$System.Status.IsError(tSC)
		
		set tCol=-1
		For i=1:1:rows
		{
			Set tCol=$Order(vInternalTimeRange(tCol))
			Quit:tCol=""
			
			Set ^Fede2(pMDXDate,tCol)=vInternalTimeRange(tCol)
			
			Set pTimeRange(pMDXDate,tCol)=vInternalTimeRange(tCol)
		}
	}
	Catch (oException)
	{
		Set tSC = oException.AsStatus()
	}
	
	Quit rows
}

/// This callback is invoked from a dashboard when an action defined by this dashboard is invoked.
ClassMethod %OnDashboardAction(pAction As %String, pContext As %ZEN.proxyObject) As %Status
{
	// pAction is the name of the action (as defined in the XML list).
	// pContext contains information from the client
	// and can be used to return information.
	Quit $$$OK
}

/// Examines the filters defined in the cube, determines the current value of each, 
/// returns a string that can be used as the %FILTER clause.
Method FilterBuilder() As %String
{
 	set tFilters=""
 	set tSC = ##class(%DeepSee.Dashboard.Utils).%GetFiltersForDataSource(..#CUBE_".cube",.tFilters)
	quit:$$$ISERR(tSC) ""
   
    //iterate through defined filters and build up usedFilters array
	set i = "",usedFilters=0
	for {
		set i = $order(tFilters(i))
		quit:i=""

	    set filter=tFilters(i)
	   	set filterName=$LI(filter,2)
		set filterValue=$PROPERTY(..%filterValues,filterName)

		if filterValue'="" { 
		    set usedFilters=usedFilters+1
			do ..ParseFilterValue(filterValue,.FilterStateArray)
			// create usedFilters array
	    	//used FilterStateArray and build the string for this filter
	    	set string=..BuildString(filterName,.FilterStateArray)
	    	set usedFilters(usedFilters)=string
	    } ; end of looking at non-null filters

    } ; end of looking at defined filters
    
    set where=""
    if usedFilters>=1 {
       set where=..CombineFilterStrings(.usedFilters)
    }
    quit where
}

/// Uses usedFilters array and returns a string that can be used
/// as the %FILTER clause of a MDX query.
ClassMethod CombineFilterStrings(ByRef usedFilters) As %String [ Private ]
{
    set where=""
	if (usedFilters=1) {
	    set where=" %FILTER "_usedFilters(1)
   } elseif (usedFilters>1) {
	    set where=usedFilters(1)
		for i=2:1:usedFilters {
			set where="NONEMPTYCROSSJOIN("_usedFilters(i)_","_where_")"
	  	}
	  	set where=" %FILTER "_where
    }
    quit where
}

/// Given a filter value, returns, by reference, a FilterStateArray, 
/// which describes the filter state.
ClassMethod ParseFilterValue(filterValue As %String, Output FilterStateArray) As %Status [ Private ]
{
    //initialize this node 
    kill FilterStateArray  
    set FilterStateArray("not")=0
    
	Set filterValue = $ZSTRIP(filterValue,"<>W")
	set firstbit=$EXTRACT(filterValue,1,4)
	if firstbit="%NOT" {
		set FilterStateArray("not")=1
		set filterValue=$EXTRACT(filterValue,6,*)
	}

    //now check if we have a set
    set nextbit=$EXTRACT(filterValue)
    if nextbit="{" {
	    //take off { from the start and } from the end
	    set filterValue=$EXTRACT(filterValue,2,*-1)
        
		//parse the list of values the same way that Joe does
		Set valueCount=..%SplitList(filterValue,.tList)
		set FilterStateArray=valueCount
		for i=1:1:valueCount {
			set FilterStateArray(i)=tList(i)
			}
	    
	} else {
		//list has only 1 item; put it into the array
		set FilterStateArray=1
		set FilterStateArray(1)=filterValue
	}

	quit $$$OK
}

/// Given a filter name and a FilterStateArray, 
/// returns a string that can be used as an MDX set.
ClassMethod BuildString(filterName, ByRef FilterStateArray) As %String [ Private ]
{
    if (FilterStateArray = 1) {
	    set string=filterName_"."_FilterStateArray(1)
        if (FilterStateArray("not")=1) {
	       set string=string_".%NOT"
	       }
    } else {
	    set string="%OR({"
	    for i=1:1:FilterStateArray{
		   set string=string_filterName_"."_FilterStateArray(i)_","
		   } 
        //remove trailing comma and close set (which is wrapped in %OR)
        set string=$EXTRACT(string,1,*-1)
	    set string=string_"})"
	   
        //deal with NOT case
        if FilterStateArray("not")=1 {
	       set string="EXCEPT("_filterName_".MEMBERS,"_string_")"
	       }
	}
	quit string
}

/*
ClassMethod %OnGetFilterMembers(pFilter As %String, Output pMembers As %List, pSearchKey As %String) As %Status
{
	Set tSC = $$$OK
	Try {
		// get member list from cube
		If (pFilter = "Specialty") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[Specialty].[H1].[Specialty]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		If (pFilter = "FacilityClass") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[CustomSite].[H1].[FacilityClass]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		If (pFilter = "FacilityType") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[CustomSite].[H1].[FacilityType]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		If (pFilter = "Facility") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[CustomSite].[H1].[Facility]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		If (pFilter = "Name") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[CustomSite].[H1].[Name]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		If (pFilter = "ReferringCareProvider") {
		Set tSC = ..%GetMembersForFilter(..#CUBE,"[ReferringCareProvider].[H1].[ReferringCareProvider]",.pMembers,pSearchKey)
		If $$$ISERR(tSC) Quit
		}
		If (pFilter = "RequestType") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[ReferralDetails].[H1].[RequestType]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		If (pFilter = "WaitingListType") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[ReferralDetails].[H2].[WaitingListType]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		If (pFilter = "ReferralStatus") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[ReferralDetails].[H3].[ReferralStatus]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		If (pFilter = "ReviewStatus") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[ReviewDetails].[H1].[ReviewStatus]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		If (pFilter = "ReferralReason") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[ReferralDetails].[H4].[ReferralReason]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		If (pFilter = "ProvisionalDiagnosis") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[ClinicalDetails].[H1].[ProvisionalDiagnosis]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		If (pFilter = "ReferralPriority") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[ReferralDetails].[H5].[ReferralPriority]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		If (pFilter = "Priority") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[ClinicalDetails].[H2].[Priority]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		If (pFilter = "TargetFacility") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[ReferringToSite].[H1].[Facility]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		If (pFilter = "TargetSite") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[ReferringToSite].[H1].[Name]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		If (pFilter = "Service") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[ServiceDetails].[H1].[Service]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		If (pFilter = "GESCondition") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[GESDetails].[H1].[GESCondition]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		If (pFilter = "DischargeCause") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[DischargeDetails].[H1].[DischargeCause]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		If (pFilter = "ToDay") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[ToTime].[H1].[ToDay]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		If (pFilter = "AgeGroup") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[Patient].[Age].[H1].[AgeGroup]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		If (pFilter = "Gender") {
			Set tSC = ..%GetMembersForFilter(..#CUBE,"[Patient].[Demographics].[H1].[Gender]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}	
	}
	Catch(ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

ClassMethod GetMonthRange(tDate As %String) As %String
{
	Set tToday=$ZDate(+$H,3)
	Set tFirstDay=$ZDateH($Piece(tToday,"-",1,2)_"-01",3)
	Set iMonth=$Piece(tToday,"-",2)
	Set iYear=$Piece(tToday,"-",1)
	Set iMonth=iMonth+1
	If iMonth=13
	{
		Set iMonth=12
		Set iYear=iYear+1
	}
	Set tLastDay=$ZDateH(iYear_"-"_iMonth_"-01",3)-1
	
	Quit "&["_tFirstDay_"]:&["_tLastDay_"]"
}

ClassMethod GetYearRange(tDate As %String) As %String
{
	Set tToday=$ZDate(tDate,3)
	Set tFirstDay=$ZDateH($Piece(tToday,"-",1)_"-01-01",3)
	Set iMonth=$Piece(tToday,"-",2)
	Set iYear=$Piece(tToday,"-",1)
	Set iMonth=iMonth+1
	If iMonth=13
	{
		Set iMonth=12
		Set iYear=iYear+1
	}
	Set tLastDay=$ZDateH(iYear_"-"_iMonth_"-01",3)-1
	
	Quit "&["_tFirstDay_"]:&["_tLastDay_"]"
}

ClassMethod %OnGetListingSQL(ByRef pFilters As %String, ByRef pSelection As %String) As %String
{
    Set tSC = $System.Status.OK()
    
    Try {
    
    	Set tSQL = "select source.PlacerID as ""Nº SIC"", to_char(source.FromTime,'DD/MM/YYYY') as ""Fecha de Solicitud"", cr.RequestType as ""Tipo de Solicitud"", cr.ReferralStatus as ""Estado"", p.SSN as ""RUT"", Patient->Name_FamilyName as ""Apellido Paterno"", Patient->Name_MiddleName as ""Apellido Materno"", Patient->Name_GivenName as ""Nombres"", Patient->Age as ""Edad"", to_char(Patient->BirthDate,'DD/MM/YYYY') as ""Fecha Nac"", Patient->Gender_Description as ""Género"", cr.WaitingListType as ""Tipo de Espera"", source.ReferralReason as ""Motivo de Solicitud"", cr.ReferralPriority as ""Prioridad de Referencia"", cr.Priority as ""Prioridad Clínica"", cr.GESCondition as ""Problema GES"", TRIM(cr.ProvisionalDiagnosis) as ""Diagnóstico Provisional"", TRIM(cr.ReferralRequirements) as ""Fundamentos de la Referencia"", source.ReferringHealthCareFacility->Description as ""Establecimiento Origen"", source.ReferringSite->Name as ""Unidad Origen"", source.ReferringClinician_Code as ""RUT Profesional"", source.ReferringClinician_Description as ""Profesional"", (CASE source.ReferringClinician_CareProviderType_Code WHEN 'M' THEN 'Médico' WHEN 'OD' THEN 'Odontólogo' WHEN 'MT' THEN 'Matrón(a)' WHEN 'PQ' THEN 'Psiquiatra' WHEN 'TM' THEN 'Técnico Paramético' WHEN 'TM' THEN 'Tecnólogo Médico' WHEN 'NT' THEN 'Nutricionista' WHEN 'ENF' THEN 'Enfermera(o)' END) as ""Tipo de Profesional"", cr.Specialty as ""Especialidad"", TRIM(cr.DoctorNotes) as ""Notas del Profesional"", source.ReceivingReferralHealthCareFacility->Description as ""Establecimiento destino"", source.ReceivingReferralSite->Name as ""Unidad destino"", cr.ReviewStatus as ""Estado de Revisión"",  to_char(cr.ReviewDateTime,'DD/MM/YYYY HH24:MI:SS') as ""Fecha/Hora de Revisión"", cr.ReviewUserCode as ""RUT Prof Revisión"", cr.ReviewUserDesc as ""Profesional Revisión"", round(cr.ReviewTime,2) as ""Tiempo de Revisión [días]"", to_char(cr.ApptDate,'DD/MM/YYYY') as ""Fecha de la Cita"", cr.Service as ""Prestación"", to_char(source.ToTime,'DD/MM/YYYY') as ""Fecha de Egreso"", cr.DischargeCause as ""Causal de Egreso"", cr.RemovalReason as ""Motivo de Remoción"", round(cr.ReferralTime,0) as ""Días de espera"", cr.ExternalID as ""Nº de Folio SIGGES"", to_char(source.EnteredOn, 'DD/MM/YYYY HH24:MI:SS') as ""Fecha/Hora Registro"", source.EnteredBy_Code as ""RUT Digitador"", source.EnteredBy_Description as ""Digitador"", round(cr.EnteredTime,2) as ""Tiempo de Digitación [días]"" from HSAA.Referral source inner join Custom_HSAA.Referral cr on cr.HSAATableRecordID = source.%Id inner join HSAA.Patient on source.Patient=Patient.ID inner join Custom_HSAA.Patient p on Patient.ID=p.HSAATableRecordId left join hsaa.HealthCareFacility Shcf on source.ReferringHealthCareFacility = Shcf.%id left join hsaa.HealthCareFacility Thcf on source.ReceivingReferralHealthCareFacility = Thcf.%id left join Custom_CT.Facility Scf on Shcf.Code=Scf.NewDEISCode left join Custom_CT.Facility Tcf on Thcf.Code=Tcf.NewDEISCode"
    	Set tTimeResolution = $G(pFilters("TimeResolution"))
    	Set tDateRange = $G(pFilters("DateRange"))
    	Set tInitialRow = $P($G(pSelection("selectedRange")),",",1)
    	Set tInitialCol = $P($G(pSelection("selectedRange")),",",2)
    	Set tFinalRow = $P($G(pSelection("selectedRange")),",",3)
	    Set tFinalCol = $P($G(pSelection("selectedRange")),",",4)
    
    	Set tInitialDate = ..ConvertDateToHorolog(tDateRange,1,.tSC)
    	
    	//Selection time ranges
    	If tTimeResolution = "Day"
    		{
	    	Set tEndDate = tInitialDate + tFinalRow - 1
	    	Set tInitialDate = tInitialDate + tInitialRow - 1
	  		}
	  	ElseIf tTimeResolution = "Month"
	  		{
		  		Set tEndDate = (..GetFirstDayOfTheMonth(tInitialDate,tFinalRow)-1)
		  		Set tInitialDate = ..GetFirstDayOfTheMonth(tInitialDate,(tInitialRow-1))
		  	}
		ElseIf tTimeResolution = "Year"
	  		{
		  		Set tEndDate = (..GetFirstDayOfTheYear(tInitialDate,tFinalRow)-1)
		  		Set tInitialDate = ..GetFirstDayOfTheYear(tInitialDate,(tInitialRow-1))  		
	  		}  	
    	
    	Set tInitialDate = $zdate(tInitialDate,3)
    	Set tEndDate = $zdate(tEndDate,3)
    
    	Set tDateField = ""
    	
    	If tInitialCol = 1
    		{
	    	Set tDateField = "FromTime"
	     	}
	    elseif tInitialCol = 2
	    	{
	    	Set tDateField = "ToTime"
    		}
		
		Set tSelection = "(" _ tDateField _ " >= '" _ tInitialDate _ "' AND " _ tDateField _ " <= '" _ tEndDate_"')"
		
		If ((tFinalCol > tInitialCol) && (tInitialCol = 1))
    	{
	    	Set tDateField = "ToTime"
	    	Set tSelection = " (" _ tSelection _ " OR (" _ tDateField _ " >= '" _ tInitialDate _ "' AND " _ tDateField _ " <= '" _ tEndDate_"'))"		
	    }
    	
    	//Filter by Selection	   	
    	Set tSQL = tSQL _ " WHERE " _ tSelection
    
    	//Filter by dashboard filters
    	Set tSQL = tSQL _ ..GetSQLFilters(.pFilters)
    	  	
    	//Order
    	Set tSQL = tSQL _ " ORDER BY FromTime"

   		If (tInitialCol = 3)
    	{
	    	Set tSC = $System.Status.Error(5001,"Elegir un valor de la columna de ingresos o de egresos para obtener el listado")
			Set tSQL="SELECT 'Elegir una celda de ingresos o de egresos para obtener el listado' as ""Error"" FROM HSAA.REFERRAL WHERE %ID=1"
		} 	
    	
    	
    	}
	Catch(ex) {
		Set tSC = ex.AsStatus()
	}
		
	Set ^Fede = tSQL

    Quit tSQL
}

ClassMethod GetFirstDayOfTheMonth(pInitialDate As %Integer, pOffSet As %Integer) As %Integer
{
	
	Set tInitialDate = $ZDate(pInitialDate,3)
	Set tInitialYear = +$Piece(tInitialDate,"-",1)
	Set tInitialMonth = +$Piece(tInitialDate,"-",2) + pOffSet
	while tInitialMonth > 12
	{
		Set tInitialYear = tInitialYear + 1
		Set tInitialMonth = tInitialMonth - 12
	}
	Set tFinalDate = $ZDateH(tInitialYear_"-"_tInitialMonth_"-01",3)
	Quit +tFinalDate
}

ClassMethod GetFirstDayOfTheYear(pInitialDate As %Integer, pOffSet As %Integer) As %Integer
{
	Set tInitialYear = +$Piece($ZDate(pInitialDate,3),"-",1) + pOffSet 
	Set tFinalDate = $ZDateH(tInitialYear_"-01-01",3)
	Quit +tFinalDate
}

ClassMethod GetSQLFilters(ByRef pFilters) As %String
{

    	Set tSQL = ""
    	
    	If (($G(pFilters("RequestType"))'="")&&($G(pFilters("RequestType"))'="*"))
		{
			Set tSQL = tSQL _ " AND cr.RequestType = '" _ $Translate($Translate($G(pFilters("RequestType")),"&["),"]") _ "'"
		}
    	If (($G(pFilters("ReferralStatus"))'="")&&($G(pFilters("ReferralStatus"))'="*"))
		{
			Set tSQL = tSQL _ " AND cr.ReferralStatus = '" _ $Translate($Translate($G(pFilters("ReferralStatus")),"&["),"]") _ "'"
		}
    	If (($G(pFilters("WaitingListType"))'="")&&($G(pFilters("WaitingListType"))'="*"))
		{
			Set tSQL = tSQL _ " AND cr.WaitingListType = '" _ $Translate($Translate($G(pFilters("WaitingListType")),"&["),"]") _ "'"
		}
    	If (($G(pFilters("ReferralReason"))'="")&&($G(pFilters("ReferralReason"))'="*"))
		{
			Set tSQL = tSQL _ " AND source.ReferralReason = '" _ $Translate($Translate($G(pFilters("ReferralReason")),"&["),"]") _ "'"
		}
    	If (($G(pFilters("ReferralPriority"))'="")&&($G(pFilters("ReferralPriority"))'="*"))
		{
			Set tSQL = tSQL _ " AND cr.ReferralPriority = '" _ $Translate($Translate($G(pFilters("ReferralPriority")),"&["),"]") _ "'"
		}
    	If (($G(pFilters("Priority"))'="")&&($G(pFilters("Priority"))'="*"))
		{
			Set tSQL = tSQL _ " AND cr.Priority = '" _ $Translate($Translate($G(pFilters("Priority")),"&["),"]") _ "'"
		}
    	If (($G(pFilters("GESCondition"))'="")&&($G(pFilters("GESCondition"))'="*"))
		{
			Set tSQL = tSQL _ " AND cr.GESCondition = '" _ $Translate($Translate($G(pFilters("GESCondition")),"&["),"]") _ "'"
		}
    	If (($G(pFilters("ReferralPriority"))'="")&&($G(pFilters("ReferralPriority"))'="*"))
		{
			Set tSQL = tSQL _ " AND cr.ReferralPriority = '" _ $Translate($Translate($G(pFilters("ReferralPriority")),"&["),"]") _ "'"
		}
    	If (($G(pFilters("ProvisionalDiagnosis"))'="")&&($G(pFilters("ProvisionalDiagnosis"))'="*"))
		{
			Set tSQL = tSQL _ " AND cr.ProvisionalDiagnosis = '" _ $Translate($Translate($G(pFilters("ProvisionalDiagnosis")),"&["),"]") _ "'"
		}
    	If (($G(pFilters("Facility"))'="")&&($G(pFilters("Facility"))'="*"))
		{
			Set tSQL = tSQL _ " AND Scf.Description = '" _ $Translate($Translate($G(pFilters("Facility")),"&["),"]") _ "'"
		}
    	If (($G(pFilters("Name"))'="")&&($G(pFilters("Name"))'="*"))
		{
			Set tSQL = tSQL _ " AND source.ReferringSite->Name = '" _ $Translate($Translate($G(pFilters("Name")),"&["),"]") _ "'"
		}
    	If (($G(pFilters("ReferringCareProvider"))'="")&&($G(pFilters("ReferringCareProvider"))'="*"))
		{
			Set tSQL = tSQL _ " AND source.ReferringClinician_Description = '" _ $Translate($Translate($G(pFilters("ReferringCareProvider")),"&["),"]") _ "'"
		}
    	If (($G(pFilters("Specialty"))'="")&&($G(pFilters("Specialty"))'="*"))
		{
			Set tSQL = tSQL _ " AND cr.Specialty = '" _ $Translate($Translate($G(pFilters("Specialty")),"&["),"]") _ "'"
		}
    	If (($G(pFilters("TargetFacility"))'="")&&($G(pFilters("TargetFacility"))'="*"))
		{
			Set tSQL = tSQL _ " AND Tcf.Description = '" _ $Translate($Translate($G(pFilters("TargetFacility")),"&["),"]") _ "'"
		}
    	If (($G(pFilters("TargetSite"))'="")&&($G(pFilters("TargetSite"))'="*"))
		{
			Set tSQL = tSQL _ " AND source.ReceivingReferralSite->Name = '" _ $Translate($Translate($G(pFilters("TargetSite")),"&["),"]") _ "'"
		}
    	If (($G(pFilters("ReviewStatus"))'="")&&($G(pFilters("ReviewStatus"))'="*"))
		{
			Set tSQL = tSQL _ " AND cr.ReviewStatus = '" _ $Translate($Translate($G(pFilters("ReviewStatus")),"&["),"]") _ "'"
		}		
		
		Quit tSQL
}
*/
}
