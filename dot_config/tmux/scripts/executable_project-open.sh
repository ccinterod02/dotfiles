#!/usr/bin/env bash
set -uo pipefail

REPOS="$HOME/repos"
AGENT="${PROJECT_AGENT:-claude}"

list_dirs() {
  {
    find "$REPOS" -mindepth 1 -maxdepth 1 -type d ! -name '.*' 2>/dev/null | sort
    command -v zoxide >/dev/null && zoxide query -l 2>/dev/null
  } | awk -v home="$HOME" '!seen[$0]++ { short = $0; sub("^" home, "~", short); print $0 "\t" short }'
}

if [ $# -ge 1 ]; then
  dir="$(realpath -- "$1")" || exit 1
else
  sel="$(list_dirs | fzf --reverse --prompt 'proyecto> ' \
          --delimiter '\t' --with-nth 2 \
          --preview 'ls -A --color=always {1}' --preview-window 'right,50%')" || exit 0
  dir="${sel%%$'\t'*}"
fi
[ -d "$dir" ] || { tmux display-message "No existe: $dir"; exit 1; }

session="$(tmux display-message -p '#{session_id}')"

existing="$(tmux list-panes -s -t "$session" -F "#{window_id}	#{pane_current_path}" |
  awk -F '\t' -v d="$dir" '$2 == d { print $1; exit }')"
if [ -n "$existing" ]; then
  tmux select-window -t "$existing"
  exit 0
fi

left="$(tmux new-window -P -F '#{pane_id}' -t "$session:" -n "$(basename "$dir")" -c "$dir")"
tmux split-window -h -t "$left" -c "$dir"
tmux send-keys -t "$left" "$AGENT" Enter
tmux select-pane -t "$left"
