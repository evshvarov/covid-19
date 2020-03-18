Class AnalyzeThis.Utils
{

ClassMethod GetNextRegex(ByRef pMatch, ByRef pResult, pIncludeTerm As %Boolean = 1) As %Boolean
{
	Set pResult=""
	
	If '$IsObject(pMatch) {
		Quit 0
	}
	
	Set tStart=$Case(pMatch.End,-2:1,:pMatch.End)
	Set tBool=pMatch.Locate()
	Quit:tBool=0 tBool
	Set tEnd=pMatch.End
	
	Set pResult=$e(pMatch.Text,tStart,$select(pIncludeTerm=1:pMatch.End,1:pMatch.Start)-1)
	
	Quit tBool
}

ClassMethod GetRegexLine(pNewLine As %String) As %String
{
	Quit $replace(pNewLine,"\","\\")_"(?=(?:(?:\\.|[^""\\])*""(?:\\.|[^""\\])*"")*(?:\\.|[^""\\])*\Z)"
}

ClassMethod GetRegexProp(pNewLine As %String) As %String
{
	Quit "("_$replace(pNewLine,"\","\\")_"|,)"_"(?=(?:(?:\\.|[^""\\])*""(?:\\.|[^""\\])*"")*(?:\\.|[^""\\])*\Z)"
}

ClassMethod DetermineNewLine(pString As %String) As %String
{
	Set tNewLine=$c(13)_$c(10)
	
	If ($find(pString,$c(10))=0)&&($find(pString,$c(13))>0) {
		Set tNewLine=$c(13)
	} ElseIf ($find(pString,$c(10))>0)&&($find(pString,$c(13))=0) {
		Set tNewLine=$c(10)
	} ElseIf ($find(pString,$c(10))>($find(pString,$c(13))+1)) {
		// Assume that headers do not have $c(13) or $c(10)
		Set tNewLine=$c(13)
	}
	
	Quit tNewLine
}

ClassMethod ReadStream(ByRef pStream, pString As %String = "") As %String
{
	Set tRet=pString_pStream.Read()
	Set tQuotes=$length(tRet,"""")-1
	
	If tQuotes#2 {
		// This means there is an odd number of quotes.
		// Continue to read until a single quote is found
		Set tDone=0
		While 'tDone {
			Set tNext=pStream.Read(1)
			Set tRet=tRet_tNext
			If tNext="""" {
				Set tNext=pStream.Read(1)
				Set tRet=tRet_tNext
				If tNext'="""" {
					// We are done, quotes are balanced
					Set tDone=1
				}
			}
		}
	} 
	
	Quit tRet
}

/// Given a cube name, refresh the data from the data source
ClassMethod RefreshCube(pCubeName As %String, pLineSize As %Integer = 0, pVerbose As %Integer = 0) As %Status
{
	Set st=$$$OK
	Set version=$O(^AnalyzeThis.ImportCSV(pCubeName,""))
	If version'="" {
		Set sourceType=$O(^AnalyzeThis.ImportCSV(pCubeName,version,""))
		If sourceType="CSV" {
			Set fileLocation=^AnalyzeThis.ImportCSV(pCubeName,version,sourceType)
			Write:pVerbose "Converting CSV to JSON...",!
			Set st=##class(AnalyzeThis.UI.Dialog.CSVImport).CSVToJSON(fileLocation,.tPropertyJSONStreamId,.tDataJSONStreamId,pLineSize)
			If $$$ISERR(st) Quit st
			Write:pVerbose "CSV successfully converted",!,"Refreshing data from JSON...",!
			Set st=##class(AnalyzeThis.Utils).RefreshJSONData(tDataJSONStreamId,pCubeName)
			if $$$ISERR(st) Quit st
			write:pVerbose "Data successfully refreshed",!,"Building the cube...",!
			Set st=$system.DeepSee.BuildCube(pCubeName)
			if $$$ISERR(st) Quit st
			write:pVerbose "Cube successfully built",!
		}
	}
	Quit st
}

