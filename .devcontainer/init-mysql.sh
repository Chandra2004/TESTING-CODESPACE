#!/bin/bash

# Start MySQL (dijalankan setiap container startup)
sudo service mysql start

# Pastikan socket permission nyaman untuk user non-root (dev-only)
sudo chmod 755 /var/run/mysqld
sudo chmod 666 /var/run/mysqld/mysqld.sock

# Pastikan auth root di natif password
sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY ''; FLUSH PRIVILEGES;"

# Health check
mysql -u root -h 127.0.0.1 -P 3306 -e "SELECT 1;"
