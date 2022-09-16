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

Rundeck admin | admin » http://IP:4440<br>
Gitlab root | /etc/gitlab/initial_root_password » http://IP<br>

# PostgreSQL Install
* sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
* wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
* sudo apt-get update
* sudo -u postgres -s /bin/bash

# Change Database Rundeck
**SSH - rundeck**
* sudo apt install -y postgresql-14
* sudo systemctl start postgresql
* sudo systemctl enable postgresql
* sudo -u postgres -s /bin/bash
* < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;
* psql
* postgres=# create database rundeck;
* postgres=# create user rundeckuser with password '<DB_PASS>';
* postgres=# grant ALL privileges on database rundeck to rundeckuser;
* exit
* sudo vi /etc/rundeck/rundeck-config.properties
```
dataSource.driverClassName = org.postgresql.Driver
dataSource.url = jdbc:postgresql://pgsql.rundeck.local/rundeck
dataSource.username = rundeckuser
dataSource.password = <DB_PASS>
```

# Project
**UI - Create project "AtualizaInfo"**
* Workflow > ls -ltr /tmp
* Nodes > Execute locally

**SSH - rundeck**
* sudo mkdir -p /var/rundeck/projects/AtualizaInfo/etc<br>
* sudo vi /var/rundeck/projects/AtualizaInfo/etc/resources.xml<br>
```
<?xml version="1.0" encoding="UTF-8"?>
<project>
<node name="srv01.aut.lab"
 description="Ubuntu Server"
 tags="Ubuntu"
 hostname="srv01.aut.lab"
 username.default="rundeck"
 ssh-key-storage-path="keys/project/AtualizaInfo/private.key"
 />
<node name="srv02.aut.lab"
 description="CentOS Server"
 tags="CentOS"
 hostname="srv02.aut.lab"
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

**SSH - rundeck**
* sudo update-alternatives --config editor (Debian/Ubuntu Server only)
* sudo bash -c 'visudo'
  * rundeck ALL=(ALL) NOPASSWD:ALL

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

**SSH - rundeck (rundeck user)**
* sudo -u rundeck -s /bin/bash
* ssh-keygen -t rsa
* cp /var/lib/rundeck/.ssh/id_rsa /var/lib/rundeck/.ssh/id_rsa.bkp
* ssh-keygen -p -N "" -m pem -f /var/lib/rundeck/.ssh/id_rsa
* ssh-copy-id -i /var/lib/rundeck/.ssh/id_rsa.pub rundeck@srv01
* ssh-copy-id -i /var/lib/rundeck/.ssh/id_rsa.pub rundeck@srv02
* cat /var/lib/rundeck/.ssh/id_rsa

**UI - Gear**
* Key Storage > Add or Upload a Key > Private Key > keys/project/AtualizaInfo/private.key (paste pk)

**UI - Project Settings**
* Default Node Executor > SSH Key Storage Path > Select Private Key (pk)

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

# PostgreSQL Installation 
sudo apt-get install -y build-essential libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev libssl-dev libxml2-utils xsltproc ccache
sudo useradd postgres
sudo mkdir /work
wget -O /tmp/postgresql-14.5.tar.bz2  https://ftp.postgresql.org/pub/source/v14.5/postgresql-14.5.tar.bz2
sudo tar xvf /tmp/postgresql-14.5.tar.bz2 -C /usr/local/src/
cd /usr/local/src/postgresql-14.5 && sudo ./configure --prefix=/work/pgsql
cd /usr/local/src/postgresql-14.5 && sudo make
* sudo -u postgres -s /bin/bash
* make check
* exit
cd /usr/local/src/postgresql-14.5 && sudo make install
sudo mkdir -p /work/pgsql/data
sudo chown postgres. /work/pgsql/data
sudo -u postgres -s /bin/bash
cd /work/pgsql
bin/initdb -D data
vi /work/pgsql/data/postgresql.conf

listen_addresses = 'localhost'
port = 5432
max_connections = 100
shared_buffers = 128MB
dynamic_shared_memory_type = posix
max_wal_size = 1GB
min_wal_size = 80MB
logging_collector = on
log_directory = 'pg_log'
log_filename = 'postgresql-%Y-%m-%d.log'
log_rotation_age = 15d
log_line_prefix = '%t %p %a %u %d %r'
log_statement = 'mod'
log_timezone = 'Europe/Lisbon'
datestyle = 'iso, mdy'
timezone = 'Europe/Lisbon'
lc_messages = 'en_US.utf8'
lc_monetary = 'en_US.utf8'
lc_numeric = 'en_US.utf8'
lc_time = 'en_US.utf8'
default_text_search_config = 'pg_catalog.english'

# !!!
* User/pass plain text
* Token plain text
* API call > Ansible Extra Vars
* Don't use the H2 embedded database for anything except testing and non-production. Use MariaDB, Mysql, Postgres or Oracle instead.
* Plugin Slack Notification
* FQDN > /etc/rundeck/framework.properties