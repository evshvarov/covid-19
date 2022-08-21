Class evshvarov.USA.Elections Extends %Persistent
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
<DataLocation>^evshvarov.USA.ElectionsD</DataLocation>
<DefaultData>ElectionsDefaultData</DefaultData>
<IdLocation>^evshvarov.USA.ElectionsD</IdLocation>
<IndexLocation>^evshvarov.USA.ElectionsI</IndexLocation>
<StreamLocation>^evshvarov.USA.ElectionsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
