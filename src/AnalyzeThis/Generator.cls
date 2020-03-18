Class AnalyzeThis.Generator
{

/// This method will go through the entire generation process. Takes in a CSV file
ClassMethod GenerateAll(pSourceType, pSource, pLineSize, pHasHeaders, pCubeName, pPropertyJSONStreamId, pDataJSONStreamId) As %Status
{
	Try {
		// Preparing JSON
		Do ..UpdateTracking(1,"Working...")
		If pSourceType="CSV" {
			Set tSC=##class(AnalyzeThis.UI.Dialog.CSVImport).CSVToJSON(pSource,.tPropertyJSONStreamId,.tDataJSONStreamId,pLineSize,pHasHeaders)
		} ElseIf pSourceType="SQL" {
			Set tSC=##class(AnalyzeThis.Utils).SQLToJSON(pSource,.tPropertyJSONStreamId,.tDataJSONStreamId,pLineSize)
		} ElseIf pSourceType="Class" {
			// Get the SQL table name and then pass through SQL method
			Set sqlQuery=##class(AnalyzeThis.Utils).ClassToQuery(pSource)
			Set tSC=##class(AnalyzeThis.Utils).SQLToJSON(sqlQuery,.tPropertyJSONStreamId,.tDataJSONStreamId,pLineSize)
		}
		// Probably should provide a way to clean these instead of deleting them here
		If pPropertyJSONStreamId'="" {
			// Delete this stream if pPropertyJSONStreamId is populated, it may have updates
			Do ##class(%Stream.FileBinary).%DeleteId(tPropertyJSONStreamId)
		}
		If pDataJSONStreamId'="" {
			// This may contain "preview mode" data. Delete it
			Do ##class(%Stream.FileBinary).%DeleteId(pDataJSONStreamId)
		}
		Set tPropertyJSONStreamId=pPropertyJSONStreamId
		Do ..UpdateTracking(1,tSC)
		If $$$ISERR(tSC) $$$ThrowStatus(tSC)
		
		Set tCubeName=$select($G(pCubeName)'="":pCubeName,1:##class(AnalyzeThis.Generator).GenerateCubeName(pFileName))
		
		// Generating Source Class
		Do ..UpdateTracking(2,"Working...")
		Set tSC=##class(AnalyzeThis.Generator).GenerateSourceClass(tCubeName,tPropertyJSONStreamId)
		Do ..UpdateTracking(2,tSC)
		If $$$ISERR(tSC) $$$ThrowStatus(tSC)
		
		// Importing Data
		Do ..UpdateTracking(3,"Working...")
		Set tSC=##class(AnalyzeThis.Generator).ImportJSONData(tPropertyJSONStreamId, tDataJSONStreamId, tCubeName)
		Do ..UpdateTracking(3,tSC)
		If $$$ISERR(tSC) $$$ThrowStatus(tSC)
		
		// Generating Cube
		Do ..UpdateTracking(4,"Working...")
		Set tSC=##class(AnalyzeThis.Generator).GenerateCube(tCubeName,tPropertyJSONStreamId)
		Do ..UpdateTracking(4,tSC)
		If $$$ISERR(tSC) $$$ThrowStatus(tSC)
		
		
		// Populating Cube
		Do ..UpdateTracking(5,"Working...")
		Set tSC=##class(%DeepSee.Utils).%BuildCube(tCubeName,,0)
		Do ..UpdateTracking(5,tSC)
		If $$$ISERR(tSC) $$$ThrowStatus(tSC)
		
		// Generating Sample Dashboard
		Do ##class(AnalyzeThis.UI.CSVImport).AddDetails(tCubeName,pSourceType,pSource)
		
		Do ..UpdateTracking(6,"Working...")
		Set tSC=##class(AnalyzeThis.Generator).GenerateDash(tCubeName)
		Do ..UpdateTracking(6,tSC)
		If $$$ISERR(tSC) $$$ThrowStatus(tSC)
	} Catch ex {
		Set tSC=ex.AsStatus()
	}
	
	// Always clean up streams
	If tPropertyJSONStreamId'="" {
		Do ##class(%Stream.FileBinary).%DeleteId(tPropertyJSONStreamId)
	}
	If tDataJSONStreamId'="" {
		Do ##class(%Stream.FileBinary).%DeleteId(tDataJSONStreamId)
	}
	Quit tSC
}

ClassMethod UpdateTracking(pStep, pMsg)
{
	Set ^AnalyzeThis.GenerateTracking($j,pStep)=pMsg
	Quit
}

