Include %DeepSee

Class AnalyzeThis.Dashboard.Utils
{

/// Delete all data and classes for a specific cube.
ClassMethod DeleteAll(pName As %String) As %Status
{
	If ('##class(%DeepSee.Utils).%CubeExists(pName)) {
		Quit $$$ERROR($$$GeneralError,"Please enter a valid cube name")
	}

	Set tCubeName=$$$UPPER(pName)
	
	Set tCubeClass=##class(%DeepSee.Utils).%GetCubeClass(tCubeName)
	Set tCubeFactClass=##class(%DeepSee.Utils).%GetCubeFactClass(tCubeName)
	Set tSourceClass=$$$DeepSeeMetaGLVN("cubes",tCubeName,"sourceClass")
	
	//Delete pivots associated with the cube
	Do ##class(AnalyzeThis.Dashboard.Utils).GetPivotList(.pivots,,pName)
	Set pivot = $O(pivots(""))
	While pivot '= "" {
		Do ##class(%DeepSee.UserLibrary.Utils).%DeleteFolderItem(pivots(pivot))
		Set pivot = $O(pivots(pivot))
	}
	
	Do ##class(AnalyzeThis.Dashboard.Utils).DeleteDashboards(pName)
	
	Set tSC=$classmethod(tCubeFactClass,"%DeleteExtent")
	If $$$ISERR(tSC) {
		Quit tSC
	}
	
	Set tSC=$system.OBJ.Delete(tCubeClass,"/displayerror=0 /displaylog=0")
	If $$$ISERR(tSC) {
		Quit tSC
	}
	
	Set tSC=$classmethod(tSourceClass,"%DeleteExtent")
	If $$$ISERR(tSC) {
		Quit tSC
	}
	
	Set tSC=$system.OBJ.Delete(tSourceClass,"/displayerror=0 /displaylog=0")
	If $$$ISERR(tSC) {
		Quit tSC
	}
	
	//Delete MetaDataAnalysis associated with cube
	Set tSC=##class(AnalyzeThis.Dashboard.MetaData).Delete(pName)
	If $$$ISERR(tSC) {
		Quit tSC
	}

	If $$$ISERR(tSC) {
		Quit tSC
	}

	Kill ^AnalyzeThis.ImportCSV(pName)
	
	Quit tSC
}

/// Return a list of all currently defined DeepSee Pivots visible to the current user.
/// This is used by utilities.<br/>
/// This list takes the form:<br/>
/// pList(i)=fullName
/// If <var>pHidden</var> is true, then include trash and local items.<br/>
/// If <var>pCubeName</var> is provided, then only list pivots based on it.
ClassMethod GetPivotList(Output pList, pHidden As %Boolean = 0, pCubeName As %String = "") As %Status
{
	Set tSC = $$$OK
	Kill pList
	Try {
		Set i=1
		Set tFlag = $zu(115,8,0)
		Set tStatement = ##class(%SQL.Statement).%New(,"DEFAULT_SCHEMA")
		Set tSC = tStatement.%Prepare("SELECT ID FROM %DeepSee_Dashboard.Pivot")
		If $$$ISERR(tSC) Quit
		
		Set pCubeName = $$$UPPER(pCubeName)

		Set tRS = tStatement.%Execute()
		While (tRS.%Next(.tSC)) {
			If $$$ISERR(tSC) Quit
			If (tRS.ID '="") {
				Set tItem = ##class(%DeepSee.UserLibrary.FolderItem).%OpenId(tRS.ID)
				If ($IsObject(tItem)) {			
					Set tFullName = $P(tItem.fullName,".",1) // name without extension
					If (pHidden || ($E(tFullName,1)'="$") || ($E(tFullName,1,3)="$$$")) {
						If ((pCubeName="")||(pCubeName=$$$UPPER(tItem.cubeName))) {
							If (tItem.%CheckResource()) {
								Set pList(i) = tItem.fullName
								Set i=i+1
							}
						}
					}
				}
			}
		}
	} Catch(ex) {
		Set tSC = ex.AsStatus()
	}
	Set tFlag = $zu(115,8,tFlag)
	Quit tSC
}

ClassMethod DeleteDashboards(pCubeName As %String)
{
	//Delete Dashboards associated with the cube
	Set dashboards(1) = "Generated/Samples for "_pCubeName_".dashboard"
	Set dashboards(2) = "Generated/Sample ScoreCard for "_pCubeName_".dashboard"
	
	Set dashIdx = $O(dashboards(""))
	While dashIdx '= "" {
		Set dashName=dashboards(dashIdx)
		Set dash=##class(%DeepSee.Dashboard.Utils).%DashboardExists(dashName)
		If (dash) {
			Set tSC=##class(%DeepSee.Dashboard.Utils).%DeleteDashboard(dashName)
			If $$$ISERR(tSC) {
				Quit
			}
		}
		
		Set dashIdx = $O(dashboards(dashIdx))
	}
}

}
