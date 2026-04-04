set -gx EDITOR vim

# Initialize integrations
starship init fish | source
zoxide init fish | source
direnv hook fish | source
