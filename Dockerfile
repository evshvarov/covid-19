ARG IMAGE=store/intersystems/irishealth:2019.3.0.308.0-community
ARG IMAGE=store/intersystems/iris-community:2019.3.0.309.0
ARG IMAGE=store/intersystems/iris-community:2019.4.0.379.0
ARG IMAGE=store/intersystems/iris-community:2020.1.0.199.0
ARG IMAGE=intersystemsdc/iris-community:2019.4.0.383.0-zpm
ARG IMAGE=intersystemsdc/iris-community:2020.1.0.209.0-zpm
FROM $IMAGE

USER root

WORKDIR /opt/irisapp
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp

USER irisowner

COPY  Installer.cls .
COPY  src src
COPY  data files
COPY js /usr/irissys/csp/irisapp
COPY irissession.sh /
SHELL ["/irissession.sh"]

RUN \
  do $SYSTEM.OBJ.Load("Installer.cls", "ck") \
  set sc = ##class(App.Installer).setup() \
  zn "IRISAPP" \
  zpm "install sslclient" \
  do ##class(Covid19.Utils).ImportData() \
  do ##class(Covid19.Utils).BISetup() \
  zpm "install dsw" \
  zpm "install isc-dev" \
  do ##class(dev.code).workdir("/irisdev/app/src") \
  do EnableDeepSee^%SYS.cspServer("/csp/irisapp/") \
  zn "%SYS" \
  write "Modify MDX2JSON application security...",! \
  set webName = "/mdx2json" \
  set webProperties("AutheEnabled") = 64 \
  set webProperties("MatchRoles")=":%DB_IRISAPP" \
  set sc = ##class(Security.Applications).Modify(webName, .webProperties) \
  if sc<1 write $SYSTEM.OBJ.DisplayError(sc) \
  
# bringing the standard shell back
SHELL ["/bin/bash", "-c"]

COPY /dsw/irisapp.json /usr/irissys/csp/dsw/configs/
COPY /dsw/DSW.WorldMap.js /usr/irissys/csp/dsw/addons/
# USER root
# RUN chmod 777 /usr/irissys/csp/dsw/addons/worldmap.js
# USER irisowner

