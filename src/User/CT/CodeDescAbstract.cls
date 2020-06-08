Class User.CT.CodeDescAbstract Extends (%Persistent, %XML.Adaptor, %ZEN.DataModel.Adaptor) [ NoExtent ]
{

/// Activo
Property Active As %Boolean(ZENATTRS = "controlClass:PortalText|labelClass:PortalLabel|caption:", ZENLABEL = "Activo") [ InitialExpression = 1, Required ];

/// Código
Property Code As %String(ZENATTRS = "controlClass:PortalText|labelClass:PortalLabel|controlStyle:width:50px", ZENLABEL = "Código") [ Required ];

/// Descripción
Property Description As %String(MAXLEN = 250, ZENATTRS = "controlClass:PortalText|labelClass:PortalLabel|controlStyle:width:300px", ZENLABEL = "Descripción") [ Required ];

/// DEBE SER REDEFINIDO EN LA CLASE HIJA!!!!
Index CodeIndex On Code;

ClassMethod Create(pCode As %String, pDescription As %String, Output pNewObj As %Persistent) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
		Set pNewObj = ..%New()
		Set pNewObj.Code = pCode
		Set pNewObj.Description = pDescription
	}
	Catch (tException)
	{
		Set tSC = tException.AsStatus()
	}
	
	Quit tSC
}

ClassMethod OpenByCode(pCode As %String, pSC As %Status) As %Persistent [ CodeMode = objectgenerator ]
{
	Do %code.WriteLine(" Set tRS = ##class(%ResultSet).%New()")
	Do %code.WriteLine(" Set pSC=$System.Status.OK()")
	//Set tLen=$Length(%class.Name,".")
	//Set tTableName = $Translate($Piece(%class.Name,".",1,tLen-1),".","_")_"."_$Piece(%class.Name,".",tLen)
	Set tTableName = %compiledclass.SqlSchemaName_"."_%compiledclass.SqlTableName
	Do %code.WriteLine(" Set pSC = tRS.Prepare(""select %ID from "_tTableName_" where Code=?"")")
	Do %code.WriteLine(" Quit:$System.Status.IsError(pSC) """"")
	Do %code.WriteLine(" Set pSC = tRS.Execute(pCode)")
	Do %code.WriteLine(" Quit:$System.Status.IsError(pSC) """"")
	Do %code.WriteLine(" If tRS.Next() Quit ..%OpenId(tRS.GetData(1))")
	Do %code.WriteLine(" Quit """"")
	
	Quit $$$OK
}

ClassMethod OpenOrCreate(pCode As %String, pDescription As %String, pSC As %Status) As %Persistent
{
	Set pSC = $System.Status.OK()
	Set pObj = ""
	Try
	{
		Set pObj = ..OpenByCode(pCode, .pSC)
		Quit:$System.Status.IsError(pSC)
		
		If '$IsObject(pObj)
		{
			Set pObj = ..%New()
			Set pObj.Code=pCode
			Set pObj.Description=pDescription
			Set pObj.Active=1
			Set pSC = pObj.%Save(0)
		}
	}
	Catch (tException)
	{
		Set pSC = tException.AsStatus()
	}
	
	Quit pObj
}

}
