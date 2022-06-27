#!/bin/bash

export dotfiles="~/.dotfiles"

echo " "
echo "---------------"
echo "update dotfiles - `date +'%Y-%m-%d %H:%M:%S'`"

/bin/cd "$dotfiles"

/bin/rm -rf "$dotfiles/backup/macOS"
/bin/mv "$dotfiles/macOS" "$dotfiles/backup"

/bin/rm -rf "$dotfiles/macOS"
/bin/mkdir "$dotfiles/macOS"

/bin/cp -r "~/.config/nvim/init.lua" "$dotfiles/macOS/init.lua"
/bin/cp -r "~/.config/alacritty/alacritty.yml" "$dotfiles/macOS/alacritty.yml"
/bin/cp -r "~/.zshrc" "$dotfiles/macOS/zshrc"
/bin/cp -r "~/.tmux.conf" "$dotfiles/macOS/tmux.conf"
/bin/cp -r "~/.p10k.zsh" "$dotfiles/macOS/p10k.zsh"

git add .
git commit -m "update dotfiles - `date +'%Y-%m-%d %H:%M:%S'`"
git push

echo " "
echo "done"
echo "---------------"

