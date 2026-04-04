# fzf uses terminal ANSI colors (palette set in terminal emulator)
set -gx FZF_DEFAULT_OPTS "\
  --color=16 \
  --color=hl:3,hl+:11 \
  --color=prompt:2,pointer:5,marker:5 \
  --color=spinner:3,header:8,info:3 \
  --height=40% --layout=reverse --border"

set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git"
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -gx FZF_ALT_C_COMMAND "fd --type d --hidden --follow --exclude .git"
