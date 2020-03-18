/// Created using the page template: Default
Class AnalyzeThis.UI.Dialog.CSVImport.showInfo Extends %CSP.UI.Portal.Dialog.WizardTemplate [ System = 4 ]
{

Parameter DOMAIN = "AnalyzeThis";

Property CubeName As %String(ZENURL = "cubeName");

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">
#htmlContent {
	width: 100%;	
}
/* Progress message style */
.progress { 
	color: green; 
	font-weight: bold;
}
/* style for title instructions */
div.Description	{
	font-size: 0.9em; 
	padding: 5px;
}
table.page {
	table-layout:fixed;	
}
/* style for import content table */
table.ContentTable	{ 
	font-family: Arial, Helvetica, sans-serif;
	border: 1px #888888 solid;
}
table.ContentTable th { 
	font-size: 12px;
	font-weight: bold;		
	background:white; 
	color: #888888;
	text-align: center;
	padding: 0 2px 0 2px;
}
table.ContentTable tr.LiteRow { background: white; font-size: 11px;}
table.ContentTable tr.DarkRow { background: #F1F0E7; font-size: 11px;}
table.ContentTable td { padding-left:2px; padding-right:2px; font-size: 11px; }
</style>
}

XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" >
<html id="header" OnDrawContent="%DrawTitle" />
<pane paneName="dialogBody" id="body"/>
<hgroup id="footer" width="100%" cellAlign="right">
<hgroup id="buttonHolder" cellAlign="right">
<button id="btnCancel" controlClass="commandButton" caption="Close" onclick="zenPage.dialogCancel();" />
</hgroup>
</hgroup>
</page>
}

/// This XML block defines the contents of this pane.
XData dialogBody [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane id="body" cellStyle="padding-left:10px;">
<label id="idRespond" enclosingClass="note" containerStyle="padding-top:10px;padding-left:4px;" hidden="true"/>
<label id="test" value="#(%page.CubeName)#" enclosingStyle="font-size: 20px; font-weight: bold;"/>
<spacer height="5"/>
<html id="htmlContent4" OnDrawContent="GetImportInfo" seed="1"/>
<spacer height="5"/>
<expando id="nullStats" caption="Null Statistics" cellStyle="font-size: 16px; font-weight: normal" containerStyle="font-size: 18px; font-weight: bold" expanded="false" childIndent="35px" animate="true">
<html id="htmlContent" OnDrawContent="GetStats" seed="1"/>
</expando>
<expando id="pivotList" caption="List of Dependent Pivots" cellStyle="font-size: 16px; font-weight: normal" containerStyle="font-size: 18px; font-weight: bold" expanded="false" childIndent="35px" animate="true">
<html id="htmlContent2" OnDrawContent="GetPivotList" seed="1"/>
</expando>
<expando id="dashList" caption="List of Dependent Dashboards" cellStyle="font-size: 16px; font-weight: normal" containerStyle="font-size: 18px; font-weight: bold" expanded="false" childIndent="35px" animate="true">
<html id="htmlContent3" OnDrawContent="GetDashboardList" seed="1"/>
</expando>
<html id="statsTable"/>
</pane>
}

Method GetImportInfo(pSeed As %String) As %Status [ ZenMethod ]
{
	Set version=$o(^AnalyzeThis.ImportCSV(..CubeName,""))
	Set sourceType=$o(^AnalyzeThis.ImportCSV(..CubeName,version,""),1,source)
	&html<
		<font size='3' color='green'>
			<p>
				This Cube was created with AnalyzeThis version number: #(version)#
				<br/>Source Type is: #(sourceType)#
				<br/>Source is: #(source)#
			</p>
		</font>>
	Quit $$$OK
}

