/// 
Class USA.BI.CovidCube Extends %DeepSee.CubeDefinition [ DependsOn = USA.Region, ProcedureBlock ]
{

/// Cube definition from Architect.
XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube xmlns="http://www.intersystems.com/deepsee" name="CovidCube" displayName="CovidCube" disabled="false" abstract="false" sourceClass="USA.Region" buildRestriction="hlevel=1" countMeasureName="%COUNT" bucketSize="8" bitmapChunkInMemory="false" precompute="0" disableListingGroups="false">
  <dimension name="Region" disabled="false" hasAll="false" allCaption="All Guid" allDisplayName="Guid" type="data" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="State" disabled="false" sourceProperty="ParentRegion" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
        <property name="Name" disabled="false" sourceProperty="ParentRegion.Name" hidden="false" isName="true" isDescription="false" isReference="false" useDisplayValue="false">
        </property>
        <property name="Color" disabled="false" sourceExpression="&quot;rgb(0,255,0)&quot;" hidden="false" isName="false" isDescription="false" isReference="false" useDisplayValue="false">
        </property>
        <property name="Population" disabled="false" sourceExpression="%cube.GetValue(%source.ParentRegion.Guid,1)" hidden="false" isName="false" isDescription="false" isReference="false" useDisplayValue="false">
        </property>
        <property name="Area" disabled="false" sourceExpression="%cube.GetValue(%source.ParentRegion.Guid,2)" hidden="false" isName="false" isDescription="false" isReference="false" useDisplayValue="false">
        </property>
        <property name="Density" disabled="false" sourceExpression="%cube.GetValue(%source.ParentRegion.Guid,3)" hidden="false" isName="false" isDescription="false" isReference="false" useDisplayValue="false">
        </property>
        <property name="Trump" disabled="false" sourceExpression="%cube.GetValue(%source.ParentRegion.Guid,4)" hidden="false" isName="false" isDescription="false" isReference="false" useDisplayValue="false">
          <additionalDescription>undefined</additionalDescription>
        </property>
        <property name="Clinton" disabled="false" sourceExpression="%cube.GetValue(%source.ParentRegion.Guid,5)" hidden="false" isName="false" isDescription="false" isReference="false" useDisplayValue="false">
          <additionalDescription>undefined</additionalDescription>
        </property>
        <property name="Confirmed" disabled="false" sourceExpression="%cube.GetValue(%source.ParentRegion.Guid,6)" hidden="false" isName="false" isDescription="false" isReference="false" useDisplayValue="false">
          <additionalDescription>undefined</additionalDescription>
        </property>
          <property name="Deaths" disabled="false" sourceExpression="%cube.GetValue(%source.ParentRegion.Guid,7)" hidden="false" isName="false" isDescription="false" isReference="false" useDisplayValue="false">
          <additionalDescription>undefined</additionalDescription>
        </property>
      
      </level>
      <level name="County" disabled="false" sourceProperty="Guid" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
        <property name="Name" disabled="false" sourceProperty="Name" hidden="false" isName="true" isDescription="false" isReference="false" useDisplayValue="false">
        </property>
        <property name="Population" disabled="false" sourceExpression="%cube.GetValue(%source.Guid,1)" hidden="false" isName="false" isDescription="false" isReference="false" useDisplayValue="false">
        </property>
        <property name="Area" disabled="false" sourceExpression="%cube.GetValue(%source.Guid,2)" hidden="false" isName="false" isDescription="false" isReference="false" useDisplayValue="false">
        </property>
        <property name="Density" disabled="false" sourceExpression="%cube.GetValue(%source.Guid,3)" hidden="false" isName="false" isDescription="false" isReference="false" useDisplayValue="false">
        </property>
        <property name="Trump" disabled="false" sourceExpression="%cube.GetValue(%source.Guid,4)" hidden="false" isName="false" isDescription="false" isReference="false" useDisplayValue="false">
          <additionalDescription>undefined</additionalDescription>
        </property>
        <property name="Clinton" disabled="false" sourceExpression="%cube.GetValue(%source.Guid,5)" hidden="false" isName="false" isDescription="false" isReference="false" useDisplayValue="false">
          <additionalDescription>undefined</additionalDescription>
        </property>
         <property name="Confirmed" disabled="false" sourceExpression="%cube.GetValue(%source.Guid,6)" hidden="false" isName="false" isDescription="false" isReference="false" useDisplayValue="false">
          <additionalDescription>undefined</additionalDescription>
        </property>
         <property name="Deaths" disabled="false" sourceExpression="%cube.GetValue(%source.Guid,7)" hidden="false" isName="false" isDescription="false" isReference="false" useDisplayValue="false">
          <additionalDescription>undefined</additionalDescription>
        </property>
        
      </level>
    </hierarchy>
  </dimension>
</cube>
}

ClassMethod GetColor(min, max, value) As %String
{
	if ('value) return "rgb(0,0,0)"

	// Крайние границы: красный и зеленый, цвет для середины - желтый
	set middle = (max + min) / 2

	if (value <= middle)
    {
        set redPart = (value - min) / (middle - min)
        return "rgb(" _ (255 * redPart\1) _ ",255, 0)"
    }
    else
    {
        set greenPart = (max - value) / (max - middle)
        return "rgb(255," _(255 * greenPart\1) _ ", 0)"
    }
}

ClassMethod GetValue(guid, type) As %Integer
{

	//b "L"
	//type=1 - population
	//type=2 - area
  	// type=4 - Trump
  	// type=5 - Clinton
	// density
	s region=##class(USA.Region).%OpenId(guid)
	if $IsObject(region) & type<4 {
	s parameter=##class(USA.ParameterValue).RegionParameterIndexOpen(region.Guid,type)
	if $IsObject(parameter) return parameter.Value}
  if (type=4)!(type=5) {
    set parameter=##class(USA.Elections).GuidIdxOpen(guid)
    if $IsObject(parameter) return $case(type,4:parameter.Trump,5:parameter.Clinton)
   }
   if type=6 {
      set parameter=##class(USA.Covid).GuidIdxOpen(guid)
    if $IsObject(parameter) return parameter.Confirmed
   }
   if type=7 {
      set parameter=##class(USA.Covid).GuidIdxOpen(guid)
    if $IsObject(parameter) return parameter.Deaths
   }
	return ""
}

ClassMethod TermListSetup()
{
 s ^DeepSee.TermList("USMAPSOURCES","caption")	=	"Map Sources"
 s ^DeepSee.TermList("USMAPSOURCES","data","Area","VALUE")	=	"USA/USMapArea.pivot"
 s ^DeepSee.TermList("USMAPSOURCES","data","Density","VALUE")	= "USA/USMapDensity.pivot"
 s ^DeepSee.TermList("USMAPSOURCES","data","Population","VALUE")	=	"USA/US Map Population.pivot"
 s ^DeepSee.TermList("USMAPSOURCES","modDate")	=	"2016-03-11 01:36:04"
 s ^DeepSee.TermList("USMAPSOURCES","name")	=	"USMapSources"
 s ^DeepSee.TermList("ELECTION VOTES","data","Votes Temperature","VALUE") = "USA/Elections.pivot"
 s ^DeepSee.TermList("ELECTION VOTES","data","Winner Takes All","VALUE")	=	"USA/Elections2.pivot"
 s ^DeepSee.TermList("ELECTION VOTES","modDate")	=	"2016-11-30 15:56:38"
 s ^DeepSee.TermList("ELECTION VOTES","name") =	"Election Votes"
 quit
}

Parameter DOMAIN;

}
