# Rundeck

**Links**<br>
https://docs.rundeck.com/docs/api/rundeck-api.html<br>
https://docs.rundeck.com/docs/administration/configuration/config-file-reference.html<br>
https://docs.rundeck.com/docs/manual/projects/<br>
https://documenter.getpostman.com/view/95797/rundeck/7TNfX9k#intro<br>
https://docs.rundeck.com/docs/manual/job-workflows.html#context-variables<br>
https://docs.rundeck.com/docs/learning/tutorial/users.html<br>
https://docs.rundeck.com/docs/administration/security/authentication.html#propertyfileloginmodule<br>
https://docs.rundeck.com/docs/administration/configuration/database/<br>
https://www.digitalocean.com/community/tutorials/how-to-move-a-postgresql-data-directory-to-a-new-location-on-ubuntu-16-04<br>
https://groups.google.com/g/rundeck-discuss/c/rXCY3dWy0CA<br>

Rundeck admin | admin » http://IP:4440<br>
Gitlab root | /etc/gitlab/initial_root_password » http://IP<br>

# PostgreSQL Install
**SSH - rundeck**
* sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
* wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
* sudo apt update
* sudo apt install -y postgresql-14
* sudo systemctl enable postgresql --now
* sudo vi /etc/postgresql/14/main/pg_hba.conf
```
#host   all             all             127.0.0.1/32            scram-sha-256
host    all             all             127.0.0.1/32            trust
```
* sudo systemctl restart postgresql

# PostgreSQL Change DB Location
**SSH - rundeck**
* sudo mkdir /work/
* sudo systemctl stop postgresql
* sudo rsync -av /var/lib/postgresql /work
* sudo mv /var/lib/postgresql/14/main /var/lib/postgresql/14/main.bkp
* sudo vi /etc/postgresql/14/main/postgresql.conf
```
#data_directory = '/var/lib/postgresql/14/main'
data_directory = '/work/postgresql/14/main'
```
* sudo systemctl restart postgresql

# Change Database Rundeck
**SSH - rundeck**
* sudo -u postgres -s /bin/bash
* < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;
* psql
* postgres=# create database rundeck;
* postgres=# create user rundeckuser with password '<DB_PASS>';
* postgres=# grant ALL privileges on database rundeck to rundeckuser;
* postgres=# exit;
* exit
* sudo vi /etc/rundeck/rundeck-config.properties
```
#dataSource.dbCreate = none
#dataSource.url = jdbc:h2:file:/var/lib/rundeck/data/rundeckdb;DB_CLOSE_ON_EXIT=FALSE;NON_KEYWORDS=MONTH,HOUR,MINUTE,YEAR,SECONDS
dataSource.driverClassName = org.postgresql.Driver
dataSource.url = jdbc:postgresql://localhost:5432/rundeck
dataSource.username = rundeckuser
dataSource.password = <DB_PASS>
```
* sudo systemctl restart rundeckd

# Project
**UI - Create project "OPS"**

**SSH - rundeck**
* sudo mkdir -p /var/rundeck/projects/OPS/etc<br>
* sudo vi /var/rundeck/projects/OPS/etc/resources.xml<br>
```
<?xml version="1.0" encoding="UTF-8"?>
<project>
<node name="srv01.aut.lab"
 description="Ubuntu Server"
 tags="Ubuntu"
 hostname="srv01.aut.lab"
 username="rundeck"
 ssh-key-storage-path="keys/private.key"
 />
<node name="srv02.aut.lab"
 description="CentOS Server"
 tags="CentOS"
 hostname="srv02.aut.lab"
 username="rundeck"
 ssh-key-storage-path="keys/private.key"
 />
</project>
```
* sudo chown -R rundeck.rundeck /var/rundeck/projects/

**UI - Project Settings**
* Edit Configuration File (insert below)
```
resources.source.1.config.file=/var/rundeck/projects/OPS/etc/resources.xml
resources.source.1.config.generateFileAutomatically=true
resources.source.1.config.includeServerNode=true
resources.source.1.type=file
```
* Nodes > List nodes

**SSH - rundeck**
* sudo update-alternatives --config editor (Debian/Ubuntu Server only)
* sudo bash -c 'visudo'
  * rundeck ALL=(ALL) NOPASSWD:ALL

