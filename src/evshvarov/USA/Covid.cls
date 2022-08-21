Class evshvarov.USA.Covid Extends %Persistent
{

Property RegionName As %String;

Property Guid As %String;

Property Confirmed As %Integer;

Property Deaths As %Integer;

Property Recovered As %Integer;

Index GuidIdx On Guid [ Unique ];

ClassMethod ImportData() As %Status
{
    d ..%KillExtent()
    &sql(
    insert into evshvarov_USA.Covid(RegionName, Guid, Confirmed, Deaths)
    select Name, Guid, Confirmed, Deaths from (SELECT 
ProvinceState as name, Null as ParentName, sum(Confirmed) as Confirmed, sum(Deaths) as Deaths, reg.Guid, Null as ParentRegion
FROM evshvarov_Covid19.Snapshot cov
LEFT OUTER JOIN evshvarov_USA.Region reg ON cov.ProvinceState = reg.Name AND reg.ParentRegion IS NULL
Where CountryRegion='United States of America'
group by ProvinceState

union

SELECT 
City as Name, state.Name as ParentName, Confirmed, Deaths, county.Guid, state.Guid as ParentRegion
FROM evshvarov_Covid19.Snapshot cov
LEFT OUTER JOIN (
SELECT 
ProvinceState as name, reg.Guid as guid
FROM evshvarov_Covid19.Snapshot cov2
LEFT OUTER JOIN evshvarov_USA.Region reg ON cov2.ProvinceState = reg.Name AND reg.ParentRegion IS NULL
Where CountryRegion='United States of America'
group by ProvinceState
) as state ON state.name =  cov.ProvinceState
LEFT OUTER JOIN evshvarov_USA.Region county ON cov.City = county.Name AND county.parentregion = state.guid
Where CountryRegion='United States of America' )
where guid is not NULL
Order by Name
)
    q $$$OK
}

ClassMethod GrantSQLAccess() As %Status
{
     &sql(GRANT SELECT,UPDATE ON evshvarov_Covid19.Snapshot TO UnknownUser)
     q $$$OK
}

Storage Default
{
<Data name="CovidDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RegionName</Value>
</Value>
<Value name="3">
<Value>Guid</Value>
</Value>
<Value name="4">
<Value>Confirmed</Value>
</Value>
<Value name="5">
<Value>Deaths</Value>
</Value>
<Value name="6">
<Value>Recovered</Value>
</Value>
</Data>
<DataLocation>^evshvarov.USA.CovidD</DataLocation>
<DefaultData>CovidDefaultData</DefaultData>
<IdLocation>^evshvarov.USA.CovidD</IdLocation>
<IndexLocation>^evshvarov.USA.CovidI</IndexLocation>
<StreamLocation>^evshvarov.USA.CovidS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
