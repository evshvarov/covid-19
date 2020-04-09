/// Region, County, City
Class USA.Area Extends (%Persistent, %XML.Adaptor)
{

/// Name of state|county|city
Property Name As %String(MAXLEN = 500) [ Required ];

/// Guid for polygons in js file
Property Guid As %String [ Required ];

/// Link to Wiki article
Property DataUrl As %String(MAXLEN = 500);

/// All values
Relationship Parameters As ParameterValue [ Cardinality = many, Inverse = Area ];

Index GuidIdx On Guid [ IdKey, Unique ];

Storage Default
{
<Data name="AreaDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>DataUrl</Value>
</Value>
</Data>
<DataLocation>^USA.AreaD</DataLocation>
<DefaultData>AreaDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^USA.AreaD</IdLocation>
<IndexLocation>^USA.AreaI</IndexLocation>
<StreamLocation>^USA.AreaS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

