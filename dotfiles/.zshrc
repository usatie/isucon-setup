export VISUAL=vim
export EDITOR="$VISUAL"
# export ISUDIR=/home/isucon/private_isu
# export RESDIR=$ISUDIR/results
# export SCRIPTDIR=$ISUDIR/scripts
# export PATH=/home/isucon/isucon-setup/script:$PATH
export ISUDIR=/home/isucon/webapp
export RESULTDIR=$ISUDIR/results
export SCRIPTDIR=$ISUDIR/util
export PATH=$SCRIPTDIR:$PATH

alias isumysql='mysql isucondition -u isucon -p'
# alias isumysql='mysql -u isucon -p isucon'
# alias isubench='sudo /home/isucon/webapp/scripts/bench.sh'
# alias isurotate='sudo /home/isucon/webapp/scripts/log_rotate.sh'
# alias isubuild='sudo /home/isucon/webapp/scripts/build.sh'
# alias isudeploy='sudo /home/isucon/webapp/scripts/deploy.sh'
# alias isursync='sudo /home/isucon/webapp/scripts/rsync.sh'
