#!/bin/bash
# Generate an ed25519 SSH key (if missing) and print the public key for GitHub.

set -euo pipefail

SSH_DIR="$HOME/.ssh"
KEY="$SSH_DIR/id_ed25519"
PUB="$KEY.pub"
EMAIL="${GIT_AUTHOR_EMAIL:-ankush4singh@gmail.com}"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ ! -f "$KEY" ]; then
  echo "==> Generating SSH key at $KEY"
  ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY" -N ""
  ok_msg="Created new SSH key"
else
  ok_msg="Using existing SSH key"
fi

chmod 600 "$KEY"
[ -f "$PUB" ] && chmod 644 "$PUB"

if [ -z "${SSH_AUTH_SOCK:-}" ] || ! ssh-add -l &>/dev/null; then
  eval "$(ssh-agent -s)" >/dev/null
fi
ssh-add "$KEY" 2>/dev/null || true

echo ""
echo "==> $ok_msg"
echo ""
echo "Add this public key to GitHub:"
echo "  https://github.com/settings/ssh/new"
echo ""
echo "--- copy below ---"
cat "$PUB"
echo "--- copy above ---"
echo ""
echo "Then test with: ssh -T git@github.com"
