Class AnalyzeThis.Dashboard.MetaData Extends (%Persistent, %DeepSee.Utils)
{

Property CubeName As %String(MAXLEN = 500, TRUNCATE = 0) [ Required ];

Property DimName As %String;

Property LevelName As %String [ Required ];

Property Cardinality As %Integer;

Property DataType As %String;

Property LevelType As %String(VALUELIST = "-Measure-Dimension-Relation") [ Required ];

Property STDDEV As %Decimal;

Property Mean As %Decimal;

Property WordRecognition As %Integer;

Property Null As %Decimal;

Property Maximum As %Decimal;

Property Minimum As %Decimal;

/// Delete method using embedded SQL
ClassMethod Delete(pCubeName As %String) As %Status
{
 Set exist=""
 &sql(SELECT %ID INTO :exist FROM AnalyzeThis_Dashboard.MetaData WHERE (CubeName=:pCubeName))
 If ((SQLCODE = 0)&&(exist'="")) {
	&sql(DELETE FROM AnalyzeThis_Dashboard.MetaData WHERE (CubeName=:pCubeName))
 }
 
 Quit $$$OK
}

Storage Default
{
<Data name="MetaDataDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>CubeName</Value>
</Value>
<Value name="3">
<Value>DimName</Value>
</Value>
<Value name="4">
<Value>LevelName</Value>
</Value>
<Value name="5">
<Value>Cardinality</Value>
</Value>
<Value name="6">
<Value>DataType</Value>
</Value>
<Value name="7">
<Value>LevelType</Value>
</Value>
<Value name="8">
<Value>STDDEV</Value>
</Value>
<Value name="9">
<Value>Mean</Value>
</Value>
<Value name="10">
<Value>WordRecognition</Value>
</Value>
<Value name="11">
<Value>Null</Value>
</Value>
<Value name="12">
<Value>Maximum</Value>
</Value>
<Value name="13">
<Value>Minimum</Value>
</Value>
</Data>
<DataLocation>^AnalyzeThis.Dashboard.MetaDataD</DataLocation>
<DefaultData>MetaDataDefaultData</DefaultData>
<IdLocation>^AnalyzeThis.Dashboard.MetaDataD</IdLocation>
<IndexLocation>^AnalyzeThis.Dashboard.MetaDataI</IndexLocation>
<StreamLocation>^AnalyzeThis.Dashboard.MetaDataS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
