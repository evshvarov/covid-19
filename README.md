# Covid-19 analytics
This is an [interactive dashboard](http://34.77.54.254:52773/dsw/index.html#/IRISAPP/Covid19/Countries.dashboard    ) on the analytics for covid-19 pandemia.
![alt text](https://user-images.githubusercontent.com/2781759/93055568-d8f79e80-f673-11ea-9b29-36d286356376.png "Dashboard1")

Another dashboard [shows the timeline](http://34.77.54.254:52773/dsw/index.html#/IRISAPP/Covid19/Daily.dashboard):
<img width="1436" alt="Screenshot 2020-09-18 at 10 59 13" src="https://user-images.githubusercontent.com/2781759/93572101-0909af00-f99e-11ea-8cdb-19a47baffcab.png">

There is also [USA Interactive map](http://34.77.54.254:52773/dsw/index.html#/IRISAPP/Covid19/USA.dashboard)
<img width="1197" alt="Screenshot 2020-09-18 at 11 01 16" src="https://user-images.githubusercontent.com/2781759/93572277-4cfcb400-f99e-11ea-9a85-1e245b8b2c39.png">

And the [World Map](http://34.77.54.254:52773/dsw/index.html#/IRISAPP/Covid19/Worldmap.dashboard)
<img width="1429" alt="Screenshot 2020-09-18 at 11 03 15" src="https://user-images.githubusercontent.com/2781759/93572503-9b11b780-f99e-11ea-8f2e-5e56c1e973d2.png">

Also the [bubble chart of top 10 countries](http://34.77.54.254:52773/dsw/index.html#/IRISAPP/Covid19/bubble%20chart.dashboard)
<img width="1198" alt="Screenshot 2020-09-18 at 11 05 28" src="https://user-images.githubusercontent.com/2781759/93572744-f2178c80-f99e-11ea-93e2-6eda2e31d212.png">


## data source
The data is taken from [Johns Hopkins repo](https://github.com/CSSEGISandData/COVID-19)

## How it works
The dashboard is running on InterSystems IRIS 2019.4 Community Edition
It uses IRIS Analytics module and DSW as a representation layer
It runs in a Kubernetes cluster in GCP

## How it was developed
[AnalyzeThis](https://openexchange.intersystems.com/package/AnalyzeThis) module has been used to generate the class and the cube.
Pivots and Dashboards were built manually using [InterSystems IRIS Analytics](https://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=D2GS)
[DSW](https://openexchange.intersystems.com/package/DeepSeeWeb) is used to design representation layer
[ISC-DEV](https://openexchange.intersystems.com/package/ISC-DEV) module was used to export pivot and dashboard.

To export Pivot and Dashboard changes do:
```
IRISAPP> do ##class(dev.code).export("*.DFI")
```
This will export pivots and dashboards into /src/dfi folder of the repo.

## deployment
It's being deployed by Github Actions using this workflow
Which uses terraform and K8 configuration.
Dockerfile loads sources, pivot and dashboard. It imports data and builds cube.

## Installation 

Open terminal and clone/git pull the repo into any local directory

```
$ git clone git@github.com:evshvarov/covid-19.git
```

Open the terminal in this directory and run:

```
$ docker-compose build
```


## How to start coding
This repository is ready to code in VSCode with ObjectScript plugin.
Install [VSCode](https://code.visualstudio.com/), [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) and [ObjectScript](https://marketplace.visualstudio.com/items?itemName=daimor.vscode-objectscript) plugins and open the folder in VSCode.

Right-click on **docker-compose.yml** file and click Compose Restart

Once docker will finish starting procedure and show:

```
Creating covid-19_iris_1 ... done
```

Click on the ObjectScript status bar and select Refresh connection in the menu.
Wait for VSCode to make connection and show something like "localhost:32778[IRISAPP] - Connected"

You can start coding after that. 

Contributions are welcome via Pull Requests
