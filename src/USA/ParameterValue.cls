Class USA.ParameterValue Extends (%Persistent, %XML.Adaptor)
{

/// State, county or city
Relationship Area As Area(XMLPROJECTION = "XELEMENT", XMLREFERENCE = "ID") [ Cardinality = one, Inverse = Parameters ];

/// Parameter
Relationship Parameter As Parameter(XMLPROJECTION = "XELEMENT", XMLREFERENCE = "ID") [ Cardinality = one, Inverse = Values ];

/// Value for region|county|city
Property Value As %Float [ Required ];

Index PVIdx On (Area, Parameter);

Index RegionParameterIndex On (Area, Parameter) [ Unique ];

Storage Default
{
<Data name="ParameterValueDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Area</Value>
</Value>
<Value name="3">
<Value>Parameter</Value>
</Value>
<Value name="4">
<Value>Value</Value>
</Value>
</Data>
<DataLocation>^USA.ParameterValueD</DataLocation>
<DefaultData>ParameterValueDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^USA.ParameterValueD</IdLocation>
<IndexLocation>^USA.ParameterValueI</IndexLocation>
<StreamLocation>^USA.ParameterValueS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
