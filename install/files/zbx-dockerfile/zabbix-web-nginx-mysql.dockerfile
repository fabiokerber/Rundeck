FROM zabbix/zabbix-web-nginx-mysql:alpine-5.2-latest
ENV ZBX_SERVER_HOST=zabbix-server-mysql
ENV DB_SERVER_HOST=mysql-server
ENV MYSQL_DATABASE=zabbixdb
ENV MYSQL_USER=zabbix
ENV MYSQL_PASSWORD=H9W&n#Iv
ENV MYSQL_ROOT_PASSWORD=UCxV*rR&
EXPOSE 8080