# Covid-19 analytics
Try with https://covid-19.demo.community.intersystems.com/dsw/index.html#!/USER
This is an [interactive dashboard](https://covid-19.demo.community.intersystems.com/dsw/index.html#!/USER/Covid19/Countries.dashboard    ) on the analytics for covid-19 pandemia.
<img width="1420" alt="Screenshot 2020-09-29 at 14 02 39" src="https://user-images.githubusercontent.com/2781759/94550638-bad99300-025c-11eb-8cd5-83a22266c991.png">
Another dashboard [shows the timeline](https://covid-19.demo.community.intersystems.com/dsw/index.html#!/USER/Covid19/Daily.dashboard):
<img width="1436" alt="Screenshot 2020-09-18 at 10 59 13" src="https://user-images.githubusercontent.com/2781759/93572101-0909af00-f99e-11ea-8cdb-19a47baffcab.png">

There is also [USA Interactive map](https://covid-19.demo.community.intersystems.com/dsw/index.html#!/USER/Covid19/USA.dashboard)
<img width="1419" alt="Screenshot 2020-09-29 at 14 05 59" src="https://user-images.githubusercontent.com/2781759/94550750-f07e7c00-025c-11eb-8531-cbd48928a525.png">

And the [World Map](https://covid-19.demo.community.intersystems.com/dsw/index.html#!/USER/Covid19/Worldmap.dashboard)
<img width="1426" alt="Screenshot 2020-09-29 at 13 59 11" src="https://user-images.githubusercontent.com/2781759/94550649-c200a100-025c-11eb-9817-cf07818bbb3f.png">

Also the [bubble chart of top 10 countries](https://covid-19.demo.community.intersystems.com/dsw/index.html#!/USER/Covid19/bubble%20chart.dashboard)
<img width="1198" alt="Screenshot 2020-09-18 at 11 05 28" src="https://user-images.githubusercontent.com/2781759/93572744-f2178c80-f99e-11ea-93e2-6eda2e31d212.png">


## data source
The data is taken from [Johns Hopkins repo](https://github.com/CSSEGISandData/COVID-19)

## How it works
The dashboard is running on InterSystems IRIS 2020.4 Community Edition
It uses IRIS Analytics module and DSW as a representation layer
It runs in a Kubernetes cluster in GCP

## How it was developed
[AnalyzeThis](https://openexchange.intersystems.com/package/AnalyzeThis) module has been used to generate the class and the cube.
Pivots and Dashboards were built manually using [InterSystems IRIS Analytics](https://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=D2GS)
[DSW](https://openexchange.intersystems.com/package/DeepSeeWeb) is used to design representation layer
[ISC-DEV](https://openexchange.intersystems.com/package/ISC-DEV) module was used to export pivot and dashboard.

To export changes in Pivots and Dashboards do:
```
USER> do ##class(dev.code).export("*.DFI")
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
Wait for VSCode to make connection and show something like "localhost:32778[USER] - Connected"

You can start coding after that. 

Contributions are welcome via Pull Requests.
