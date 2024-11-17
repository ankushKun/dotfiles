
CONFIG="$HOME/.config"
DOTFILES="$HOME/.dotfiles"

backupFile(){
    source_path=$1
    destination_path=$2

    if [ -f $source_path ]; then
        cp $source_path $destination_path
        echo "Backed up $source_path to $destination_path"
    fi
}

# Folders
backupFile "$CONFIG/kitty" "$DOTFILES/config"
backupFile "$CONFIG/alacritty" "$DOTFILES/config"
backupFile "$CONFIG/nvim" "$DOTFILES/config"
backupFile "$CONFIG/lvim" "$DOTFILES/config"

# files
backupFile "$HOME/.zshrc" "$DOTFILES/home/.zshrc"
backupFile "$HOME/.tmux.conf" "$DOTFILES/home/.tmux.conf"
backupFile "$HOME/.p10k.zsh" "$DOTFILES/home/.p10k.zsh"