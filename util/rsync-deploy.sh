#!/bin/bash
sudo rsync -qauh --no-o --no-g $HOME/etc/nginx /etc
sudo rsync -qauh --no-o --no-g $HOME/etc/mysql /etc
