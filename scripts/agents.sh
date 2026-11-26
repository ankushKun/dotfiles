#!/bin/bash
# Sync tracked Claude Code settings with the live ~/.claude/settings.json.
# Only keys present in agents/claude-settings.json are managed. Keys Claude
# writes for this machine (autoMode, permissions) stay local and never hit git.
#
#   agents.sh apply   merge the tracked keys into the live file (default)
#   agents.sh pull    copy live values of tracked keys back into the repo
#   agents.sh check   exit 1 if the live file differs on any tracked key

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
BASE="$DOTFILES/agents/claude-settings.json"
LIVE="$HOME/.claude/settings.json"

mkdir -p "$HOME/.claude"
[ -f "$LIVE" ] || echo '{}' >"$LIVE"

case "${1:-apply}" in
  apply)
    merged=$(jq -s '.[0] * .[1]' "$LIVE" "$BASE")
    printf '%s\n' "$merged" >"$LIVE"
    echo "Claude settings: tracked keys applied"
    ;;
  pull)
    pulled=$(jq -s '.[1] as $l | .[0] | with_entries(if ($l | has(.key)) then .value = $l[.key] else . end)' "$BASE" "$LIVE")
    printf '%s\n' "$pulled" >"$BASE"
    echo "Claude settings: live values pulled into $BASE"
    ;;
  check)
    jq -e -s '(.[0] * .[1]) == .[0]' "$LIVE" "$BASE" >/dev/null
    ;;
  *)
    echo "usage: $0 [apply|pull|check]" >&2
    exit 2
    ;;
esac
