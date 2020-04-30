Class AnalyzeThis.GenerateImportCSV
{

// 1. Delete class AnalyzeThis.Generated.covid03162020 on the server

// 2 call Run method which will generated together with Import method

// 3. Export class AnalyzeThis.Generated.covid03162020 and copy-n-paste properties from repo from the same class

// 4. Use method Import to import the data from file

ClassMethod Run() As %Status
{
    s pfile="/irisdev/app/data/covid-03-16-2020.csv"
    s rowtype="ProvinceState VARCHAR(100),CountryRegion VARCHAR(100),LastUpdate DATE,Confirmed INTEGER,Deaths INTEGER,Recovered INTEGER,Latitude VARCHAR(50),Longitude VARCHAR(50)"
    s pclass="AnalyzeThis.Generated.covid03162020"
    do ##class(%SQL.Util.Procedures).CSVTOCLASS(, rowtype, pfile,",", ,1, pclass,,)
    q $$$OK
}

ClassMethod Import() As %Status
{
    s pfile="/irisdev/app/data/covid-03-23-2020.csv"
    s rc=0
    do ##class(AnalyzeThis.Generated.covid03162020).Import(,pfile,",", ,1, rc)
    w rc
    q $$$OK
}

}
