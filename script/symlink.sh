#!/bin/bash
# https://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself
REPOPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1; cd .. >/dev/null 2>&1; pwd -P )"

# .gitconfig
ln -si $REPOPATH/dotfiles/.gitconfig ~/.gitconfig

# .vimrc
ln -si $REPOPATH/dotfiles/.vimrc ~/.vimrc

# .bashrc
if grep -q "source $REPOPATH/dotfiles/.bashrc" ~/.bashrc; then
	echo "Already added to ~/.bashrc"
else
	echo "source $REPOPATH/dotfiles/.bashrc" >> ~/.bashrc
fi

# .zshrc
if grep -q "source $REPOPATH/dotfiles/.zshrc" ~/.zshrc; then
	echo "Already added to ~/.zshrc"
else
	echo "source $REPOPATH/dotfiles/.zshrc" >> ~/.zshrc
fi
