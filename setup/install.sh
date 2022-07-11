#!/bin/bash
sudo apt update
sudo apt install net-tools -y
sudo apt install iotop -y
sudo apt install percona-toolkit -y # pt-query-digest
sudo apt install dstat -y
sudo apt install apache2-utils -y # ab
sudo apt install unzip
# alp
wget https://github.com/tkuchiki/alp/releases/download/v1.0.9/alp_linux_amd64.zip \
	&& unzip alp_linux_amd64.zip \
	&& sudo install ./alp /usr/local/bin/alp \
	&& rm alp_linux_amd64.zip alp
# vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# vim PlugInstall
vim +PlugInstall +qa
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
# go goimports
go install golang.org/x/tools/cmd/goimports@latest
# go pprof
go install github.com/google/pprof@latest
# trdsql
wget https://github.com/noborus/trdsql/releases/download/v0.10.0/trdsql_v0.10.0_linux_amd64.zip \
	&& unzip trdsql_v0.10.0_linux_amd64.zip \
	&& sudo install ./trdsql_v0.10.0_linux_amd64/trdsql /usr/local/bin/trdsql \
	&& rm -rf trdsql_v0.10.0_linux_amd64.zip trdsql_v0.10.0_linux_amd64
