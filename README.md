# docker-zabbix-agent

![alt text](http://www.diegoluisi.eti.br/wp-content/uploads/2015/05/zabbix.png "Agente Zabbix") 
# Extension del agente zabbix

Imagen de docker para ser usada en Kuberntes como sidecar container junto a la aplicacion a inspeccionar.

### En caso de modificarlo, generar un tag y publicarlo con http://172.18.140.27:30000/job/docker-zabbix-agent/

+ La imagen tiene un script escrito en bash __/etc/zabbix/zabbix_api.sh__ que recibe un parametro entre create, enable y disable.

Cuando se envia el parámetro __create__, busca las variables de entorno ZBX_TEMPLATEID, ZBX_GROUPID y ZBX_JMXPORT para registrar el hostname en zabbix.

ZBX_TEMPLATEID es string csv con los id de los templates a linkear al host.

ZBX_GROUPID es string csv con los id de los grupos a linkear al host.

ZBX_JMXPORT es opcional y si esta definido crea en el host la interfaz JMX en el puerto indicado.


+ Cuando se envia el parámetro __disable__ se desactiva la entrada del host en zabbix. Usado cuando se destruye el host y no se desean perder las metricas guardadas.

+ Cuando se envia el parámetro __enable__ se vuelve a activar el host en zabbix.


Ejemplo de configuración de deploy en Kubernetes.

```yaml
- name: zabbix-agent
  image: "gcr.io/redeo-all/docker-zabbix-agent:1.0.3"
  lifecycle:
    postStart:
      exec:
        command: 
        - "/etc/zabbix/zabbix_api.sh"
        - "create"
    preStop:
      exec:
        command:
        - "/etc/zabbix/zabbix_api.sh"
        - "disable"
```
