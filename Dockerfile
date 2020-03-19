ARG IMAGE=store/intersystems/irishealth:2019.3.0.308.0-community
ARG IMAGE=store/intersystems/iris-community:2019.3.0.309.0
ARG IMAGE=store/intersystems/iris-community:2019.4.0.379.0
ARG IMAGE=store/intersystems/iris-community:2020.1.0.199.0
ARG IMAGE=intersystemsdc/iris-community:2019.4.0.383.0-zpm
FROM $IMAGE

USER root

WORKDIR /opt/irisapp
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp

USER irisowner

COPY  Installer.cls .
COPY  src src
COPY  data files
COPY irissession.sh /
SHELL ["/irissession.sh"]

RUN \
  do $SYSTEM.OBJ.Load("Installer.cls", "ck") \
  set sc = ##class(App.Installer).setup() \
  zn "IRISAPP" \
  zpm "install analyzethis" \
  set pfile = "/opt/irisapp/files/covid-03-16-2020.csv", rc=0 \
  do ##class(AnalyzeThis.Generated.covid03162020).Import(,pfile,",", ,1,.rc) \
  write "imported records: "_rc \
  do ##class(%DeepSee.Utils).%BuildCube("covid03162020") \
  zpm "install dsw" 
# bringing the standard shell back
SHELL ["/bin/bash", "-c"]
