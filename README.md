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
`/etc/nginx/`
```
log_format ltsv "time:$time_local"
	"\thost:$remote_addr"
	"\tforwardedfor:$http_x_forwarded_for"
	"\treq:$request"
	"\tstatus:$status"
	"\tmethod:$request_method"
	"\turi:$request_uri"
	"\tsize:$body_bytes_sent"
	"\treferer:$http_referer"
	"\tua:$http_user_agent"
	"\treqtime:$request_time"
	"\tcache:$upstream_http_x_cache"
	"\truntime:$upstream_http_x_runtime"
	"\tapptime:$upstream_response_time"
	"\tvhost:$host";
access_log /var/log/nginx/access.log ltsv;
```
6. Enable MySQL slow log
`/etc/mysql/`
``` 
slow_query_log         = ON
slow_query_log_file    = /var/log/mysql/mysql-slow.log
long_query_time        = 0
```
7. Enable Golang log
8. Enable pprof
9. (Enable najeira/measure)
10. Configure log_bench.sh
11. Run the benchmarker
12. Setup utility variables and aliases
```
export ISUDIR=/home/isucon/private_isu
export RESULTDIR=$ISUDIR/results
export SCRIPTDIR=$ISUDIR/scripts
export PATH=/home/isucon/isucon-setup/script:$PATH

alias isumysql='mysql isucondition -u isucon -p'
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