# Node
**SSH - srv01/srv02**
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

**SSH - rundeck (rundeck user)**
* sudo -u rundeck -s /bin/bash
* ssh-keygen -t rsa
* cp /var/lib/rundeck/.ssh/id_rsa /var/lib/rundeck/.ssh/id_rsa.bkp
* ssh-keygen -p -N "" -m pem -f /var/lib/rundeck/.ssh/id_rsa
* ssh-copy-id -i /var/lib/rundeck/.ssh/id_rsa.pub rundeck@srv01
* ssh-copy-id -i /var/lib/rundeck/.ssh/id_rsa.pub rundeck@srv02
* cat /var/lib/rundeck/.ssh/id_rsa

**UI - Gear**
* Key Storage > Add or Upload a Key > Private Key > keys/private.key (paste rsa pk)

**UI - Project Settings - Edit Configuration**
* Default Node Executor > SSH Key Storage Path > Select Private Key (keys/private.key)

# API Token
**SSH - rundeck**
* < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo; 
* echo <TOKEN> | wc -m (33)
* sudo bash -c 'echo "rundeck.tokens.file=/etc/rundeck/tokens.properties" >> /etc/rundeck/framework.properties'
* sudo bash -c 'echo "admin: <TOKEN>, build,architect,admin,user,deploy" >> /etc/rundeck/tokens.properties'
* sudo chown -R rundeck.rundeck /etc/rundeck/tokens.properties
* sudo systemctl restart rundeckd

# API Running Jobs
* curl --insecure -X GET http://192.168.56.180:4440/api/41/projects?authtoken=<TOKEN> -H 'Content-Type: application/xml'
* curl --insecure -X GET http://192.168.56.180:4440/api/41/projects?authtoken=<TOKEN> -H 'Content-Type: application/json'
* curl --insecure -X GET http://192.168.56.180:4440/api/41/project/AtualizaInfo/jobs?authtoken=<TOKEN> -H 'Content-Type: application/json'
* curl --insecure -X POST http://192.168.56.180:4440/api/41/job/<JOB_ID>/run?authtoken=<TOKEN> -H 'Content-Type: application/json'

# API Running Jobs (node filter)
* curl --insecure -X POST http://192.168.56.180:4440/api/41/job/<JOB_ID>/run?authtoken=<TOKEN> -H 'Content-Type: application/json' -d '{"filter":"srv01.aut.lab,srv02.aut.lab"}'

# API Import & Export Project/Jobs
* curl --insecure -X GET http://192.168.56.180:4440/api/41/project/AtualizaInfo/jobs/export?authtoken=<TOKEN> -H 'Content-Type: application/xml' > /tmp/project_export.xml
* curl --insecure -X GET http://192.168.56.180:4440/api/41/job/<JOB_ID>?authtoken=<TOKEN> -H 'Content-Type: application/xml' > /tmp/install_package.xml
* curl -v -H x-rundeck-auth-token:<TOKEN> http://192.168.56.180:4440/api/41/project/AtualizaInfo/jobs/import -F xmlBatch=@"/import_templates/job_export.xml"

# User Add
* sudo vi /etc/rundeck/realm.properties
  * fabio:<PASSWORD>,user,admin,architect,deploy,build

# Job Template (workflow)
* Step 1
  * Local Command
    * Command: sudo bash -c 'printf ${node.name} > /etc/ansible/hosts'
    * Step Label: Local Hosts File

* Step 2
  * Ansible Playbook Inline Workflow Node Step
    * Ansible binaries directory path: /usr/local/bin/
    * Ansible base directory path: /etc/ansible/
    * Playbook: ...
    * Extra Variables: ...

    * SSH Authentication: privateKey
    * SSH User: rundeck
    * SSH Passphrase from secure option: option.password

    * Privilege escalation method: sudo

# !!!
* User/pass plain text
* Token plain text
* API call > Ansible Extra Vars
* Don't use the H2 embedded database for anything except testing and non-production. Use MariaDB, Mysql, Postgres or Oracle instead.
* Plugin Slack Notification
* FQDN > /etc/rundeck/framework.properties