/// Given a file name, output the resulting cube name
ClassMethod GenerateCubeName(pFileName) As %String
{
	Set tName=$zstrip($replace($piece(##class(%File).GetFilename(pFileName),".",1),"DEEPSEE",""),"*PCW")
	
	Quit tName
}

/// Given a cube name and Property Stream ID, generate a source class
ClassMethod GenerateSourceClass(pCubeName, pPropertyJSONStreamId) As %Status
{
	Set tSC=$$$OK
	
	Set tSC=##class(AnalyzeThis.Dashboard.Utils).DeleteAll(pCubeName)
	
	// Take file from request
	Set tSC=##class(AnalyzeThis.Generator).JSONToClass(pPropertyJSONStreamId,"AnalyzeThis.Generated."_pCubeName)
	
	Quit tSC
}

/// Given a Property Stream ID and a Class Name, generate a Class with the given properties and name
ClassMethod JSONToClass(propertiesJSON As %String, pClassName As %String) As %Status
{
	//Use propertiesJSON to build class
	//Populate with dataJSON
	If ##class(%Dictionary.ClassDefinition).%ExistsId(pClassName) {
		Set tSC=##class(%Dictionary.ClassDefinition).%DeleteId(pClassName)
	}
	Set class=##class(%Dictionary.ClassDefinition).%New()
	Set class.Name=pClassName
	Set class.Super="%Persistent"
	Set tempStream=##class(%Stream.FileBinary).%OpenId(propertiesJSON)
	Set dynamicProperties={}.%FromJSON(tempStream)
	Set iter=dynamicProperties.Display.%GetIterator()
	While iter.%GetNext(.key,.value) {
		If dynamicProperties.Ignore.%Get(key) {
			Continue
		}
		Set prop=##class(%Dictionary.PropertyDefinition).%New()
		Set prop.Name=value
		Set prop.Type=dynamicProperties.Type.%Get(key)
		Set prop.SqlColumnNumber=key+2
		If prop.Type="%String" {
			Do prop.Parameters.SetAt("","MAXLEN")
		} ElseIf prop.Type="%Integer" {
			Set intformat=dynamicProperties.IntFormat.%Get(key)
			Set:intformat'="" prop.Type=intformat
			
			If intformat="%Library.Currency" {
				// Add setter method to strip currency signs if included
				Set method=##class(%Dictionary.MethodDefinition).%New(class.Name_"||"_prop.Name_"Set")
				Set method.Name=prop.Name_"Set"
				Set method.FormalSpec="pVal"
				Set method.ReturnType="%Status"
				
				Do method.Implementation.WriteLine(" Try { Set pVal=$zstrip(pVal,""*P"",,"".,"") }")
				Do method.Implementation.WriteLine(" Catch ex {  }")
				Do method.Implementation.WriteLine(" Set i%"_prop.Name_"=pVal")
				Do method.Implementation.WriteLine(" Quit $$$OK")

				Do class.Methods.Insert(method)

			}
		} ElseIf ((prop.Type="%Date") || (prop.Type="%TimeStamp")) {
			Set tempFormat=dynamicProperties.DateFormat.%Get(key)
			If tempFormat=5 {
				//Cast back as string until we support partial dates
				Set prop.Type="%String"
			} ElseIf tempFormat=30 {
				// No need to convert since this is in $H already
			} Else {
				//Create setter method to translate to $h
				Set method=##class(%Dictionary.MethodDefinition).%New(class.Name_"||"_prop.Name_"Set")
				Set method.Name=prop.Name_"Set"
				Set method.FormalSpec="pVal"
				Set method.ReturnType="%Status"
				
				If (prop.Type="%Date") {
					Do method.Implementation.WriteLine(" Try { Set pVal=$zdh(pVal,"_tempFormat_") }")
				} Else {
					// This is a %TimeStamp type, convert to %Date since %DeepSee.WizardUtils does not handle %TimeStamp
					Set prop.Type="%Date"
					Do method.Implementation.WriteLine(" Try { Set pVal=+$zdth(pVal,"_tempFormat_") }")
				}
				Do method.Implementation.WriteLine(" Catch ex {  }")
				Do method.Implementation.WriteLine(" Set i%"_prop.Name_"=pVal")
				Do method.Implementation.WriteLine(" Quit $$$OK")

				Do class.Methods.Insert(method)
			}
		}
		//If dynamicProperties.Include.%Get(key)="true" {
		Do class.Properties.Insert(prop)
		//}
	}
	
	// Set global name directly to allow for global mapping of AnalyzeThis.*
	Set param=##class(%Dictionary.ParameterDefinition).%New()
	Set param.Name="DEFAULTGLOBAL"
	// Unique up to 32 characters, only take first 16 chars of class name to avoid confusion
	Set param.Default="^AnalyzeThis.G."_$extract($piece(pClassName,".",*),1,16)
	Do class.Parameters.Insert(param)
	
	Set tSC=class.%Save()
	Set tSC=$system.OBJ.Compile(pClassName,"fck /displayerror=0 /displaylog=0")
	
	Quit tSC
}

/// Given a Property Stream ID, Data Stream ID, and a CubeName - populate the source class with data from the stream
ClassMethod ImportJSONData(propertyJSONStreamId As %String, dataJSONStreamId As %String, pCubeName As %String, pCleanFirst As %Boolean = 1) As %Status
{
	Set tSC=$$$OK
	
	Set tClassName="AnalyzeThis.Generated."_pCubeName
	
	If pCleanFirst {
		Set tSC=$classmethod(tClassName,"%DeleteExtent")
	}
	
	Set dataJSON=##class(%Stream.FileBinary).%OpenId(dataJSONStreamId)
	Set propertyJSON=##class(%Stream.FileBinary).%OpenId(propertyJSONStreamId)
	Set dataArray=[].%FromJSON(dataJSON)
	Set propertyObj={}.%FromJSON(propertyJSON)
	Set iterArray=dataArray.%GetIterator()
	While iterArray.%GetNext(.key,.val) {
		Set obj=$classmethod(tClassName,"%New")
		Set iterObj=dataArray.%Get(key).%GetIterator()
		While iterObj.%GetNext(.key2,.val2) {
			//Set:propertyObj.Include.%Get(propertyObj.%Get(key2))="true" $property(obj,propertyObj.Display.%Get(propertyObj.%Get(key2)))=val2
			Set $property(obj,propertyObj.Display.%Get(propertyObj.Properties.%Get(key2)))=val2
		}
		Set tSC= obj.%Save()
	}
	
	Quit tSC
}

/// Given a Cube name and a Property Stream ID, generate a cube
ClassMethod GenerateCube(pCubeName, pPropertyJSONStreamId) As %Status
{
	Set tSourceClass="AnalyzeThis.Generated."_pCubeName
	Set tCubeClass=tSourceClass_"Cube"
	Set tCubeName=pCubeName
	
	//Generate DeepSee Cube
	//Set st=##class(%DeepSee.WizardUtils).%GenerateCubeDefinition("AnalyzeThis.Generated."_tSourceClass_".Record",tCubeName,tCubeClass)
	Set st=##class(%DeepSee.WizardUtils).%GenerateCubeDefinition(tSourceClass,tCubeName,tCubeClass)
	If $$$ISERR(st) Quit st
	
	//Compile new cube class
	Set st=$System.OBJ.Compile(tCubeClass,"fck /displayerror=0 /displaylog=0")
	If $$$ISERR(st) Quit st
	
	Set tempStream=##class(%Stream.FileBinary).%OpenId(pPropertyJSONStreamId)
	Set propertyObj={}.%FromJSON(tempStream)
	
	//Disable items as needed
	Set model=$zobjclassmethod(tCubeClass,"%GetModel")
	For i=1:1:model.dimensions.Count() {
		Set tempPos=propertyObj.Properties.%Get(model.dimensions.GetAt(i).name)
		If propertyObj.Include.%Get(tempPos)'="true" {
			Set model.dimensions.GetAt(i).disabled=1
		}
	}
	For i=1:1:model.measures.Count() {
		If propertyObj.Include.%Get(propertyObj.Properties.%Get(model.measures.GetAt(i).name))'="true" {
			Set model.measures.GetAt(i).disabled=1
		}
		// make measures searchable
		Set model.measures.GetAt(i).searchable=1
		Set prop=##class(%Dictionary.PropertyDefinition).%OpenId(tSourceClass_"||"_model.measures.GetAt(i).sourceProperty)
		If $isobject(prop) {
			If prop.Type="%Library.Currency" {
					Set currency=##class(%SYS.NLS.Locale).%New()
					Set model.measures.GetAt(i).formatString=currency.Currency_"#.##;-"_currency.Currency_"#.##;;;"
			}
		}
	}
	Set st=##class(%DeepSee.Utils).%SaveCubeDefinition(tCubeClass,,model.description,model)
	If $$$ISERR(st) Quit st
	
	Set st=$System.OBJ.Compile(tCubeClass,"fck /displayerror=0 /displaylog=0")
	Quit st
}

/// Given a cube name, generate a Dashboard
ClassMethod GenerateDash(pCubeName As %String, pVerbose As %Boolean = 0) As %Status
{
	Set st=$$$OK
	Set dashName="Generated/Samples for "_pCubeName_".dashboard"
	If ##class(%DeepSee.Dashboard.Utils).%DashboardExists(dashName) {
		Do ##class(AnalyzeThis.Dashboard.Utils).DeleteDashboards(pCubeName)
	}
	Do ##class(AnalyzeThis.Dashboard.AutoPivot).GenerateSampleDashboards(pCubeName,pVerbose)
	Set st=##class(%DeepSee.Dashboard.Utils).%DashboardExists(dashName)
	Quit st
}

}