/// Return a list of all currently defined DeepSee Pivots visible to the current user.
/// This is used by utilities.<br/>
/// This list takes the form:<br/>
/// pList(index) = $LB(name)<br/>
/// If <var>pHidden</var> is true, then include trash and local items.<br/>
/// If <var>pCubeName</var> is provided, then only list pivots based on it.
Method GetPivotList(pSeed As %String) As %Status [ ZenMethod ]
{
	Set pHidden=0
	Set tSC=$$$OK
	Kill pList
	Try {
		Set i=1
		Set tFlag=$zu(115,8,0)
		Set tStatement=##class(%SQL.Statement).%New(,"DEFAULT_SCHEMA")
		Set tSC=tStatement.%Prepare("SELECT ID FROM %DeepSee_Dashboard.Pivot")
		If $$$ISERR(tSC) Quit
		
		Set pCubeName=$$$UPPER(..CubeName)
		Set html="<ul style='list-style-type:square'>"
		Set tRS=tStatement.%Execute()
		While (tRS.%Next(.tSC)) {
			If $$$ISERR(tSC) Quit
			If (tRS.ID '="") {
				Set tItem=##class(%DeepSee.UserLibrary.FolderItem).%OpenId(tRS.ID)
				If ($IsObject(tItem)) {			
					Set tFullName=$P(tItem.fullName,".",1) // name without extension
					If (pHidden || ($E(tFullName,1)'="$") || ($E(tFullName,1,3)="$$$")) {
						If ((pCubeName="")||(pCubeName=$$$UPPER(tItem.cubeName))) {
							If (tItem.%CheckResource()) {
								Set i=i+1
								Set tName=tItem.fullName
								Set tTitle=##class(AnalyzeThis.Dashboard.AutoPivot).ReformatName(tName)
								Set html=html_"<li>"_$piece(tTitle,"/",2)_"</li>"
							}
						}
					}
				}
			}
		}
		Set html="</ul><font size='3' color='green'><p>"_i_" Pivot Tables were made for this cube </p></font>"_html
	}
	Catch(ex) {
		Set tSC=ex.AsStatus()
	}
	Set tFlag=$zu(115,8,tFlag)
	&html<#(html)#>
	Quit tSC
}

Method GetDashboardList(pSeed As %String) As %Status [ ZenMethod ]
{
	Set tSC=$$$OK
	Set pCubeName=$$$UPPER(..CubeName)
	Set i=0
	Set html="<ul style='list-style-type:square'>"
	
	Set dashName="Sample ScoreCard for "_pCubeName
	Set dexist=##class(%DeepSee.Dashboard.Utils).%DashboardExists("Generated/"_dashName_".dashboard")
	If (dexist) {		
		Set html=html_"<li>"_dashName_"</li>"
		Set i=i+1
	}
	
	Set dashName="Samples for "_pCubeName
	Set dexist=##class(%DeepSee.Dashboard.Utils).%DashboardExists("Generated/"_dashName_".dashboard")
	If (dexist) {	
		Set html=html_"<li>"_dashName_"</li>"
		Set i=i+1
	}
	
	Set html="</ul><font size='3' color='green'><p>"_i_" Dashboards were made for this cube </p></font>"_html
	&html<#(html)#>
	Quit tSC
}

Method GetStats(pSeed As %String) As %Status [ ZenMethod ]
{
	Set st=$$$OK
	
	Set mdx="SELECT [Measures].[%COUNT] on 1 from ["_..CubeName_"]"
	Set rs=##class(%DeepSee.ResultSet).%ExecuteDirect(mdx)
	Set totalmembers=rs.%GetOrdinalValue(1)
	Set html="<font size='3' color='green'><p>"_totalmembers_" facts have been built for Cube "_..CubeName_"</p></font><table border=""1""><th>Level Name</th><th>Number of Members</th><th>Percentage of Null Values</th>"
	Set st=##class(%DeepSee.Utils).%GetDimensionList(..CubeName,.info)
	Set d=$order(info(""))
	while d'="" {
		Set h=$order(info(d,""))
		while h'="" {
			Set l=$order(info(d,h,""))
			while l'="" {
				If $lg(info(d,h,l),1)="l" {
					Set spec="["_$lg(info(d,h,l),2)_"].["_$lg(info(d,h,l),3)_"].["_$lg(info(d,h,l),4)_"]"
					Set mdx="SELECT COUNT("_spec_".Members) on 1 from ["_..CubeName_"]"
					Set rs=##class(%DeepSee.ResultSet).%ExecuteDirect(mdx)
					Set members=rs.%GetOrdinalValue(1)
					
					Set mdx="SELECT ISNULL("_spec_".&[<null>],0)/[Measures].[%COUNT] on 1 from ["_..CubeName_"]"
					Set rs=##class(%DeepSee.ResultSet).%ExecuteDirect(mdx)
					Set nullpercent=(((rs.%GetOrdinalValue(1)*10000)\1)/100)
					Set html=html_"<tr><td>"_spec_"</td><td>"_members_"</td><td>"_nullpercent_"%</td></tr>"
				}
				Set l=$order(info(d,h,l))
			}
			Set h=$order(info(d,h))
		}
		Set d=$order(info(d))
	}
	Set html=html_"</table>"
	
	&html<#(html)#>
	QUIT st
}

/// Get the (localized) title string for the dialog.
/// This should be implemented in a subclass.
Method %OnGetTitle() As %String [ Internal ]
{
	Quit $$$TextHTML("Cube Info")
}

/// Get the (localized) subtitle string for the dialog.
/// This should be implemented in a subclass.
Method %OnGetSubtitle() As %String [ Internal ]
{
	Quit ""
}

ClassMethod DrawPageTitle(pSeed As %String) As %Status [ Internal ]
{
	Set tPageTitle=$$$TextHTML("Cube Info")
	&html<<div class="Description">#(tPageTitle)#
	</div><hr size="1"/>>
	Quit $$$OK
}

}
