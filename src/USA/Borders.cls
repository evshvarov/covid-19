/// Borders for polygons
Class USA.Borders Extends %Persistent
{

/// ParentRegion guid or string-'NULL' if level=0
Property ParentRegion As %String [ Required ];

/// Parameter
Property Parameter As USA.Parameter [ Required ];

/// Level
Property HLevel As %Integer [ Required ];

Property Minimum As %Integer;

Property Maximum As %Integer;

Index BordersIdx On (ParentRegion, Parameter, HLevel) [ Unique ];

/// Get a set of borders values for polygons whose parent GUID = parentRegionGuid
ClassMethod GetBorders(paramId As %String, hLevel As %Integer, parentRegionGuid As %String) As %String
{
	set borderMax = 10000
	set borderMin = 0
	set unitName = "-"

	if (parentRegionGuid="") set parentRegionGuid = "NULL"
	
	set border = ""
	
	try{
		if (..BordersIdxExists(parentRegionGuid, paramId, hLevel) = 1){
			set border = ..BordersIdxOpen(parentRegionGuid, paramId, hLevel)
		}
		else{
			set minVal=0, maxVal=10000
			
			if (parentRegionGuid = "NULL"){
				&sql(SELECT Min(Value), Max(Value) INTO :minVal,:maxVal
					 FROM USA.Region as reg INNER JOIN
					 USA.ParameterValue as pv ON reg.ID = pv.Area
					 WHERE reg.HLevel=:hLevel AND pv.Parameter=:paramId )
			}
			else{
				&sql(SELECT Min(Value), Max(Value) INTO :minVal,:maxVal
					 FROM USA.Region as reg INNER JOIN
					 USA.ParameterValue as pv ON reg.ID = pv.Area
					 WHERE reg.HLevel=:hLevel AND pv.Parameter=:paramId AND reg.ParentRegion=:parentRegionGuid)
			}
			 
			set border = ..%New()
			set border.ParentRegion = parentRegionGuid
			set border.Parameter = ##class(USA.Parameter).%OpenId(paramId)
			set border.HLevel = hLevel
			set border.Maximum = maxVal
			set border.Minimum = minVal
			do border.%Save()
		}
		
		set borderMin = border.Minimum
		set borderMax = border.Maximum
		set unitName = border.Parameter.UnitName
	}
	catch 
	{}
		
	quit borderMin_";"_borderMax_";"_unitName
}

/// Update values for border
ClassMethod SetBorders(paramId As %String, level As %Integer, parentRegionGuid As %String, min As %Integer, max As %Integer) As %Status
{
	set st = $$$OK
	try{
		if (parentRegionGuid="") set parentRegionGuid = "NULL"
		set brd = ..BordersIdxOpen(parentRegionGuid, paramId, level)
		set brd.Maximum = max
		set brd.Minimum = min
		set st = brd.%Save()
	}
	catch(ex){
		set st = ex.AsStatus()
	}
	quit st
}

Storage Default
{
<Data name="BordersDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ParentRegion</Value>
</Value>
<Value name="3">
<Value>Parameter</Value>
</Value>
<Value name="4">
<Value>HLevel</Value>
</Value>
<Value name="5">
<Value>Minimum</Value>
</Value>
<Value name="6">
<Value>Maximum</Value>
</Value>
</Data>
<DataLocation>^USA.BordersD</DataLocation>
<DefaultData>BordersDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^USA.BordersD</IdLocation>
<IndexLocation>^USA.BordersI</IndexLocation>
<StreamLocation>^USA.BordersS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
