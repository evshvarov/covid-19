# Covid-19 analytics
This is an [interactive dashboard](http://35.241.213.177:52773/dsw/index.html#!/d/Covid19/Countries.dashboard?ns=IRISAPP) on the analytics for covid-19 pandemia.
## data source
The data is taken from [John Hopkins repo](https://github.com/CSSEGISandData/COVID-19)

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
$ git clone git@github.com:intersystems-community/objectscript-contest-template.git
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
Creating objectscript-contest-template_iris_1 ... done
```

Click on the ObjectScript status bar and select Refresh connection in the menu.
Wait for VSCode to make connection and show something like "localhost:32778[IRISAPP] - Connected"

You can start coding after that. 

Contributions are welcome via Pull Requests
