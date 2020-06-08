/// 
Class User.Cube.SleepRecordCube Extends %DeepSee.CubeDefinition [ DependsOn = User.SleepRecord, ProcedureBlock ]
{

/// Cube definition from Architect.
XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube xmlns="http://www.intersystems.com/deepsee" name="SleepRecord" displayName="SleepRecord" disabled="false" abstract="false" sourceClass="User.SleepRecord" countMeasureName="%COUNT" bucketSize="8" bitmapChunkInMemory="false" precompute="0" disableListingGroups="false">
  <dimension name="EventType" disabled="false" hasAll="false" allCaption="All EventType" allDisplayName="EventType" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="EventType" disabled="false" sourceProperty="EventType" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="RecordDate" disabled="false" hasAll="false" allCaption="All RecordDate" allDisplayName="RecordDate" sourceProperty="RecordDate" type="time" calendar="gregorian" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="RecordDateDay" disabled="false" timeFunction="DayMonthYear" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
    <hierarchy name="H2" disabled="false" hidden="false">
      <level name="RecordDateDayOfWeek" disabled="false" timeFunction="DayOfWeek" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="TimeFrom" disabled="false" hasAll="false" allCaption="All TimeFrom" allDisplayName="TimeFrom" sourceProperty="TimeFrom" type="time" calendar="gregorian" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="TimeFromHour" disabled="false" timeFunction="HourNumber" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="TimeFromMin" disabled="false" timeFunction="MinuteNumber" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <measure name="Length" disabled="false" sourceExpression="(%source.TimeTo-%source.TimeFrom)/60" aggregate="AVG" type="number" hidden="false" searchable="false">
  </measure>
</cube>
}

Parameter DOMAIN;

}
