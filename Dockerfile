ARG IMAGE=store/intersystems/irishealth:2019.3.0.308.0-community
ARG IMAGE=store/intersystems/iris-community:2019.3.0.309.0
ARG IMAGE=store/intersystems/iris-community:2019.4.0.379.0
ARG IMAGE=store/intersystems/iris-community:2020.1.0.199.0
ARG IMAGE=intersystemsdc/iris-community:2019.4.0.383.0-zpm
ARG IMAGE=intersystemsdc/iris-community:2020.1.0.209.0-zpm
ARG IMAGE=intersystemsdc/iris-community:2020.3.0.200.0-zpm
ARG IMAGE=intersystemsdc/iris-community:2020.2.0.196.0-zpm
FROM $IMAGE

USER root

WORKDIR /opt/irisapp
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp

USER irisowner

COPY  Installer.cls .
COPY  src src
COPY  data files
COPY sql sql
COPY js /usr/irissys/csp/irisapp
COPY iris.script /tmp/iris.script

RUN iris start IRIS \
	&& iris session IRIS < /tmp/iris.script \
  && iris stop IRIS quietly

COPY /dsw/irisapp.json /usr/irissys/csp/dsw/configs/
COPY /dsw/DSW.WorldMap.js /usr/irissys/csp/dsw/addons/
COPY /dsw/heatmapChart.js /usr/irissys/csp/dsw/addons/
# USER root
# RUN chmod 777 /usr/irissys/csp/dsw/addons/worldmap.js
# USER irisowner

