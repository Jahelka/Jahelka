#!/usr/bin/env bash

# Stažení balíčku pro instalaci zabbix repo
sudo excludepkgs=zabbix*

# Instalace meta balíčku
sudo rpm -Uvh -Uvh https://repo.zabbix.com/zabbix/7.0/rhel/9/x86_64/zabbix-release-latest-7.0.el9.noarch.rpm
sudo dnf clean all

# Instalace meta balíčku
sudo dnf install zabbix-agent2 zabbix-agent2-plugin-*

# Povoleni sluzby zabbix-agent2
sudo systemctl enable zabbix-agent2

# Restart sluzby zabbix-agent2
sudo systemctl restart zabbix-agent2

# EOF