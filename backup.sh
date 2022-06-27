#!/bin/bash

dotfiles="~/.dotfiles"

echo " "
echo "---------------"
echo "update dotfiles - `date +'%Y-%m-%d %H:%M:%S'`"

cd $dotfiles

rm -rf $dotfiles/backup/macOS
mv $dotfiles/macOS $dotfiles/backup/

rm -rf $dotfiles/macOS
mkdir $dotfiles/macOS

/bin/cp -r ~/.config/nvim $dotfiles/macOS/
/bin/cp -r ~/.config/alacritty $dotfiles/macOS/
/bin/cp -r ~/.zshrc $dotfiles/macOS/zshrc
/bin/cp -r ~/.tmux.conf $dotfiles/macOS/tmux.conf
/bin/cp -r ~/.p10k.zsh $dotfiles/macOS/p10k.zsh

git add .
git commit -m "update dotfiles - `date +'%Y-%m-%d %H:%M:%S'`"
git push

echo " "
echo "done"
echo "---------------"

