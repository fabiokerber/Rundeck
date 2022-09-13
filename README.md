# Rundeck

http://IP:4440

**UI - Criado projeto AtualizaInfo**
* Workflow > ls -ltr /tmp
* Nodes > Execute locally

**SSH - rundeck**
* sudo mkdir -p /var/rundeck/projects/AtualizaInfo/etc
* sudo vi /var/rundeck/projects/AtualizaInfo/etc/resources.xml
```
<?xml version="1.0" encoding="UTF-8"?>
<project>
<node name="srv01"
 description="Ubuntu Server"
 tags="Linux"
 hostname="192.168.56.190"
 username="rundeck"
 />
<node name="srv02"
 description="CentOS Server"
 tags="Linux"
 hostname="192.168.56.191"
 username="rundeck"
 />
</project>
```
* sudo chown -R rundeck.rundeck /var/rundeck/projects/

**UI - Project Settings**
* Edit Configuration File (adicionar abaixo)
```
resources.source.1.config.file=/var/rundeck/projects/AtualizaInfo/etc/resources.xml
resources.source.1.config.generateFileAutomatically=true
resources.source.1.config.includeServerNode=true
resources.source.1.type=file
```
* Nodes > Listar Nós

**SSH - rundeck**
```
vagrant@rundeck:~$ sudo ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): /var/lib/rundeck/.ssh/id_rsa
```

**UI - Engrenagem**
* Key Storage > Add or Upload a Key