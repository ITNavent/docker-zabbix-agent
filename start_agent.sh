#!/bin/bash

set -x

set /sbin/tini -- /usr/bin/docker-entrypoint.sh "$@"

/etc/zabbix/zabbix_api.sh createOrUpdate
status=$?
echo "Prestart status: $status"

exec "$@"