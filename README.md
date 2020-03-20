# Covid-19 analytics
This is an interactive dashboard on the analytics for covid-19 pandemia.
## data source
The data is taken from [John Hopkins repo](https://github.com/CSSEGISandData/COVID-19)

## How it works
The dashboard is running on InterSystems IRIS 2019.4 Community Edition
It uses IRIS Analytics module and DSW as a representation layer
It runs in a Kubernetes cluster in GCP

## How it was developed
AnalyzeThis module was used to generate class and cube.
Pivots and Dashboards were built manually using IRIS Analytics
DSW is used to design representation layer
ISC-DEV module was used to export pivot and dashboard

## deployment
It's being deployed by Github Actions using this workflow
Which uses terraform and K8 configuration.
Dockerfile loads sources, pivot and dashboard. It imports data and builds cube.


[Read about all the files in this artilce](https://community.intersystems.com/post/dockerfile-and-friends-or-how-run-and-collaborate-objectscript-projects-intersystems-iris)
