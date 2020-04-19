SELECT 
ID, ProvinceState, sum(Confirmed), sum(Deaths), sum(Recovered)
FROM AnalyzeThis_Generated.covid03162020
LEFT OUTER JOIN 
Where CountryRegion='US'
group by ProvinceState


SELECT 
ProvinceState, sum(Confirmed), sum(Deaths), reg.Guid
FROM AnalyzeThis_Generated.covid03162020 cov
LEFT OUTER JOIN USA.Region reg ON cov.ProvinceState = reg.Name
Where CountryRegion='US'
group by ProvinceState


select * from (SELECT 
ProvinceState as name, Null as ParentName, sum(Confirmed) as Confirmed, sum(Deaths) as Deaths, reg.Guid, Null as ParentRegion
FROM AnalyzeThis_Generated.covid03162020 cov
LEFT OUTER JOIN USA.Region reg ON cov.ProvinceState = reg.Name
Where CountryRegion='US'
group by ProvinceState

union

SELECT 
City as Name, state.Name as ParentName, Confirmed, Deaths, county.Guid, state.Guid as ParentRegion
FROM AnalyzeThis_Generated.covid03162020 cov
LEFT OUTER JOIN (
SELECT 
ProvinceState as name, reg.Guid as guid
FROM AnalyzeThis_Generated.covid03162020 cov2
LEFT OUTER JOIN USA.Region reg ON cov2.ProvinceState = reg.Name
Where CountryRegion='US'
group by ProvinceState
) as state ON state.name =  cov.ProvinceState
LEFT OUTER JOIN USA.Region county ON cov.City = county.Name AND county.parentregion = state.guid
Where CountryRegion='US' )
where guid is not NULL
order by Name



WASHINGTON	 	296832	13632	027FBB6F-512F-48E7-9BB9-0BEFA254DD22	 	2
DELAWARE	 	7812	133	067D221C-A573-4BFF-847C-C922DE4239E0	 	2
TEXAS	 	29331	567	116DFADF-40D7-46D6-9E07-820AC8BA98AB	 	2
INDIANA	 	11886	406	65A5D506-92CE-4DB2-9CC1-29AF8ADC9F26	 	2
NEVADA	 	6777	216	799963A3-40AA-4E90-B739-F1282206FBFA	 	2
OREGON


select * from (SELECT 
ProvinceState as name, Null as ParentName, sum(Confirmed) as Confirmed, sum(Deaths) as Deaths, reg.Guid, Null as ParentRegion
FROM AnalyzeThis_Generated.covid03162020 cov
LEFT OUTER JOIN USA.Region reg ON cov.ProvinceState = reg.Name AND reg.ParentRegion IS NULL
Where CountryRegion='US'
group by ProvinceState

union

SELECT 
City as Name, state.Name as ParentName, Confirmed, Deaths, county.Guid, state.Guid as ParentRegion
FROM AnalyzeThis_Generated.covid03162020 cov
LEFT OUTER JOIN (
SELECT 
ProvinceState as name, reg.Guid as guid
FROM AnalyzeThis_Generated.covid03162020 cov2
LEFT OUTER JOIN USA.Region reg ON cov2.ProvinceState = reg.Name AND reg.ParentRegion IS NULL
Where CountryRegion='US'
group by ProvinceState
) as state ON state.name =  cov.ProvinceState
LEFT OUTER JOIN USA.Region county ON cov.City = county.Name AND county.parentregion = state.guid
Where CountryRegion='US' )
where guid is not NULL



