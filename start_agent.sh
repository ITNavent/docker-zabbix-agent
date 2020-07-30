#!/bin/bash

/etc/zabbix/zabbix_api.sh createOrUpdate
status=$?
if [ $status -ne 0 ]; then
  echo "Failed prestart: $status"
  exit $status
fi

/usr/bin/docker-entrypoint.sh