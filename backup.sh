#!/bin/bash

cd ~/Developer/dotfiles

rm -rf ~/Developer/dotfiles/backup/macOS/*
mv ~/Developer/dotfiles/macOS/* ~/Developer/dotfiles/backup/macOS/

rm -rf ~/Developer/dotfiles/macOS/*

cp -r ~/.config/nvim ~/Developer/dotfiles/macOS/
cp -r ~/.config/alacritty ~/Developer/dotfiles/macOS/
cp -r ~/.zshrc ~/Developer/dotfiles/macOS/zshrc
cp -r ~/.tmux.conf ~/Developer/dotfiles/macOS/tmux.conf

git add .
git commit -m "update dotfiles - `date +'%Y-%m-%d %H:%M:%S'`"
git push
