export VISUAL=vim
export EDITOR="$VISUAL"
plugins+=(zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh
source $HOME/env.sh

echo '[WARNING] Edit dotfiles/.zshrc to configure $APPDIR'
# export APPDIR=$HOME/webapp

echo '[WARNING] Edit dotfiles/.zshrc to configure $RESULTDIR'
# export RESULTDIR=$HOME/results

echo '[WARNING] Edit dotfiles/.zshrc to configure $SCRIPTDIR'
# export SCRIPTDIR=$HOME/isucon-setup/util
#
echo '[WARNING] Edit dotfiles/.zshrc to configure $SQLDIR'
# export SQLDIR=$HOME/isucon-setup/sql

echo '[WARNING] Edit dotfiles/.zshrc to configure $PATH'
# export PATH=$SCRIPTDIR:$PATH

echo '[WARNING] Edit dotfiles/.zshrc to configure alias isumysql'
# alias isumysql='source $HOME/env.sh && mysql $MYSQL_DBNAME -u $MYSQL_USER -p'

echo '[WARNING] Edit dotfiles/.zshrc to configure $PATH and $GOROOT'
# export PATH=/home/isucon/local/go/bin:/home/isucon/go/bin:$PATH
# export GOROOT=/home/isucon/local/go
