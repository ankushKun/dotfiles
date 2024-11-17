
CONFIG="$HOME/.config"
DOTFILES="$HOME/.dotfiles"

cp -r $DOTFILES/config/* $CONFIG
cp -r $DOTFILES/home/* $HOME

echo "Restored dotfiles"