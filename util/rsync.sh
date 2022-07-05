#!/bin/bash
echo "Start rsync.sh"
CONFDIR=$ISUDIR/conf
sudo rsync -qauh /etc/nginx $CONFDIR
sudo rsync -qauh /etc/mysql $CONFDIR
sudo chown -R isucon:isucon $CONFDIR
echo "Finish rsync.sh"
