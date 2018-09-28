FROM zabbix/zabbix-agent:alpine-3.0-latest
LABEL maintainer="corerealestate@navent.com"

RUN apk add --no-cache curl jq bash

COPY zabbix_api.sh /etc/zabbix/zabbix_api.sh
RUN ["chmod", "+x", "/etc/zabbix/zabbix_api.sh"]