/// Given a Property Stream ID, Data Stream ID, and a CubeName - populate the source class with data from the stream
ClassMethod RefreshJSONData(dataJSONStreamId As %String, pCubeName As %String) As %Status
{
	Set tSC=$$$OK
	
	Set tClassName="AnalyzeThis.Generated."_pCubeName
	Set tSC=$classmethod(tClassName,"%DeleteExtent")
	
	// Get property name array
	Do ##class(AnalyzeThis.Utils).GetPropertyNames(tClassName,.propNames)
	
	Set dataJSON=##class(%Stream.FileBinary).%OpenId(dataJSONStreamId)
	Set dataArray=[].%FromJSON(dataJSON)
	Set iterArray=dataArray.%GetIterator()
	While iterArray.%GetNext(.key,.val) {
		Set obj=$classmethod(tClassName,"%New")
		Set iterObj=dataArray.%Get(key).%GetIterator()
		Set propCount=0
		While iterObj.%GetNext(.key2,.val2) {
			Set $property(obj,propNames($i(propCount)))=val2
		}
		Set tSC= obj.%Save()
	}
	
	Quit tSC
}

/// Given a class name, get the property names by order of SqlColumnNumber
ClassMethod GetPropertyNames(pClassName As %String, Output pPropNames) As %Status
{
	Set sql="SELECT Name FROM %Dictionary.PropertyDefinition WHERE parent=? ORDER BY SqlColumnNumber"
	Set sqlrs=##class(%SQL.Statement).%ExecDirect(,sql,pClassName)
	
	While sqlrs.%Next() {
		Set pPropNames($i(pPropNames))=sqlrs.Name
	}
	
	Quit $$$OK
}

ClassMethod SQLToJSON(pSourceQuery As %String, ByRef propertyJSONStreamId, ByRef dataJSONStreamId, pMaxLines As %Integer = 0) As %Status
{
	Set tSC=$$$OK
	
	// Build Prop JSON
	Set sqlrs=##class(%SQL.Statement).%ExecDirect(,pSourceQuery)
	If sqlrs.%SQLCODE'=0 {
		Quit $$$ERROR(5001,"SQLToJSON Error. SQLCODE: "_$SYSTEM.SQL.SQLCODE(sqlrs.%SQLCODE))
	}
	Set metadata=sqlrs.%GetMetadata()
	Set properties={}
	Set propposition={}
	Set displayarray=[]
	Set typearray=[]
	Set dateformatarray=[]
	Set includearray=[]
	Set intformatarray=[]
	// ignorearray is an array that says if a column has an empty header
	Set ignorearray=[]
	Set propcount=-1
	For i=1:1:metadata.columnCount {
		Set propcount=$i(propcount)
		Set prop=metadata.columns.GetAt(i).colName
		Do displayarray.%Push(prop)
		Do typearray.%Push("%String")
		Do dateformatarray.%Push("")
		Do intformatarray.%Push("")
		Do includearray.%Push("true")
		Do ignorearray.%Push(prop="")
		Do propposition.%Set(prop,propcount)
	}
	Do properties.%Set("Properties",propposition)
	Do properties.%Set("Display",displayarray)
	Do properties.%Set("Type",typearray)
	Do properties.%Set("DateFormat",dateformatarray)
	Do properties.%Set("IntFormat",intformatarray)
	Do properties.%Set("Include",includearray)
	Do properties.%Set("Ignore",ignorearray)
	
	Set propertyJSONStream=##class(%Stream.FileBinary).%New()
	Do properties.%ToJSON(.propertyJSONStream)
	Do propertyJSONStream.%Save()
	Set propertyJSONStreamId=propertyJSONStream.%Id()
	
	// Build Data JSON
	Set dynamicArray=[]
	While sqlrs.%Next() {
		Set dynamicObject={}
		For i=0:1:propcount {
			Do dynamicObject.%Set(properties.Display.%Get(i),sqlrs.%GetData(i+1))
		}
		Do dynamicArray.%Push(dynamicObject)
		
		Set rowcount=$i(rowcount)
		If (pMaxLines>0)&&(rowcount>pMaxLines) {
			Quit
		}
	}
	
	Set dataJSONStream=##class(%Stream.FileBinary).%New()
	Do dynamicArray.%ToJSON(.dataJSONStream)
	Do dataJSONStream.%Save()
	Set dataJSONStreamId=dataJSONStream.%Id()
	
	Quit tSC
}

ClassMethod ClassToQuery(pClass) As %String
{
	// Check for .cls extension
	Set tCls=1
	If $zconvert($extract(pClass,*-3,*),"U")'=".CLS" {
		Set tCls=0
	}
	Set sqlTableName=##class(%DeepSee.Utils).%GetSQLTableName($piece(pClass,".",1,*-tCls))
	Set sqlQuery="SELECT * FROM "_sqlTableName
	Quit sqlQuery
}

}
