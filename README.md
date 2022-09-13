# Rundeck

http://IP:4440

**Criado projeto AtualizaInfo**
* Workflow > ls -ltr /tmp
* Nodes > Execute locally

**Acesso ssh rundeck**
* sudo mkdir -p /var/rundeck/projects/AtualizaInfo/etc
* vi /var/rundeck/projects/AtualizaInfo/etc/resources.xml
```
<?xml version="1.0" encoding="UTF-8"?>
<project>
<node name="srv01"
 description="Ubuntu Server"
 tags="Linux"
 hostname="192.168.56.190"
 username="<USUARIO>"
 />
<node name="<NOME DO HOST>"
 description="CentOS Server"
 tags="Linux"
 hostname="192.168.56.191"
 username="<USUARIO>"
 />
</project>
```
* chown -R rundeck.rundeck /var/rundeck/projects/
