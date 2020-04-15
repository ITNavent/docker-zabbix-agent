FROM golang:1.10.0-alpine
RUN apk add --no-cache git
ENV GOPATH /go
RUN go get -u github.com/googlecloudplatform/gcsfuse
FROM zabbix/zabbix-agent:alpine-3.0-latest

COPY --from=0 /go/bin/gcsfuse /usr/local/bin

RUN apk add --no-cache ca-certificates fuse && rm -rf /tmp/*

LABEL maintainer="corerealestate@navent.com"

RUN apk add --no-cache curl jq bash

RUN apk add --update \
    python \
    python-dev \
    py-pip \
    which \
    git

COPY zabbix_api.sh /etc/zabbix/zabbix_api.sh
RUN ["chmod", "+x", "/etc/zabbix/zabbix_api.sh"]

COPY mantenimiento.py /etc/zabbix/mantenimiento.py
RUN ["chmod", "+x", "/etc/zabbix/mantenimiento.py"]

COPY putInMantenimiento.sh /etc/zabbix/putInMantenimiento.sh
RUN ["chmod", "+x", "/etc/zabbix/putInMantenimiento.sh"]

COPY jstack_pod.sh /etc/zabbix/jstack_pod.sh
RUN ["chmod", "+x", "/etc/zabbix/jstack_pod.sh"]

COPY jstack_pod.sh /etc/zabbix/jstack_pod.sh
RUN ["chmod", "+x", "/etc/zabbix/jstack_pod.sh"]

COPY mantenimientosindata.py /etc/zabbix/mantenimientosindata.py
RUN ["chmod", "+x", "/etc/zabbix/mantenimientosindata.py"]

COPY removeInMantenimientoSinData.sh /etc/zabbix/removeInMantenimientoSinData.sh
RUN ["chmod", "+x", "/etc/zabbix/removeInMantenimientoSinData.sh"]

COPY putInMantenimientoSinData.sh /etc/zabbix/putInMantenimientoSinData.sh
RUN ["chmod", "+x", "/etc/zabbix/putInMantenimientoSinData.sh"]

COPY mantenimientosindatacongrupo.py /etc/zabbix/mantenimientosindatacongrupo.py
RUN ["chmod", "+x", "/etc/zabbix/mantenimientosindatacongrupo.py"]