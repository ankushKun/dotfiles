#!/bin/sh

inactive_style='fg=#7a809b,bg=default'
active_style='default'

# Walk every pane across all sessions and apply a pane-local style. This avoids
# using a global window-style that can dim the active pane too.
tmux list-panes -a -F '#{pane_id} #{pane_active} #{window_panes}' |
while IFS=' ' read -r pane active pane_count; do
  [ -n "$pane" ] || continue

  if [ "${pane_count:-0}" -le 1 ] || [ "$active" = "1" ]; then
    # Reset active panes and single-pane windows so apps keep their colors.
    tmux set-option -q -p -t "$pane" window-style "$active_style"
  else
    # Muted foreground for inactive panes; background stays transparent/default.
    tmux set-option -q -p -t "$pane" window-style "$inactive_style"
  fi
done
