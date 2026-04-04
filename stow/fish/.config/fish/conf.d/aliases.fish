# ls → eza
alias ls='eza -al --color=always --group-directories-first --icons' # preferred listing
alias la='eza -a --color=always --group-directories-first --icons'  # all files and dirs
alias ll='eza -l --color=always --group-directories-first --icons'  # long format
alias lt='eza -aT --color=always --group-directories-first --icons' # tree listing
alias l.="eza -a | grep -e '^\.'"                                     # show only dotfiles

# cat → bat
alias cat "bat --style=plain --paging=never"
alias catp "bat"

# grep → rg
alias grep "rg"

# navigation
alias .. "cd .."
alias ... "cd ../.."
alias .... "cd ../../.."
