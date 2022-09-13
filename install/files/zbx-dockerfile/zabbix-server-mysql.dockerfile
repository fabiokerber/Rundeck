FROM zabbix/zabbix-server-mysql:alpine-5.2-latest
USER root
ENV DB_SERVER_HOST=mysql-server
ENV MYSQL_DATABASE=zabbixdb
ENV MYSQL_USER=zabbix
ENV MYSQL_PASSWORD=H9W&n#Iv
ENV MYSQL_ROOT_PASSWORD=UCxV*rR&
ENV ZBX_JAVAGATEWAY=zabbix-java-gateway
RUN apk --no-cache add curl
RUN apk --no-cache add jq
EXPOSE 10051