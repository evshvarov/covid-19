Class USA.Elections Extends %Persistent
{

Property RegionName As %String;

Property Guid As %String;

Property Trump As %Integer;

Property Clinton As %Integer;

Index GuidIdx On Guid [ Unique ];

Storage Default
{
<Data name="ElectionsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RegionName</Value>
</Value>
<Value name="3">
<Value>Guid</Value>
</Value>
<Value name="7">
<Value>Trump</Value>
</Value>
<Value name="8">
<Value>Clinton</Value>
</Value>
</Data>
<DataLocation>^USA.ElectionsD</DataLocation>
<DefaultData>ElectionsDefaultData</DefaultData>
<IdLocation>^USA.ElectionsD</IdLocation>
<IndexLocation>^USA.ElectionsI</IndexLocation>
<StreamLocation>^USA.ElectionsS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
