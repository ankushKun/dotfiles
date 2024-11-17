
CONFIG="$HOME/.config"
DOTFILES="$HOME/.dotfiles"

cp -r $DOTFILES/config/* $CONFIG
cp $DOTFILES/home/.* $HOME

echo "Restored dotfiles"