FROM mysql:8.0
ENV MYSQL_DATABASE=zabbixdb
ENV MYSQL_USER=zabbix
ENV MYSQL_PASSWORD=H9W&n#Iv
ENV MYSQL_ROOT_PASSWORD=UCxV*rR&
CMD ["--character-set-server=utf8", "--collation-server=utf8_bin", "--default-authentication-plugin=mysql_native_password"]