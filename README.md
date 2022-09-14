# Rundeck

**Links**
https://docs.rundeck.com/docs/api/rundeck-api.html
https://docs.rundeck.com/docs/administration/configuration/config-file-reference.html

http://IP:4440

# Project
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
 tags="Ubuntu"
 hostname="192.168.56.190"
 username.default="rundeck"
 ssh-key-storage-path="keys/project/AtualizaInfo/private.key"
 />
<node name="srv02"
 description="CentOS Server"
 tags="CentOS"
 hostname="192.168.56.191"
 username.default="rundeck"
 ssh-key-storage-path="keys/project/AtualizaInfo/private.key"
 />
</project>
```
* sudo chown -R rundeck.rundeck /var/rundeck/projects/

**UI - Project Settings**
* Edit Configuration File (insert below)
```
resources.source.1.config.file=/var/rundeck/projects/AtualizaInfo/etc/resources.xml
resources.source.1.config.generateFileAutomatically=true
resources.source.1.config.includeServerNode=true
resources.source.1.type=file
```
* Nodes > List nodes

# Node
**SSH - srv01**
* sudo useradd -r -m rundeck
* sudo passwd rundeck
* sudo update-alternatives --config editor (Debian/Ubuntu Server only)
* sudo bash -c 'visudo'
  * rundeck ALL=(ALL) NOPASSWD:ALL
* sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
* sudo bash -c 'echo "AllowUsers root" >> /etc/ssh/sshd_config'
* sudo bash -c 'echo "AllowUsers rundeck" >> /etc/ssh/sshd_config'
* sudo bash -c 'echo "AllowUsers fabio" >> /etc/ssh/sshd_config'
* sudo bash -c 'echo "AllowUsers vagrant" >> /etc/ssh/sshd_config'
* sudo systemctl restart sshd

**SSH - rundeck (user rundeck)**
* sudo -u rundeck -s /bin/bash
* ssh-keygen -t rsa
* cp /var/lib/rundeck/.ssh/id_rsa /var/lib/rundeck/.ssh/id_rsa.bkp
* ssh-keygen -p -N "" -m pem -f /var/lib/rundeck/.ssh/id_rsa
* ssh-copy-id -i /var/lib/rundeck/.ssh/id_rsa.pub rundeck@srv01
* cat /var/lib/rundeck/.ssh/id_rsa

**UI - Engrenagem**
* Key Storage > Add or Upload a Key > Private Key > keys/project/AtualizaInfo/private.key (paste pk)

**UI - Project Settings**
* Default Node Executor > SSH Key Storage Path > Select Private Key (pk)

# API
**SSH - rundeck (user rundeck)**
* < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo; 
* echo <TOKEN> | wc -m (33)
* sudo bash -c 'echo "rundeck.tokens.file=/etc/rundeck/tokens.properties" >> /etc/rundeck/framework.properties'
* sudo bash -c 'echo "admin: <TOKEN>, build,architect,admin,user,deploy" >> /etc/rundeck/tokens.properties'
* sudo chown -R rundeck.rundeck /etc/rundeck/tokens.properties
* sudo systemctl restart rundeckd