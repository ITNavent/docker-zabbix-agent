# docker-zabbix-agent

![alt text](http://www.diegoluisi.eti.br/wp-content/uploads/2015/05/zabbix.png "Agente Zabbix") 
# Extension del agente zabbix

Imagen de docker para ser usada en Kuberntes como sidecar container junto a la aplicacion a inspeccionar.

Para crear la imagen:

docker build -t gcr.io/redeo-all/docker-zabbix-agent:${TAG_IMAGEN} -f Dockerfile .

Luego subirla al repo:

docker push gcr.io/redeo-all/docker-zabbix-agent:${TAG_IMAGEN}


+ La imagen tiene un script escrito en bash __/etc/zabbix/zabbix_api.sh__ que recibe un parametro entre create, enable y disable.

Cuando se envia el parámetro __create__, busca las variables de entorno ZBX_TEMPLATEID, ZBX_GROUPID y ZBX_JMXPORT para registrar el hostname en zabbix.

ZBX_TEMPLATEID es string csv con los id de los templates a linkear al host.

ZBX_GROUPID es string csv con los id de los grupos a linkear al host.

ZBX_JMXPORT es opcional y si esta definido crea en el host la interfaz JMX en el puerto indicado.


+ Cuando se envia el parámetro __disable__ se desactiva la entrada del host en zabbix. Usado cuando se destruye el host y no se desean perder las metricas guardadas.

+ Cuando se envia el parámetro __enable__ se vuelve a activar el host en zabbix.

+ Cuando se envia el parámetro __createOrUpdate__ opera en modo __create__ en caso de no existir en host en zabbix.

+ Cuando se envia un segundo ṕarametro además de disable / create / createOrUpdate setea el tiempo de timeout , antes de que realice la acción enviada en parametro 1

Para cuando existe el host en zabbix se hace un update de las interfases actualizando la IP de las mismas. Esto es util para usarlo con Stateful Sets de K8.


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
        - "40" (opcional)
    preStop:
      exec:
        command:
        - "/etc/zabbix/zabbix_api.sh"
        - "disable"
```
