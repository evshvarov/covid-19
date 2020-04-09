Class USA.City Extends Area
{

/// County
Relationship Region As Region(XMLPROJECTION = "XELEMENT", XMLREFERENCE = "ID") [ Cardinality = one, Inverse = Cities ];

/// 1 - capital of state or county, 0-ordinary city
Property SpecialIcon As %Boolean [ Required ];

Property Latitude As %Float [ Required ];

Property Longitude As %Float [ Required ];

Index RegionIdx On Region;

Storage Default
{
<Data name="CityDefaultData">
<Subscript>"City"</Subscript>
<Value name="1">
<Value>Region</Value>
</Value>
<Value name="2">
<Value>Latitude</Value>
</Value>
<Value name="3">
<Value>Longitude</Value>
</Value>
<Value name="4">
<Value>SpecialIcon</Value>
</Value>
</Data>
<DefaultData>CityDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}

