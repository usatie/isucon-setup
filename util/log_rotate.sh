#!/bin/bash

# DATE=$(date +%Y%m%d-%H%M%S)
# mv /var/log/nginx/access.log /var/log/nginx/access.log.$DATE
# mv /var/log/mysql/mysql-slow.log /var/log/mysql/mysql-slow.log.$DATE

echo "Start log_rotate.sh"
sudo truncate /var/log/nginx/access.log -s 0
sudo truncate /var/log/nginx/error.log -s 0
sudo truncate /var/log/mysql/mysql-slow.log -s 0
sudo truncate /var/log/mysql/error.log -s 0

sudo nginx -s reopen
sudo systemctl restart mysql
echo "Finish log_rotate.sh"
