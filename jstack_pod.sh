#!/bin/bash
JENKINS_URL="http://rundeck:123456@34.73.253.150"

if [ “$NODE_ENV” != “prd” ]
then
NODE_ENV="stg"
fi

HOSTNAME=$(printf %s "$(hostname)")
echo $NODE_ENV
echo $NAMESPACE

curl -s -X POST --url "$JENKINS_URL/job/zabbix-jstack-$NODE_ENV/buildWithParameters?token=token-$NODE_ENV&cause=job.execid+$RANDOM" --header 'cache-control: no-cache' --header 'content-type: application/x-www-form-urlencoded' --data "HOSTNAME=$HOSTNAME&NAMESPACE=$NAMESPACE"

