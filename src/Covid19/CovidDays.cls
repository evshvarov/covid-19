/// 
Class Covid19.CovidDays Extends %DeepSee.CubeDefinition [ DependsOn = Covid19.Day, ProcedureBlock ]
{

/// Cube definition from Architect.
XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube xmlns="http://www.intersystems.com/deepsee" name="CovidDays" displayName="CovidDays" disabled="false" abstract="false" sourceClass="Covid19.Day" countMeasureName="%COUNT" bucketSize="8" bitmapChunkInMemory="false" precompute="0" disableListingGroups="false" enableSqlRestrict="false">
  <dimension name="Day" disabled="false" hasAll="true" allCaption="All Time" allDisplayName="All Time" sourceProperty="Day" type="time" calendar="gregorian" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="Month" disabled="false" timeFunction="MonthYear" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="Day" disabled="false" timeFunction="DayMonthYear" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="CountryRegion" disabled="false" hasAll="false" allCaption="All CountryRegion" allDisplayName="CountryRegion" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="CountryRegion" disabled="false" sourceProperty="Place.CountryRegion" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="ProvinceState" disabled="false" hasAll="false" allCaption="All ProvinceState" allDisplayName="ProvinceState" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="ProvinceState" disabled="false" sourceProperty="Place.ProvinceState" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <measure name="ConfirmedNew" disabled="false" sourceProperty="ConfirmedNew" aggregate="SUM" type="integer" hidden="false" searchable="false" formatString="#,#;;;;">
  </measure>
  <measure name="DeathsNew" disabled="false" sourceProperty="DeathsNew" aggregate="SUM" type="integer" hidden="false" searchable="false" formatString="#,###">
  </measure>
  <listing name="New_listing1" disabled="false" listingType="table" fieldList="ConfirmedNew,Day,Place-&gt;CountryRegion,Place-&gt;ProvinceState">
  </listing>
</cube>
}

Parameter DOMAIN;

}
