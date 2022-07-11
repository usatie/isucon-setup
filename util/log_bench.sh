#!/bin/bash
DURATION=70
DATE=$(date +%Y%m%d-%H%M%S)

source $HOME/env.sh
echo "Start log_bench.sh"

mkdir -p $RESULTDIR
LINES=20 top -b -d 1 -n $DURATION -w > $RESULTDIR/top.$DATE &
sudo iotop -b -d 1 -n $DURATION -oaP > $RESULTDIR/iotop.$DATE &
dstat -tcdm --tcp -n 1 $DURATION > $RESULTDIR/dstat.$DATE &
go tool pprof -raw -seconds $DURATION http://localhost:3000/debug/pprof/profile >/dev/null &

echo "Ready to run the benchmarker"

sleep $DURATION

sudo alp ltsv --file /var/log/nginx/access.log -r --sort=sum \
	-m "/api/condition/\w+" \
	-o count,1xx,2xx,3xx,4xx,5xx,method,uri,min,avg,max,sum \
	| tee $RESULTDIR/alp.digest.$DATE
sudo pt-query-digest --explain h=$MYSQL_HOST,u=$MYSQL_USER,p=$MYSQL_PASS \
	/var/log/mysql/mysql-slow.log \
	| tee $RESULTDIR/slowquery.digest.$DATE
sudo trdsql -driver mysql -dsn "$MYSQL_USER:$MYSQL_PASS@/$MYSQL_DBNAME" \
	-oh -iltsv $(cat $SQLDIR/access.sql) \
	| tee $RESULTDIR/trdsql.digest.$DATE
# curl http://localhost:3000/measure | tee $RESULTDIR/measure.digest.$DATE
echo "Finish log_bench.sh"
