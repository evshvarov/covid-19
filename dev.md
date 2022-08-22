# useful commands
## build container with no cache
```
docker-compose build --no-cache --progress=plain
```
## start container with iris
```
$ docker-compose up -d
```

## open terminal to docker
```
docker-compose exec iris iris session iris -U USER
```
## export IRIS Analytics artifacts
```
d ##class(dev.code).export("*.DFI")
```

## import countries
```
d ##class(community.csvgen).GenerateFromURL("https://raw.githubusercontent.com/datasciencedojo/datasets/master/WorldDBTables/CountryTable.csv",",","covid19.Countries")
```

## sql error handling
```
&sql()
if SQLCODE < 0 throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE,"Context")
```


AnalyzeThis.Generated.covid03162020
evshvarov.covid19.Snapshot