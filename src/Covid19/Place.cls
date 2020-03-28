Class Covid19.Place Extends %Persistent
{

Property CountryRegion As %String(MAXLEN = "");

Property Latitude As %String(MAXLEN = "");

Property Longitude As %String(MAXLEN = "");

Property ProvinceState As %String(MAXLEN = "");

Storage Default
{
<Data name="PlaceDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>CountryRegion</Value>
</Value>
<Value name="3">
<Value>Latitude</Value>
</Value>
<Value name="4">
<Value>Longitude</Value>
</Value>
<Value name="5">
<Value>ProvinceState</Value>
</Value>
</Data>
<DataLocation>^Covid19.PlaceD</DataLocation>
<DefaultData>PlaceDefaultData</DefaultData>
<IdLocation>^Covid19.PlaceD</IdLocation>
<IndexLocation>^Covid19.PlaceI</IndexLocation>
<StreamLocation>^Covid19.PlaceS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
