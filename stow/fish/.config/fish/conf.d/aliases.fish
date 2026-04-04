# ls → eza
alias ls "eza --icons --group-directories-first"
alias ll "eza -la --icons --group-directories-first --git"
alias la "eza -a --icons --group-directories-first"
alias lt "eza --tree --level=2 --icons"

# cat → bat
alias cat "bat --style=plain --paging=never"
alias catp "bat"

# grep → rg
alias grep "rg"

# navigation
alias .. "cd .."
alias ... "cd ../.."
alias .... "cd ../../.."
