Class AnalyzeThis.ThirdParty.NVD3timeChart Extends (%DeepSee.Component.Portlet.abstractPortlet, %ZEN.Component.page)
{

Method %DrawHTML()
{
	Set namespace=$NAMESPACE
	Set username=$USERNAME
	Set password="SYS"
	Set mdx=..settings("MDX")
	
	&HTML<
	<html>
<head>
 <style type="text/css">
      body {
        padding-top: 43px;
      }
      .statement_para {
          font-size: 14pt;
          line-height: 120%;
          width: 60%;
          text-align: justify;
          text-justify: distribute;
          margin: 10px auto;
          margin-bottom: 30px;
      }

      .row {
	      margin: 1%;
        }

      article {
        padding: 0 1%;
        font-size: 18px;
        line-height: 1.5em;
      }

    </style>
<br />
</head>
<body width='100%'>
<div id='chart' style='width:100%; height:100%'>
  <svg style='height:100%; width:100%'/>
</div>
</body>
</html> 

<script src="http://d3js.org/d3.v3.min.js"></script>
<script src="novus-nvd3-b14dbe5/build/nv.d3.js" type="text/javascript"></script>
<script src="zenCSLM.js" type="text/javascript"></script>
<script src="DeepSee.js" type="text/javascript"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/nvd3/1.7.0/nv.d3.min.css">
<script type="text/javascript">
var username='#(username)#';
var password="";
var application="/api/deepsee/v1";
var namespace='#(namespace)#';
console.log(window.location.host);
var host="http://localhost:57772";
var mdx='#(mdx)#';
console.log(window.location.host);
var connection=new DeepSeeConnection(username,password,host,application,namespace);
console.log(window.location.host);
var resultSet=new DeepSeeResultSet(connection,'portlet');
resultSet.runMDXQuery(mdx,draw);

function draw(resultSet) {

console.log(resultSet);
var chartDataPoint=[];
var chartData=[];
var chartDataArray=[];
var colct=resultSet.getColumnCount();
var rowct=resultSet.getRowCount();
console.log(colct);
console.log(rowct);

for (var i=1; i <= rowct; ++i) {
	for (var j=1; j<=75; ++j) {
		chartDataPoint=[Date.parse(resultSet.getOrdinalLabel(1,j)), resultSet.getOrdinalValue(i,j)];
		chartDataArray[j-1]= chartDataPoint;
	}
	chartData[i-1]={"key":i,"values":chartDataArray};	
}
console.log(chartData);
var chartString=JSON.stringify(chartData);
sessionStorage.setItem("info", chartString);
var test=sessionStorage.getItem("info");

	
data=JSON.parse(chartString);
	console.log(data);
	nv.addGraph(function() {
		var chart=nv.models.stackedAreaChart()
		.margin({right: 100})
		.x(function(d) { return d[0] })   //We can modify the data accessor functions...
		.y(function(d) { return d[1] })   //...in case your data is formatted differently.
		.useInteractiveGuideline(true)    //Tooltips which show all data points. Very nice!
		.rightAlignYAxis(true)      //Let's move the y-axis to the right side.
		.showControls(true)       //Allow user to choose 'Stacked', 'Stream', 'Expanded' mode.
		
		.clipEdge(true);

    //Format x-axis labels with custom function.
    chart.xAxis
    .tickFormat(function(d) {
	    return d3.time.format('%x')(new Date(d)) 
    });
    
    chart.yAxis
    .tickFormat(d3.format(',.2f'));

	d3.select('#chart svg')
	.datum(data)
	.call(chart);

	nv.utils.windowResize(chart.update);
	return chart;
	});
}
</script> >
}

/// Return an optional array of "settings" values for this portlet.<br/>
/// The list of settings is displayed in the Widget Builder where the user can view and
/// edit them.
/// When the portlet is rendered, the values of all settings is made available to the
/// portlet's <method>%DrawHTML</method> method via the <property>settings</property>--a
/// multidimensional array subscripted by setting name.<br/>
/// On return, <var>pInfo</var> can contain a list of settings in the form:<br/>
/// pInfo(n) = $LB(name,value,type,caption,title)<br/>
/// <var>name</var> is the logical name of the setting.<br/>
/// <var>value</var> is the default value of the setting.<br/>
/// <var>type</var> indicates the type of the setting. This determines the control
/// displayed to get the value of the setting. If omitted the type is assumed to be a string.
/// The type can be: "%Integer", "%Boolean", or "ENUM^caption1:value1,caption2:value2".<br/>
/// <var>caption</var> is the localized caption of the setting.<br/>
/// <var>title</var> is an optional tooltip displayed for the setting.<br/>
/// Custom portlet settings can be controlled using the SETTINGS=PORTLET parameter in the 
/// dashboard URL  
ClassMethod %OnGetPortletSettings(Output pInfo As %List, ByRef pSettings) As %Status
{
	// DTB111 - add pSettings to make available for user callback
	Kill pInfo
	Set pInfo($I(pInfo))=$LB("MDX",$g(pSettings("MDX")),"","")
	Quit $$$OK
}

}
