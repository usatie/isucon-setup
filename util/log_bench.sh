#!/bin/bash
# Configure these values before use
# ISUDIR=/home/isucon/private_isu
# RESDIR=$ISUDIR/results
# SCRIPTDIR=$ISUDIR/scripts
DURATION=70
DATE=$(date +%Y%m%d-%H%M%S)

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
	-o count,method,uri,min,avg,max,sum \
	| tee $RESULTDIR/alp.digest.$DATE
sudo pt-query-digest --explain h=localhost,u=isucon,p=isucon \
	/var/log/mysql/mysql-slow.log \
	| tee $RESULTDIR/slowquery.digest.$DATE
# curl http://localhost:3000/measure | tee $RESULTDIR/measure.digest.$DATE
echo "Finish log_bench.sh"
