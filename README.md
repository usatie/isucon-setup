# isucon-setup

## Set up
0. Update golang to the latest version
```
wget https://go.dev/dl/go1.18.3.linux-amd64.tar.gz
tar -xvf go1.18.3.linux-amd64.tar.gz
rm go1.18.3.linux-amd64.tar.gz
# mv go ~/go
# mv go ~/local/go
# mv go /usr/local/go
```
1. Run `./script/addkey.sh` to add pub keys to ~/.ssh/authorized_keys
2. Run `./script/install.sh` to install useful tools
3. Run `./script/symlink.sh` to setup dotfiles
4. Switch to golang
5. Enable nginx access log
6. Enable MySQL slow log
7. Enable Golang log
8. Enable pprof
9. (Enable najeira/measure)
10. Configure save.sh
11. Run the benchmarker
12. Setup utility variables and aliases
```
export ISUDIR=/home/isucon/private_isu
export RESULTDIR=$ISUDIR/results
export SCRIPTDIR=$ISUDIR/scripts
export PATH=/home/isucon/isucon-setup/script:$PATH

alias isumysql='mysql -u isucon -p'
alias isubench='$SCRIPTDIR/log_bench.sh'
alias isurotate='$SCRIPTDIR/log_rotate.sh'
alias isubuild='$SCRIPTDIR/build.sh'
alias isurestart='$SCRIPTDIR/restart.sh'
alias isursync='$SCRIPTDIR/rsync.sh'
```

## Clean up
1. Disable Golang log
2. Disable MySQL slow log
3. Disable nginx access log
