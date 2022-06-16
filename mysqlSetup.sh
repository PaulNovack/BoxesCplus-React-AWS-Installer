#! /bin/bash
sudo apt-get install mysql-server mysql-client -y
sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
mysql -e "create user 'boxes'@'%' identified by 'boxes'"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'boxes'@'%';"
mysql -e "create database boxes"
sudo service mysql stop
sudo service mysql start
mysql -uboxes -pboxes boxes < /home/ubuntu/boxesCreate.sql
sudo service mysql stop
sudo service mysql start


