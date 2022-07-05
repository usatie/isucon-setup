#!/bin/bash
sudo apt update
sudo apt install net-tools -y
sudo apt install iotop -y
sudo apt install percona-toolkit -y # pt-query-digest
sudo apt install dstat -y
sudo apt install apache2-utils -y # ab
sudo apt install unzip
sudo apt install zsh
# alp
wget https://github.com/tkuchiki/alp/releases/download/v1.0.9/alp_linux_amd64.zip && unzip alp_linux_amd64.zip && sudo install ./alp /usr/local/bin/alp && rm alp_linux_amd64.zip alp
# vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# vim PlugInstall
vim +PlugInstall +qa
# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
