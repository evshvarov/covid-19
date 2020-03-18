Class AnalyzeThis.ThirdParty.ListingInterface Extends %ZEN.Component.page
{

Parameter INCLUDEFILES;

ClassMethod DrawHTML()
{
	&html<
		<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.0/jquery.min.js"></script>
		<script type="text/javascript" src="http://www.trirand.net/js/trirand/jquery.jqGrid.min.js"></script>
		<script src="http://www.trirand.net/js/trirand/i18n/grid.locale-en.js"></script>
		
		<script type="text/javascript">
			//OnClick handler for listing button
			var lbClickHandler=function(self,target) {
				var cont = self.getConnectedController();
				var myindex = self.index;
				if ((!cont)||(!myindex)) return;
				var selR=cont.getSelectedRange();
				if (!selR) {
					alert("Select a cell before viewing a listing");
					return;
				}
				
				var isListing = !(jQuery("#listingButton"+myindex).attr("myparam")=="Graph");
				if (isListing) {
					jQuery("#listingButton"+myindex)[0].src="deepsee/ds2_binoculars_44.png";
					jQuery("#listingButton"+myindex).attr("myparam","Graph");
					jQuery('#wrapper'+myindex).hide();
					jQuery('#grid'+myindex).hide(1000);
					
					jQuery("#"+target+myindex).show();
					cont.fireOnUpdateEvent();
					zenPage.onAdjustSizes();
				} else {
					jQuery("#"+target+myindex).hide(1000);
					var curQuery=cont.GetCurrentQueryText();
					// var gridData=JSON.parse(#server(DeepSee.ListingInterface.GetListingSql(curQuery,selR.toString()))#);
					var gridData=JSON.parse(zenClassMethod(self,'GetListingSql','L,L','String',[curQuery,selR.toString()])); //(,"0,"+seriesCount+",0,"+seriesCount));
	
					/* 
					Saving in excel CSV format
					*/
					var saveAsExcel = function() {
						if (typeof(gridData) !== "undefined") {
							var arr =gridData;
							
							var csv = '';
							var i = 0;
							
							for (i=0;i<arr.length;i++) {
								var row = arr[i];
								var csv_row = [];
								for (var key in row) {
									var val = row[key].replace(";", ":");
									//BAD thing, take from locale
									var val = row[key].replace(".", ",");
									//console.log(val);
									csv_row.push(val);
								}
								csv += csv_row.join(";");
								
								if (i<arr.length-1) {
									csv +='\r\n';
								}
							}
							
							csv = encodeURIComponent(csv);
							
							var link = document.createElement("a");
							$(link).hide();
							link.setAttribute("href", "data:application/csv;charset=utf-8,"+csv);
							link.setAttribute("download", "my_data.csv");
							link.click();
						}
					}
					/*
					End : CSV EXPORT
					*/
					
					var colModel=[];
					var colNames=[];
					for (var key in gridData[0]) colModel.push({"name":key,"index":key});
					for (var key in gridData[0]) colNames.push(key);
					
					$("#grid"+myindex).GridUnload();
					$("#grid"+myindex).jqGrid({
						datatype: 'local'
						, pager:'#pager'+myindex
						, data:gridData
						, beforeSelectRow: function(){ return false; }
						, rownumbers: this.rownumbers // A new column at left of the grid is added. The purpose of this column is to count the number of available rows, beginning from 1.
						, viewrecords: this.viewrecords // jqGrid displays the beginning and ending record number in the grid
						, gridview: this.gridview
						, colNames: colNames
						, colModel: colModel
						//, rowNum: 20
						, gridComplete: function(){
							jQuery(".ui-jqgrid a").on("click",function(i){
								var win=window.open(i.currentTarget.href, '_blank');
								win.focus();
							});
						}
						, rowList:[10,20,30]
					});
					
					jQuery("#grid"+myindex).jqGrid('navGrid','#pager'+myindex,{edit:false,add:false,del:false,csv:true,position: 'left'});
					jQuery("#grid"+myindex).jqGrid('filterToolbar', {searchOnEnter:false});
					jQuery('#grid'+myindex).jqGrid('navButtonAdd','#pager'+myindex,{id:'pager_csv1',caption:'',title:'Export To CSV',onClickButton : saveAsExcel ,buttonicon:'ui-icon-document'}); 
		    
					jQuery('#wrapper'+myindex).show();
					jQuery('#grid'+myindex).show(1000);
					jQuery('#listingButton'+myindex)[0].src="deepsee/ds2_dialpad_44.png";
					jQuery("#listingButton"+myindex).attr("myparam","Listing");
					zenPage.onAdjustSizes();
				}
				return;
			}
			
			var renderListingButton =function(self, target) {
				var isPivot = self.getConnectedController().getSelectedRange;
			
				//Delete previous buttons
				jQuery("#listingButton"+self.index+", #listingTD"+self.index).remove();
				//Magical button adding to widget's header
				if(self.enableListing) {
					jQuery('*[id="'+self.getConnectedController().id.split("/")[0]+'"] .dswidgetHeader table.group tr').first().append('<td id="listingTD'+self.index+'" style="padding-right: 6px;vertical-align: bottom;"><img title="Show Listing" id="listingButton'+self.index+'" myparam="Graph" src="deepsee/ds2_binoculars_44.png"></img></td>');
				}
				
			  	//Initiallize onClick function for listing button
			  	var selfIndex=self.index;
			  	
			  	var contr=self.getConnectedController();
			   	jQuery("#listingButton"+self.index).click(function(){
			   		lbClickHandler(self,target);
			   	}); 
				if (!isPivot) jQuery("#listingButton"+self.index).css('opacity', 0.5).off("click");
			}
			
			var resizeGrid = function(self,width, height){
				jQuery("#grid"+self.index).setGridWidth(width - 4);
				jQuery("#grid"+self.index).setGridHeight(height - 1 - jQuery("#gbox_grid"+self.index).height() + jQuery("#gbox_grid"+self.index+" .ui-jqgrid-bdiv").height());
			}
		</script>
    >
}

ClassMethod GetListingSql(inMDX, inrange) [ ZenMethod ]
{
	Try {
		// Run the query that was last run in this KPI (this populated the table we are selecting from)
		//Set MDXDefault="SELECT NON EMPTY {[DateOfSale].[Actual].[YearSold].NOW, [DateOfSale].[Actual].[YearSold].[NOW-1]} ON 0,NON EMPTY [Product].[P1].[Product Name].Members ON 1 FROM [HoleFoods]"
		Set tMDX=inMDX
		
		// Create a resultset to get the table currently being displayed (this is guaranteed cached and so should be fast)
		Set tOrigRS=##class(%DeepSee.ResultSet).%ExecuteDirect(tMDX,,.tSC)
		
		// Now that we have a resultset, get the appropriate MDX filters that correspond to the selected cell(s)
		For ii=1:1:4 {
			Set range(ii)=$piece(inrange,",",ii)
		}
		Do tOrigRS.%GetFiltersForCellRange(.tFilters,range(1),range(2),range(3),range(4))
		
		// The listing is actually the result of a DRILLTHROUGH query, so we need to run another 
		// resultset that populates the <cube>.Listing table using the MDX drillthrough and provides
		// the correct SQL to read the results.
		// Start with the base (one-cell) query on the cube:
		Set tNewMDX="DRILLTHROUGH SELECT FROM "_tOrigRS.%CubeKey
		
		// Add the filters corresponding to the widget selection:
		Set idx=$order(tFilters(""))
		While idx'="" {
			Set tNewMDX=tNewMDX_" %FILTER "_tFilters(idx)
			Set idx=$order(tFilters(idx))
		}
		
		// Run the DRILLTHROUGH query built above to populate the listing table and create the needed SQL
		Set tDrillRS=##class(%DeepSee.ResultSet).%ExecuteDirect(tNewMDX)
		
		// Get the generic listing SQL of the source data for this subquery
		Set rsSQL=tDrillRS.%GetListingSQL()
		// The SQL returned just above selects all fields in the source table. 
	} Catch ex {
		// Store the error in the designated SQLError global.
		// The listing will still execute as the default listing.
	}
	
	// Return the new SQL
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tStatement.%SelectMode=2 //Display mode shows you all data in parsed way e.g. Date
	Set tStatus = tStatement.%Prepare(rsSQL)
	Set RS=tStatement.%Execute()
	Set colNum=tStatement.%Metadata.columns.Count()
	Set sc="" 
	Set ans="["
	Set sc=RS.%Next()
	Quit:sc=0
	For  {
		Set ans=ans_"{"
		
		For i=1:1:colNum {
			Set column=tStatement.%Metadata.columns.GetAt(i)
			Set ans=ans_""""_$zcvt(column.colName,"o","JS")_""":"_""""_$zcvt(RS.%GetData(i),"o","JS")_""""
			Set:i'=colNum ans=ans_","
		}
		Set ans=ans_"}"
		Set sc=RS.%Next() 
		If (sc=0) Quit
		Set ans=ans_","
	}
	Set ans=ans_"]"
	
	Quit ans
}

}
