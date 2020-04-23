/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// Example KPI definition using SQL statements against the HoleFoods transaction data.
Class Covid19.WorldKPI Extends %DeepSee.KPI
{

/// This XData definition defines the KPI.
XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi
xmlns="http://www.intersystems.com/deepsee/kpi"
 name="Covid19/World" sourceType="sql"
 sql="SELECT 
CountryRegion, Sum(Confirmed) as confirmed,  Sum(Deaths) as deaths, Sum(Recovered) as recovered FROM AnalyzeThis_Generated.covid03162020 Group by %EXACT(CountryRegion)"
 caption="KPI SQL">

<property name="CountryRegion" columnNo="1"/>
<property name="Confirmed" columnNo="2"/>
</kpi>
}

}
