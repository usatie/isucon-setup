#!/bin/bash
echo "Start rsync.sh"
rsync /etc/nginx/sites-available/isucon.conf conf/isucon.conf
rsync /etc/mysql/mysql.conf.d/mysqld.cnf conf/mysqld.cnf
echo "Finish rsync.sh"
