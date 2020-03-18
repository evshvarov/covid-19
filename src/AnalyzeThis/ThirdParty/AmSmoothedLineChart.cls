Class AnalyzeThis.ThirdParty.AmSmoothedLineChart Extends (AbstractAmChart, %DeepSee.Component.Portlet.abstractPortlet)
{

ClassMethod %OnGetPortletName() As %String
{
    Quit "AmCharts: Smoothed Line Chart"
}

ClassMethod %OnGetPortletIcon() As %String
{
    Quit "deepsee/ds_chart_line.png"
}

ClientMethod acquireData() [ Language = javascript ]
{
	// connect to controller
	var controller = this.getConnectedController();
	if (!controller) return;
	
	// are we connected to a pivot table?
	var isPivot = controller.getSelectedRange;
	if (!isPivot) {
		var labelDim = 2;
		var seriesSize = controller.getDimSize(1);
		var seriesCount = controller.getDimSize(2);
	} else {
		var labelDim = 1;
		var seriesSize = controller.getDimSize(2);
		var seriesCount = controller.getDimSize(1);
	}
	
	//For amcharts
	// populate props array
	var props = [];
	for(var yearVal=0;yearVal <  seriesCount;yearVal++) {
		//var propName = controller.getPropertyName(yearVal);
		var propName = controller.getLabel(yearVal,labelDim);
		if (!isPivot && propName.charAt(0) == '%') continue;  // KPI special columns
		props[yearVal] = {name: propName}
		props[yearVal].val=controller.getData(yearVal,0);
	}
	
	console.log(props);
	return props;
}

ClientMethod renderContents() [ Language = javascript ]
{
	//renderListingButton(this);
	this.renderSameParts(this);   
	var chart = new AmCharts.AmSerialChart();
    var chartData=this.acquireData();
    chart.pathToImages = "http://www.amcharts.com/lib/3/images/";
    chart.dataProvider = chartData;
    chart.marginLeft = 10;
    chart.categoryField = "name";
    //chart.dataDateFormat = "YYYY";
    
    // listen for "dataUpdated" event (fired when chart is inited) and call zoomChart method when it happens
    chart.addListener("dataUpdated", zoomChart);
    
    // AXES
    // category
    var categoryAxis = chart.categoryAxis;
    // categoryAxis.parseDates = true; // as our data is date-based, we set parseDates to true
    // categoryAxis.minPeriod = "YYYY"; // our data is yearly, so we set minPeriod to YYYY
    categoryAxis.dashLength = 3;
    categoryAxis.minorGridEnabled = true;
    categoryAxis.minorGridAlpha = 0.1;
    
    // value
    var valueAxis = new AmCharts.ValueAxis();
    valueAxis.axisAlpha = 0;
    valueAxis.inside = true;
    valueAxis.dashLength = 3;
    chart.addValueAxis(valueAxis);
    
    // GRAPH                
    graph = new AmCharts.AmGraph();
    graph.type = "smoothedLine"; // this line makes the graph smoothed line.
    graph.lineColor = "#d1655d";
    graph.negativeLineColor = "#637bb6"; // this line makes the graph to change color when it drops below 0
    //graph.bullet = "round";
    //graph.bulletSize = 8;
    //graph.bulletBorderColor = "#FFFFFF";
    //graph.bulletBorderAlpha = 1;
    //graph.bulletBorderThickness = 2;
    graph.lineThickness = 2;
    graph.valueField = "val";
    graph.balloonText = "[[value]]";
    chart.addGraph(graph);
    
    // CURSOR
    var chartCursor = new AmCharts.ChartCursor();
    chartCursor.cursorAlpha = 0;
    chartCursor.cursorPosition = "mouse";
    //chartCursor.categoryBalloonDateFormat = "YYYY";
    chart.addChartCursor(chartCursor);
    
    // SCROLLBAR
    var chartScrollbar = new AmCharts.ChartScrollbar();
    chart.addChartScrollbar(chartScrollbar);
    
    // WRITE
    chart.write("amchart"+this.index);
    this.chart=chart;
    //This part is for ONclick
    var temppivot = this.getConnectedController(); //need this @clickGraphItem event
    chart.addListener("zoomed",
    	function (event) {
    		console.log(event);
    		//event.item.dataContext.fill = 1;
    		//event.chart.validateData();
    		temppivot.selectCellRange(event.startIndex+1,0,event.endIndex+1,0);
    	}
    );
        
    //this method is called when chart is first inited as we listen for "dataUpdated" event
    function zoomChart() {
    	//  different zoom methods can be used - zoomToIndexes, zoomToDates, zoomToCategoryValues
    	chart.zoomToIndexes(0,100);
    }
}

}
