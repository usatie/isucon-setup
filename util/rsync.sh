#!/bin/bash
echo "Start rsync.sh"
sudo rsync -qauh /etc $HOME
sudo chown -R isucon:isucon $HOME/etc
echo "Finish rsync.sh"
