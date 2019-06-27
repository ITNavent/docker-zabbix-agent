#!/bin/bash
echo "parametro $1 arranco script numero de parametros $#" >> tests.txt
if [ -n "$2" ]; then
	START_TIME=$SECONDS
	echo "el parametro de sleep es $2" >> tests.txt
	sleep $2
	ELAPSED_TIME=$(($SECONDS - $START_TIME))
        echo "termina el sleep $ELAPSED_TIME" >> tests.txt
fi


HOSTNAME=$(printf %s "$(hostname)")
echo HOSTNAME $HOSTNAME

HOSTIP=$(printf %s "$(hostname -i)")
echo HOSTIP $HOSTIP

LOGIN_BODY='{"jsonrpc":"2.0","method":"user.login","params":{ "user":"deploy_bot","password":"deploy"},"auth":null,"id":0}'
echo $LOGIN_BODY
TOKEN=$(curl -X POST -H 'Content-type:application/json' -d "$LOGIN_BODY" \
-s -N "https://zabbix.navent.com/api_jsonrpc.php" | jq -r '.result')
echo TOKEN $TOKEN

HOSTID_BODY='{"jsonrpc":"2.0","method":"host.get","params":{"filter":{"host":["'"$HOSTNAME"'"]},"selectInterfaces":"extend"},"auth":"'"$TOKEN"'","id":1}'
echo HOSTID_BODY $HOSTID_BODY

HOSTID_RESPONSE=$(curl -X POST -H 'Content-type:application/json' -d "$HOSTID_BODY" \
-s -N "https://zabbix.navent.com/api_jsonrpc.php")
echo HOSTID_RESPONSE $HOSTID_RESPONSE

HOSTID=$(echo "$HOSTID_RESPONSE" | jq -r '.result[0].hostid')
echo HOSTID $HOSTID

HOSTINTERFACES=$(echo "$HOSTID_RESPONSE" | jq -r '.result[0].interfaces')
echo HOSTINTERFACES $HOSTINTERFACES


function create_host() {
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
	if [ -z "$ZBX_JMXPORT" ]; then
		JMX_INTERFACE=""
	else
		JMX_INTERFACE=',{"type":4,"main":1,"useip":1,"ip":"'"$HOSTIP"'","dns":"","port":"'"$ZBX_JMXPORT"'"}'
	fi
	echo JMX_INTERFACE $JMX_INTERFACE

	CREATE_BODY='{"jsonrpc":"2.0","method":"host.create","params":{"host":"'"$HOSTNAME"'","templates":['"${TEMPLATE_IDS::-1}"'],"groups":['"${GROUP_IDS::-1}"'],"interfaces":[{"type":1,"main":1,"useip":1,"ip":"'"$HOSTIP"'","dns":"","port":"10050"}'"$JMX_INTERFACE"']},"auth":"'"$TOKEN"'","id":3}'
	echo CREATE_BODY $CREATE_BODY

	curl -X POST -H 'Content-type:application/json' -d "$CREATE_BODY" -s -N "https://zabbix.navent.com/api_jsonrpc.php"
}

function enable_host() {
	UPDATE_BODY='{"jsonrpc":"2.0","method":"host.update","params":{"hostid":"'"$HOSTID"'","status":0},"auth":"'"$TOKEN"'","id":3}'
	echo UPDATE_BODY $UPDATE_BODY

	curl -X POST -H 'Content-type:application/json' -d "$UPDATE_BODY" -s -N "https://zabbix.navent.com/api_jsonrpc.php"
}

case $1 in
	create)
		create_host
		;;
	createOrUpdate)
		if [ "$HOSTID" == null ]
		then
			create_host
		else
			UPDATE_HOSTINTERFACES=$(echo "$HOSTINTERFACES" | jq --arg hostip "$HOSTIP" '.[].ip |=$hostip')
			echo UPDATE_HOSTINTERFACES $UPDATE_HOSTINTERFACES

			UPDATE_IP_BODY='{"jsonrpc":"2.0","method":"hostinterface.update","params":'"$UPDATE_HOSTINTERFACES"',"auth":"'"$TOKEN"'","id":4}'
			echo UPDATE_IP_BODY $UPDATE_IP_BODY

			curl -X POST -H 'Content-type:application/json' -d "$UPDATE_IP_BODY" -s -N "https://zabbix.navent.com/api_jsonrpc.php"

			enable_host
		fi
		;;
	enable)
		enable_host
		;;
	disable)
		UPDATE_BODY='{"jsonrpc":"2.0","method":"host.update","params":{"hostid":"'"$HOSTID"'","status":1},"auth":"'"$TOKEN"'","id":3}'
		echo UPDATE_BODY $UPDATE_BODY

		curl -X POST -H 'Content-type:application/json' -d "$UPDATE_BODY" -s -N "https://zabbix.navent.com/api_jsonrpc.php"
		;;
	*)
		echo "desconocido, debe ser uno de (create,createOrUpdate,enable,disable)"
		;;
esac
