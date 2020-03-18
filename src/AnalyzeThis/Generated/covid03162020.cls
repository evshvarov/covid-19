Class AnalyzeThis.Generated.covid03162020 Extends %Persistent [ Not ProcedureBlock ]
{

Parameter DEFAULTGLOBAL = "^AnalyzeThis.G.covid03162020";

Property Confirmed As %Integer [ SqlColumnNumber = 5 ];

Property CountryRegion As %String(MAXLEN = "") [ SqlColumnNumber = 3 ];

Property Deaths As %Integer [ SqlColumnNumber = 6 ];

Property LastUpdate As %Date [ SqlColumnNumber = 4 ];

Property Latitude As %String(MAXLEN = "") [ SqlColumnNumber = 8 ];

Property Longitude As %String(MAXLEN = "") [ SqlColumnNumber = 9 ];

Property ProvinceState As %String(MAXLEN = "") [ SqlColumnNumber = 2 ];

Property Recovered As %Integer [ SqlColumnNumber = 7 ];

Method LastUpdateSet(pVal) As %Status
{
 Try { Set pVal=+$zdth(pVal,3) }
 Catch ex {  }
 Set i%LastUpdate=pVal
 Quit $$$OK
}

Storage Default
{
<Data name="covid03162020DefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Confirmed</Value>
</Value>
<Value name="3">
<Value>CountryRegion</Value>
</Value>
<Value name="4">
<Value>Deaths</Value>
</Value>
<Value name="5">
<Value>LastUpdate</Value>
</Value>
<Value name="6">
<Value>Latitude</Value>
</Value>
<Value name="7">
<Value>Longitude</Value>
</Value>
<Value name="8">
<Value>ProvinceState</Value>
</Value>
<Value name="9">
<Value>Recovered</Value>
</Value>
</Data>
<DataLocation>^AnalyzeThis.G.covid03162020D</DataLocation>
<DefaultData>covid03162020DefaultData</DefaultData>
<IdLocation>^AnalyzeThis.G.covid03162020D</IdLocation>
<IndexLocation>^AnalyzeThis.G.covid03162020I</IndexLocation>
<StreamLocation>^AnalyzeThis.G.covid03162020S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
