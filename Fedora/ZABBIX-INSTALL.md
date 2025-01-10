# Install Zabbix
Repositories for teaching purposes at SPOS DK

Repository pro vyuku na SPOS DK

## Manuální postup instalace Zabbix monitorovacího systému 

Zabbix - [https://www.zabbix.com](https://www.zabbix.com)

- Vytvoříme si VM s FreeBSD 14
- Po přihláení do OS postupně vykonáme tyto příkazy
- Po instalaci a konfiguraci použijeme Browser a provedeme finalni konfiguraci

```console
    # Vytvorime si VM s FreeBSD 14
    vagrant up
    vagrant ssh

    # Aktualizace systému
    sudo pkg update

    # Instalace základních nástrojů
    sudo pkg install -y p5-UUID gsed htop

    # Instalace MySQL serveru
    sudo pkg install -y mysql80-server
    sudo /usr/local/etc/rc.d/mysql-server enable
    sudo /usr/local/etc/rc.d/mysql-server restart

    # Konfigurace databáze pro Zabbix
    sudo mysql -e "CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
    sudo mysql -e "CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'zabbix_password';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';"
    sudo mysql -e "SET GLOBAL log_bin_trust_function_creators = 1;"
    sudo mysql -e "FLUSH PRIVILEGES;"

    # Instalace Zabbix serveru, frontend a agenta
    sudo pkg install -y zabbix7-agent zabbix7-server zabbix7-frontend-php83 zabbix7-java apache24 mod_php83

    # Import Zabbix databázové struktury
    sudo cat /usr/local/share/zabbix7/server/database/mysql/schema.sql | mysql --default-character-set=utf8mb4 -uzabbix -pzabbix_password zabbix
    sudo cat /usr/local/share/zabbix7/server/database/mysql/images.sql | mysql --default-character-set=utf8mb4 -uzabbix -pzabbix_password zabbix
    sudo cat /usr/local/share/zabbix7/server/database/mysql/data.sql | mysql --default-character-set=utf8mb4 -uzabbix -pzabbix_password zabbix

    # Disable log_bin_trust_function_creators option after importing database schema.
    sudo mysql -e "SET GLOBAL log_bin_trust_function_creators = 0;"

    # Konfigurace Zabbix serveru
    sudo gsed -i 's/# DBPassword=/DBPassword=zabbix_password/' /etc/zabbix/zabbix_server.conf

    # Spuštění Zabbix serveru a agenta
    sudo /usr/local/etc/rc.d/zabbix_agentd restart
    sudo /usr/local/etc/rc.d/zabbix_server restart

    # Konfigurace PHP pro Zabbix frontend
    sudo cp /usr/local/etc/php.ini-production /usr/local/etc/php.ini
    sudo gsed -i 's/^max_input_time = .*/max_input_time = 300/' /usr/local/etc/php.ini
    sudo gsed -i 's/^memory_limit = .*/memory_limit = 128M/' /usr/local/etc/php.ini
    sudo gsed -i 's/^post_max_size = .*/post_max_size = 16M/' /usr/local/etc/php.ini
    sudo gsed -i 's/^upload_max_filesize = .*/upload_max_filesize = 2M/' /usr/local/etc/php.ini
    sudo gsed -i 's/^;date.timezone =.*/date.timezone = Europe\/Prague/' /usr/local/etc/php.ini
    sudo cp /home/vagrant/zabbix.conf /usr/local/etc/apache24/extra/

    # Restart Apache pro načtení změn
    sudo cp /usr/local/etc/apache24/httpd.conf /usr/local/etc/apache24/httpd.conf-orig
    sudo cp /home/vagrant/httpd.conf.patch /usr/local/etc/apache24/
    sudo cd /usr/local/etc/apache24/
    sudo patch httpd.conf < httpd.conf.patch
    sudo cp /home/vagrant/zabbix.conf.php /usr/local/www/zabbix7/conf/
    sudo chown www:www /usr/local/www/zabbix7/conf/zabbix.conf.php
    sudo chmod 400 /usr/local/www/zabbix7/conf/zabbix.conf.php
    sudo /usr/local/etc/rc.d/apache24 restart

    # Konfigurace zabbix_agent2.conf
    sudo cp -v /usr/local/etc/zabbix7/zabbix_agentd.conf /usr/local/etc/zabbix7/zabbix_agentd.conf-orig
    sudo gsed -i 's/Server=127.0.0.1/Server=localhost/g' /usr/local/etc/zabbix7/zabbix_agentd.conf
    sudo gsed -i 's/ServerActive=127.0.0.1/ServerActive=localhost/g' /usr/local/etc/zabbix7/zabbix_agentd.conf
    sudo diff -u /usr/local/etc/zabbix7/zabbix_agentd.conf-orig /usr/local/etc/zabbix7/zabbix_agentd.conf

    # Restart sluzby zabbix-agentd
    sudo /usr/local/etc/rc.d/zabbix_agentd restart
```
## Provedeme konfiguraci Zabbix Web GUI pomocí PHP wizard

- Zadejte do browseru - http://localhost:8085/zabbix/
- Username: Admin
- Passwoed: zabbix

...