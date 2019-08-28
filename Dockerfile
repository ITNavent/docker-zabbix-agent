FROM zabbix/zabbix-agent:alpine-3.0-latest
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
