set -gx EDITOR vim

# Source conf.d files (fish auto-loads these at startup, but this allows manual re-sourcing)
for f in ~/.config/fish/conf.d/*.fish
    source $f
end

# Initialize integrations
starship init fish | source
zoxide init fish | source
direnv hook fish | source
