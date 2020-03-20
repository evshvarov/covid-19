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
[ISC-DEV](https://openexchange.intersystems.com/package/ISC-DEV) module was used to export pivot and dashboard

## deployment
It's being deployed by Github Actions using this workflow
Which uses terraform and K8 configuration.
Dockerfile loads sources, pivot and dashboard. It imports data and builds cube.



[Read about all the files in this artilce](https://community.intersystems.com/post/dockerfile-and-friends-or-how-run-and-collaborate-objectscript-projects-intersystems-iris)
