# isucon-setup

## Set up
1. Update golang to the latest version
```
wget https://go.dev/dl/go1.18.3.linux-amd64.tar.gz
tar -xvf go1.18.3.linux-amd64.tar.gz
rm go1.18.3.linux-amd64.tar.gz
# mv go ~/go
# mv go ~/local/go
# mv go /usr/local/go
```
2. Run `./script/addkey.sh` to add pub keys to ~/.ssh/authorized_keys
3. Run `./script/install.sh` to install useful tools
4. Run `./script/symlink.sh` to setup dotfiles
5. Switch to golang
6. git init
7. Enable nginx access log
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
8. Enable MySQL slow log
`/etc/mysql/`
``` 
slow_query_log         = ON
slow_query_log_file    = /var/log/mysql/mysql-slow.log
long_query_time        = 0
```
9. Enable Golang log
10. Enable pprof
`echo`
```
import "net/http/pprof"

func main () {
    e := echo.New()

    pprofGroup := e.Group("/debug/pprof")
    pprofGroup.Any("/cmdline", echo.WrapHandler(http.HandlerFunc(pprof.Cmdline)))
    pprofGroup.Any("/profile", echo.WrapHandler(http.HandlerFunc(pprof.Profile)))
    pprofGroup.Any("/symbol", echo.WrapHandler(http.HandlerFunc(pprof.Symbol)))
    pprofGroup.Any("/trace", echo.WrapHandler(http.HandlerFunc(pprof.Trace)))
    pprofGroup.Any("/*", echo.WrapHandler(http.HandlerFunc(pprof.Index)))
}
```
`goji`
```
import "net/http/pprof"

func main () {
    mux := goji.NewMux()

	mux.HandleFunc(pat.Get("/debug/pprof/cmdline"), pprof.Cmdline)
	mux.HandleFunc(pat.Get("/debug/pprof/profile"), pprof.Profile)
	mux.HandleFunc(pat.Get("/debug/pprof/symbol"), pprof.Symbol)
	mux.HandleFunc(pat.Get("/debug/pprof/trace"), pprof.Trace)
	mux.HandleFunc(pat.Get("/debug/pprof/*"), pprof.Index)
}
```
11. (Enable najeira/measure)
12. Configure log_bench.sh
13. Run the benchmarker
14. Setup utility variables and aliases
```
export ISUDIR=/home/isucon/webapp
export RESULTDIR=$ISUDIR/results
export SCRIPTDIR=/home/isucon/isucon-setup/script
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
