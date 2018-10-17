#!/bin/bash

HOSTNAME=$(printf %s "$(hostname)")
echo HOSTNAME $HOSTNAME

HOSTIP=$(printf %s "$(hostname -i)")
echo HOSTIP $HOSTIP

LOGIN_BODY='{"jsonrpc":"2.0","method":"user.login","params":{ "user":"deploy_bot","password":"deploy"},"auth":null,"id":0}'
echo $LOGIN_BODY
TOKEN=$(curl -X POST -H 'Content-type:application/json' -d "$LOGIN_BODY" \
-s -N "http://zabbix.navent.com/api_jsonrpc.php" | jq -r '.result')
echo TOKEN $TOKEN

HOSTID_BODY='{"jsonrpc":"2.0","method":"host.get","params":{"filter":{"host":["'"$HOSTNAME"'"]}},"auth":"'"$TOKEN"'","id":1}'
echo HOSTID_BODY $HOSTID_BODY

HOSTID=$(curl -X POST -H 'Content-type:application/json' -d "$HOSTID_BODY" \
-s -N "http://zabbix.navent.com/api_jsonrpc.php" | jq -r '.result[0].hostid')
echo HOSTID $HOSTID

case $1 in
	create)
		TEMPLATE_IDS=
		IFS=',' read -r -a arrayT <<< $(echo $ZBX_TEMPLATEID)
		for element in "${arrayT[@]}"
		do
    		TEMPLATE_IDS+="{\"templateid\":$element},"
    	done
		echo TEMPLATE_IDS "${TEMPLATE_IDS::-1}"

		GROUP_IDS=
		IFS=',' read -r -a arrayG <<< $(echo $ZBX_GROUPID)
		for element in "${arrayG[@]}"
		do
    		GROUP_IDS+="{\"groupid\":$element},"
    	done
		echo GROUP_IDS "${GROUP_IDS::-1}"
		
		JMX_INTERFACE=
		if [ -f "$ZBX_JMXPORT" ]; then
    		JMX_INTERFACE=""
		else
    		JMX_INTERFACE=',{"type":4,"main":1,"useip":1,"ip":"'"$HOSTIP"'","dns":"","port":"'"$ZBX_JMXPORT"'"}'
		fi
		echo JMX_INTERFACE $JMX_INTERFACE
		
		CREATE_BODY='{"jsonrpc":"2.0","method":"host.create","params":{"host":"'"$HOSTNAME"'","templates":['"${TEMPLATE_IDS::-1}"'],"groups":['"${GROUP_IDS::-1}"'],"interfaces":[{"type":1,"main":1,"useip":1,"ip":"'"$HOSTIP"'","dns":"","port":"10050"}'"$JMX_INTERFACE"']},"auth":"'"$TOKEN"'","id":3}'
		echo CREATE_BODY $CREATE_BODY

		curl -X POST -H 'Content-type:application/json' -d "$CREATE_BODY" -s -N "http://zabbix.navent.com/api_jsonrpc.php"
		;;
	enable)
		UPDATE_BODY='{"jsonrpc":"2.0","method":"host.update","params":{"hostid":"'"$HOSTID"'","status":0},"auth":"'"$TOKEN"'","id":3}'
		echo UPDATE_BODY $UPDATE_BODY

		curl -X POST -H 'Content-type:application/json' -d "$UPDATE_BODY" -s -N "http://zabbix.navent.com/api_jsonrpc.php"
		;;
	disable)
		UPDATE_BODY='{"jsonrpc":"2.0","method":"host.update","params":{"hostid":"'"$HOSTID"'","status":1},"auth":"'"$TOKEN"'","id":3}'
		echo UPDATE_BODY $UPDATE_BODY

		curl -X POST -H 'Content-type:application/json' -d "$UPDATE_BODY" -s -N "http://zabbix.navent.com/api_jsonrpc.php"
		;;
	*)
		echo "desconocido, debe ser uno de (create,enable,disable)"
		;;
esac