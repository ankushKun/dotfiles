#!/bin/bash

export prefix="/Users/ankushsingh"
export dotfiles="$prefix/.dotfiles"

echo " "
echo "---------------"
echo "update dotfiles - `date +'%Y-%m-%d %H:%M:%S'`"

/bin/cd "$dotfiles"

/bin/rm -rf "$dotfiles/old/macOS"
/bin/mv "$dotfiles/macOS" "$dotfiles/old"

/bin/rm -rf "$dotfiles/macOS"
/bin/mkdir "$dotfiles/macOS"

/bin/cp -r "$prefix/.config/nvim/init.lua" "$dotfiles/macOS/init.lua"
/bin/cp -r "$prefix/.config/alacritty/alacritty.yml" "$dotfiles/macOS/alacritty.yml"
/bin/cp -r "$prefix/.zshrc" "$dotfiles/macOS/zshrc"
/bin/cp -r "$prefix/.tmux.conf" "$dotfiles/macOS/tmux.conf"
/bin/cp -r "$prefix/.p10k.zsh" "$dotfiles/macOS/p10k.zsh"
/bin/cp -r "$prefix/.config/mpv" "$dotfiles/macOS/mpv"

git add .
git commit -m "update dotfiles - `date +'%Y-%m-%d %H:%M:%S'`"
git push

echo " "
echo "done"
echo "---------------"

