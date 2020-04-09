Class USA.Parameter Extends (%Persistent, %XML.Adaptor)
{

Property Name As %String [ Required ];

Property UnitName As %String;

Relationship Values As ParameterValue [ Cardinality = many, Inverse = Parameter ];

ClassMethod GetIdByName(name As %String) As %String
{
	set id=0
	&sql(SELECT ID INTO :id FROM USA.Parameter WHERE Name = :name)
	quit id
}

Storage Default
{
<Data name="ParameterDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>UnitName</Value>
</Value>
</Data>
<DataLocation>^USA.ParameterD</DataLocation>
<DefaultData>ParameterDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^USA.ParameterD</IdLocation>
<IndexLocation>^USA.ParameterI</IndexLocation>
<StreamLocation>^USA.ParameterS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

