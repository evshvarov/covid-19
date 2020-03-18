Class AnalyzeThis.Dashboard.MetaDataAnalyze Extends %DeepSee.Utils
{

ClassMethod EvaluateCube(pCube As %String) As %Status
{
	Set tSC=$$$OK
	Try {
		If (pCube="") {
			Quit
		}
		Set tCube=$$$UPPER(pCube)
		Set tFactClass=$$$UPPER(..%GetCubeFactClass(tCube))
		If (tFactClass="") {
			Quit
		}
		
		//Delete Existing MetaData for the Cube
		Do ##class(AnalyzeThis.Dashboard.MetaData).Delete(tCube)
		
		Set tSC=..%GetCubeLevels(tCube,.tLevels,1,1)
		If $$$ISERR(tSC) Quit

		Set tFactCount=..%GetCubeFactCount(tCube)

		If (tFactCount>0) {
			Set n=$O(tLevels(""))
			While (n'="") {
				Kill tMeta
				Set tMeta=##class(AnalyzeThis.Dashboard.MetaData).%New()
				Set tMeta.CubeName=tCube
				Set tMDXnull="", tMDXavg="", tMDXstd=""
				Set tSpec=""
				Set tWord=0
				Set tGender=0
				Set ttName=$$$UPPER($LG(tLevels(n),3))
				
				Set tType=$LG(tLevels(n),1)
				
				//Dimensions
				If (tType="l") {
					Set tSpec="["_$LG(tLevels(n),2)_"].["_$LG(tLevels(n),3)_"].["_$LG(tLevels(n),4)_"]"
					Set tMDXnull="SELECT "_tSpec_".&[<null>] ON ROWS FROM ["_tCube_"]"
					
					Set ttName=$$$UPPER($LG(tLevels(n),4))

					//Word Recognition
					If (ttName["MEASURE") {
						Set tWord=1
					}
					
					If ((ttName["SEX")||(ttName["GENDER")) {
						Set tWord=tWord+1
						Set tMeta.DataType="Gender"
					}
					
					If (ttName["STATE") {
						Set tWord=tWord+1
						Set tMeta.DataType="State"
					}
				}
				//Measures
				ElseIf (tType="m") {
					If ($LG(tLevels(n),3)'="%COUNT") {
						Set tSpec="["_$LG(tLevels(n),2)_"].["_$LG(tLevels(n),3)_"]"
						Set tMDXnull="SELECT FROM ["_tCube_"] WHERE %SEARCH.&["_tSpec_" IS NULL]"		
						Set tMDXavg="SELECT "_tSpec_".AVG ON 0 FROM ["_tCube_"]"
						Do ##class(%DeepSee.Utils).%GetDimensionInfo(tCube,tSpec,.tDim,.tHier,.tLevel)
						Do ##class(%DeepSee.Utils).%GetDimensionFact(tCube,tDim,tHier,tLevel,.sqlname)
						Set tablename=##class(%DeepSee.Utils).%GetCubeFactTable(tCube)
						
						Kill sql, statement,st,rs
						Set sql="SELECT STDDEV("_sqlname_") As SD,MAX("_sqlname_") As MX ,MIN("_sqlname_") As MN FROM "_tablename
						Set statement=##class(%SQL.Statement).%New()
						Set st=statement.%Prepare(sql)
						If (st) {
							Set rs=statement.%Execute()
							While (rs.%Next()'=0) {
								Set tMeta.STDDEV=rs.%Get("SD")
								Set tMeta.Maximum=rs.%Get("MX")
								Set tMeta.Minimum=rs.%Get("MN")
							}
						}
						
						Set ttName=$$$UPPER($LG(tLevels(n),3))
						//Word Recognition
						If (ttName["SCORE") {
							Set tWord=1
						}
						If (ttName["AVERAGE") {
							Set tWord=tWord+1
						}
						If (ttName["TOTAL") {
							Set tWord=tWord+1
						}
						If (ttName["REVENUE") {
							Set tWord=tWord+1
						}
					}
				}
				//Relations
				ElseIf (tType="r") {
					// find null ref for relation
					Set tRelation=$LG(tLevels(n),2)
					Set tNullRef=$G($$$DeepSeeMetaGLVN("cubes",tCube,"relations",$$$UPPER(tRelation),"nullReplacement"))
					If (tNullRef'="") {
						Set tSpec="["_tRelation_"]"
						Set tMDXnull="SELECT FROM ["_tCube_"] WHERE "_tSpec_".&["_tNullRef_"]"
					}
				}
				
				//Get Cardinality
				Set tCard=0
				If tSpec'="" {
					Do ##class(%DeepSee.Utils).%GetDimensionInfo(tCube,tSpec,.tDim,.tHier,.tLevel)
					If tDim=0 {
						Set tIndex=$G($$$DeepSeeMetaGLVN("cubes",tCube,"msr#",$LG($$$DeepSeeMetaGLVN("cubes",tCube,"mbr#",tDim,tHier,tLevel),5)))_"Search"
					} Else {
						Set tIndex=$LG($$$DeepSeeMetaGLVN("cubes",tCube,"mbr#",tDim,tHier,tLevel),5)
					}
					
					Set tValue=$O($$$DeepSeeIndexGLVN(tCube,tIndex,""))
					While (tValue '="") {
						Set tCard=tCard + 1
						Set tValue=$O($$$DeepSeeIndexGLVN(tCube,tIndex,tValue))
					}
					Set tMeta.Cardinality=tCard
				}
				
				//Execute
				Set tMeta.LevelName=$Case(tType, "l":$LG(tLevels(n),4),"m":$LG(tLevels(n),3),:tSpec)
				Set tMeta.DimName=$LG(tLevels(n),2)
				Set tMeta.LevelType=$Case(tType,"l":"Dimension","m":"Measure","r":"Relation",:tType)
				Set tMeta.WordRecognition=tWord
				Set listVals=$lb(tMDXnull,tMDXavg,tMDXstd)
				For i=1:1:$listlength(listVals) {
					Set tMDX=$listget(listVals,i)
					If tMDX'="" {
						Set tRS=##class(%DeepSee.ResultSet).%New()
						Set tSC=tRS.%PrepareMDX(tMDX)
						If $$$ISERR(tSC) Quit
						Set tSC=tRS.%Execute()
						If $$$ISERR(tSC) Quit
						Set tVal=tRS.%GetOrdinalValue()
						If i=1 {
							Set tMeta.Null=(tVal/tFactCount)
						} ElseIf i=2 {
							Set tMeta.Mean=tVal
						} ElseIf i=3 {
							Set tMeta.STDDEV=tVal
						}
					}
				}
				
				Set tSC=tMeta.%Save()
				If $$$ISERR(tSC) Quit
				
				Set n=$O(tLevels(n))	
			}
		}
		
		Set namespace=$NAMESPACE
		Set tCubeClass=##class(%DeepSee.Utils).%GetCubeClass(tCube)
		Set tSC=$zobjclassmethod(tCubeClass,"%GetSourceInfo",.tSourceInfo)
		Set tSourceClass=tSourceInfo("sourceClass")
		Set class=##class(%Dictionary.ClassDefinition).%OpenId(tSourceClass,,.st)
	
		If (st) {
			For i=1:1:class.Properties.Count() {
				Set prop=class.Properties.GetAt(i)
				Set tType=prop.Type
				If (tType="%Library.Date") {
					Kill propName,sql,statement,st,rs
					Set propName="%"_prop.Name_"%"
					Set sql="UPDATE AnalyzeThis_Dashboard.MetaData (DataType) VALUES ('Date') WHERE LevelName LIKE ?"
					Set statement=##class(%SQL.Statement).%New("deffered")
					Set st=statement.%Prepare(sql)
					If (st) {
						Set rs=statement.%Execute(propName)
					}
				}
				If (($$$UPPER(prop.Name)[$$$UPPER("year"))&&(tType'="%Library.Date")) {
					Kill propName,sql,statement,st,rs
					Set propName="%"_prop.Name_"%"
					Set sql="UPDATE AnalyzeThis_Dashboard.MetaData (DataType) VALUES ('Year') WHERE LevelName LIKE ?"
					Set statement=##class(%SQL.Statement).%New("deffered")
					Set st=statement.%Prepare(sql)
					If (st) {
						Set rs=statement.%Execute(propName)
					}
				}
			}
		}
	} Catch(ex) {
		Set tSC=ex.AsStatus()
	}
	
	If $$$ISERR(tSC) {
		Do $System.Status.DisplayError(tSC)
	}

	Quit tSC
}

}
