Include %DeepSee

/// DeepSee CSV Import page.
/// This page lets you import data from a CSV file into DeepSee.
Class AnalyzeThis.UI.CSVImport Extends %DeepSee.UI.standardPage [ System = 4 ]
{

Parameter DOMAIN = "AnalyzeThis";

Parameter Version = 1;

/// Displayed name of this page.
Parameter PAGENAME = "AnalyzeThis";

/// If this page has multiple views, this is its initial display mode.
Parameter DEFAULTVIEWMODE;

Parameter DOCBOOKID;

/// If true, the user has write access to the page.
Property canWritePage As %ZEN.Datatype.boolean [ InitialExpression = 1 ];

/// If true, user can modify this particular listing group.
Property canWrite As %ZEN.Datatype.boolean [ InitialExpression = 1 ];

XData contentPane [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane xmlns="http://www.intersystems.com/zen">
<hgroup valign="top" >
<spacer width="20" />
<vgroup valign="top" >
<spacer height="20" />
<tablePane id="table"
    cellSpacing="2"
	fixedHeaders="false"	
	queryClass="AnalyzeThis.UI.CSVImport"
	queryName="GetImportedCubes"
	useSnapshot="true"
	showQuery="false"
	showZebra="true"
	showRowNumbers="false"
	maxRows="5000"
	valueColumn="CubeName"
	
	>
<column colName="CubeName" header="Cube Name" />
<column colName="Analyzer" link="#(%query.Application)#_DeepSee.UI.Analyzer.zen?CUBE=#(%query.CubeName)#"/>
<column colName="Architect" link="#(%query.Application)#_DeepSee.UI.Architect.zen?CUBE=#(%query.CubeName)#"/>
<column colName="Dashboard" link="#(%query.Application)#_DeepSee.UserPortal.DashboardViewer.zen?DASHBOARD=Generated/Samples%20for%20#(%query.CubeName)#.dashboard"/>
<column colName="ScoreCard" link="#(%query.Application)#_DeepSee.UserPortal.DashboardViewer.zen?DASHBOARD=Generated/Sample%20ScoreCard%20for%20#(%query.CubeName)#.dashboard"/>
<column colName="Info" onclick="return zenPage.showInfo('#(%query.CubeName)#');" linkCaption="Info" link="#"/>
<column colName="RefreshData" onclick="zenPage.refreshCube('#(%query.CubeName)#');" linkCaption="RefreshData" link="#"/>
<column colName="Application" hidden="true"/>
</tablePane>
</vgroup>
</hgroup>
</pane>
}

/// Get the (localized) title string for the page.
/// This should be implemented in a subclass.
Method %OnGetTitle() As %String [ Internal ]
{
	Quit $$$Text("AnalyzeThis","AnalyzeThis")
}

/// Get the (localized) name of the page.
Method %OnGetPageName() As %String [ Internal ]
{
	Quit $$$Text("AnalyzeThis","AnalyzeThis")
}

/// Get the product name for the page.
Method %OnGetProductName() As %String [ Internal ]
{
	Quit "DeepSee"
}

/// Get information to display in the ribbon bar.
Method OnGetRibbonInfo(Output pDisplay As %Boolean, Output pViewIcons As %List, Output pSortOptions As %List, Output pSearchBox As %Boolean, Output pRibbonTitle As %String, Output pCommands As %List) As %Status [ Internal ]
{
	Set pDisplay=1
	Set pSearchBox=0
	Set pRibbonTitle=$$$Text("AnalyzeThis")

	// commands
	// $LB(id,caption,help,onclick)
	Set:(..canWrite||..canWritePage) pCommands($I(cmdIdx))=$LB("cmdNew",$$$Text("New"),$$$Text("Create a cube based off a CSV file"),"zenPage.newCube();")
	//Set:..canWrite pCommands($I(cmdIdx))=$LB("cmdOpen",$$$Text("Open"),$$$Text("Open this cube"),"zenPage.openCube();")
	Set:..canWrite pCommands($I(cmdIdx))=$LB("cmdRemove",$$$Text("Delete"),$$$Text("Delete this cube"),"zenPage.deleteCube();")
	
	Quit $$$OK
}

/// OCnvenience utility for setting the ribbon message
ClientMethod setRibbonMessage(message) [ Internal, Language = javascript ]
{
	if (message == undefined) {
		message='';
	}
	self.document.getElementById('ribbonMessage').innerHTML=message;
}

/// This client event is fired when a popup page launched from this page fires an action.
ClientMethod onPopupAction(popupName, action, value) [ Internal, Language = javascript ]
{
	switch(popupName) {
	case 'switchNamespace':
		var homeurl=zenLink("/csp/sys/%25CSP.Portal.Home.zen");
		var url=zenPage.GetNewURL(value,"AnalyzeThis.UI.CSVImport.zen");
		if (url == "" || value == "%SYS") url=homeurl;
		self.document.location=url;
		break;
	case 'CSVImport':
		if (action=="okay") {
			try {
				self.document.location=zenLink('AnalyzeThis.UI.CSVImport.cls');
			} catch(ex) {
			
			}
		}
		if (action=="dash") {
			try {
				self.document.location=zenLink('_DeepSee.UserPortal.DashboardViewer.zen?DASHBOARD=Generated/Samples%20for%20'+value+'.dashboard')	
			} catch(ex) {
			
			}
		}
		if (action=="score") {
			try {
				self.document.location=zenLink('_DeepSee.UserPortal.DashboardViewer.zen?DASHBOARD=Generated/Sample%20ScoreCard%20for%20'+value+'.dashboard')	
			} catch(ex) {
			
			}
		}

		break;
}
}

/// This is called in the middle of rendering the tool ribbon.
/// Subclasses can inject their own content into the ribbon by writing it out in this method.
/// This content is best wrapped within a single td element.
/// It can also consist of multiple td elements.
/// <p>
/// To achieve a fixed position for elements within the ribbon, for a fixed width page you can 
/// use a single enclosing td that contains a table and a single tr, 
/// with td elements inside that single tr that contain your content for the ribbon.
/// <p>
/// To achieve a fixed position for elements within the ribbon, 
/// for a page whose width varies depending on its contents (thereby stretching the ribbon)
/// you can use multiple td elements to contain your content and then a final
/// td element that is empty and has width 40% (or so) to push your contents towards the left
/// and keep them in their proper locations.
Method OnDrawRibbon() As %Status [ Internal ]
{
	&html<<td id="ribbonSpacer" width="5%"></td>>
	&html<<td id="ribbonMessage" style="color:red" width="20%"></td>>
	Quit $$$OK
}

/// Create a new cube.
ClientMethod newCube() [ Internal, Language = javascript ]
{
	if (this.pageModified) {
		if (!confirm($$$Text('There are unsaved changes, do you wish to continue?'))) {
			return;
		}
	}
	var parms={
			MODE:"models",
	};
	
	zenLaunchPopupWindow('AnalyzeThis.UI.Dialog.CSVImport.cls','CSVImport','status,resizable=yes,width=900,height=700',parms);
}

/// View info about cube.
ClientMethod showInfo(pCubeName) [ Language = javascript ]
{
	if (this.pageModified) {
		if (!confirm($$$Text('There are unsaved changes, do you wish to continue?'))) {
			return;
		}
	}
	var parms=new Object();
	parms.cubeName=pCubeName;
	
	zenPage.launchPopupWindow('AnalyzeThis.UI.Dialog.CSVImport.showInfo.cls','CSVImport','status,resizable=yes,width=900,height=700',parms);

	//d ##class(AnalyzeThis.UI.Dialog.CSVImport.showInfo).drawStats(pCubeName)
}

/// Refresh the specified cube.
ClientMethod refreshCube(cubeName) [ Language = javascript ]
{
	alert(this.Refresh(cubeName));
}

/// Trigger Refresh Cube Background Process
Method Refresh(pCubeName As %String) As %String [ ZenMethod ]
{
	Job ##class(AnalyzeThis.Utils).RefreshCube(pCubeName)
	Quit "Data refresh started for "_pCubeName_" started in background"
}

/// Create a new cube.
ClientMethod openCube() [ Language = javascript ]
{
	if (zenPage.getComponentById("table").getValue()!="") {
		if (this.pageModified) {
			if (!confirm($$$Text('There are unsaved changes, do you wish to continue?'))) {
				return;
			}
		}
		var parms={
				MODE:"models",
				CUBE:zenPage.getComponentById("table").getValue(),
		};
		
		zenLaunchPopupWindow('AnalyzeThis.UI.Dialog.CSVImportOpen.cls','CSVImportOpen','status,scrollbars,resizable=yes,width=900,height=700',parms);
	} else {
		alert("Please select a cube below");
	}
}

/// Delete the current cube.
ClientMethod deleteCube() [ Language = javascript ]
{
	if (zenPage.getComponentById("table").getValue()!="") {
		if (confirm($$$Text('Do you wish to remove all dashboards, pivot tables, cubes, and classes associated with '+zenPage.getComponentById("table").getValue()))) {
			zenPage.setRibbonMessage('Deleting '+zenPage.getComponentById("table").getValue()+'...');
			this.Delete(zenPage.getComponentById("table").getValue())
			try {
				self.document.location=zenLink('AnalyzeThis.UI.CSVImport.cls');
			} catch(ex) {
			
			}
		}
	}
}

/// Delete a cube.
Method Delete(pName As %String) As %String [ ZenMethod ]
{
	Set tMsg="Cube Deleted."
	
	Set tSC=##class(AnalyzeThis.Dashboard.Utils).DeleteAll(pName)
	If $$$ISERR(tSC) {
		Set tMsg=$System.Status.GetErrorText(tSC)
	}
	
	Quit tMsg
}

Query GetImportedCubes() As %Query(ROWSPEC = "CubeName,Analyzer,Architect,Dashboard,ScoreCard,Info,Application") [ SqlProc ]
{
}

ClassMethod GetImportedCubesExecute(ByRef qHandle As %Binary) As %Status
{
	Set tSC=$$$OK
	Kill ^||AnalyzeThis.CSVImportExecute
	Set CubeName=$o(^AnalyzeThis.ImportCSV(""))
	While CubeName'="" {
		Set dashName="Generated/Samples for "_CubeName_".dashboard"
		Set dash=##class(%DeepSee.Dashboard.Utils).%DashboardExists(dashName)
		Set scoreCardName="Generated/Sample ScoreCard for "_CubeName_".dashboard"
		Set scoreCard=##class(%DeepSee.Dashboard.Utils).%DashboardExists(scoreCardName)
		Set ^||AnalyzeThis.CSVImportExecute($i(count))=$lb(CubeName,"Analyzer","Architect",$case(dash, 0:"", 1:"Dashboard"),$case(scoreCard, 0:"", 1:"ScoreCard"),"Info",$system.CSP.GetPortalApp($NAMESPACE,$replace($this,"%","_")_".zen"),"info")
		Set CubeName=$o(^AnalyzeThis.ImportCSV(CubeName))
	}
    Set qHandle=$LB("")
    Quit tSC
}

ClassMethod GetImportedCubesFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status
{
	Set index=$list(qHandle,1)
	Set index=$o(^||AnalyzeThis.CSVImportExecute(index))
    If index="" {
        Set Row=""
        Set AtEnd=1
    } Else {
        Set Row=^||AnalyzeThis.CSVImportExecute(index)
    }
    Set qHandle=$LB(index)
    Quit $$$OK
}

ClassMethod GetImportedCubesClose(ByRef qHandle As %Binary) As %Status [ Internal, PlaceAfter = GetImportedCubesExecute ]
{
    Set qHandle=""
    Quit $$$OK
}

ClassMethod AddDetails(pCubeName As %String, pSourceType As %String, pSourceLocation As %String)
{
	Set ^AnalyzeThis.ImportCSV(pCubeName, ..#Version, pSourceType)=pSourceLocation
}

}
