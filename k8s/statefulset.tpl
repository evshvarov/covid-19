apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: covid19-analytics
  namespace: iris
spec:
  serviceName: covid19-analytics
  replicas: 1
  updateStrategy:
    type: RollingUpdate
  selector:
    matchLabels:
      app: covid19-analytics
  template:
    metadata:
      labels:
        app: covid19-analytics
    spec:

      initContainers:
      - name: covid19-volume-change-owner-hack
        image: busybox
        command:
        - sh
        - -c
        - |
          chown -R 51773:52773 /opt/covid19/COVID19-DATA
          chmod g+w /opt/covid19/COVID19-DATA
          echo -e "zn \"%sys\"\nif (##class(SYS.Database).%ExistsId(\"/opt/covid19/COVID19-DATA\")) { halt }\nset db=##class(SYS.Database).%New()\nset db.Directory=\"/opt/covid19/COVID19-DATA\"\nset db.ResourceName=\"%DB_COVID19\"\nwrite db.%Save()\nhalt" > /mount-helper/mount_covid19_data
        volumeMounts:
        - mountPath: /opt/covid19/COVID19-DATA
          name: covid19-volume
        - mountPath: /mount-helper
          name: mount-helper
      volumes:
      - emptyDir: {}
        name: mount-helper
      containers:
      - image: DOCKER_REPO_NAME:DOCKER_IMAGE_TAG
        name: covid19-analytics
        lifecycle:
          postStart:
            exec:
              command:
              - /bin/bash
              - -c
              - |
                sleep 30
                iris session iris < /mount-helper/mount_covid19_data
        ports:
        - containerPort: 52773
          name: web
        volumeMounts:
        - mountPath: /opt/covid19/COVID19-DATA
          name: covid19-volume
        - mountPath: /mount-helper
          name: mount-helper
  volumeClaimTemplates:
  - metadata:
      name: covid19-volume
      namespace: iris
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 10Gi
