ARG IMAGE=intersystemsdc/irishealth-community
ARG IMAGE=intersystemsdc/iris-community
FROM $IMAGE

WORKDIR /home/irisowner/irisdev/

ARG TESTS=0
ARG MODULE="evshvarov-covid19-analytics"
ARG NAMESPACE="USER"

RUN --mount=type=bind,src=.,dst=. \
    iris start IRIS && \
	iris session IRIS < iris.script && \
    ([ $TESTS -eq 0 ] || iris session iris -U $NAMESPACE "##class(%ZPM.PackageManager).Shell(\"test $MODULE -v -only\",1,1)") && \
    iris stop IRIS quietly

#COPY /dsw/DSW.WorldMap.js /usr/irissys/csp/dsw/addons/
#COPY /dsw/heatmapChart.js /usr/irissys/csp/dsw/addons/
# USER root
# RUN chmod 777 /usr/irissys/csp/dsw/addons/worldmap.js
# USER irisowner

