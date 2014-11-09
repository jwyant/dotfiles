source ~/.antigen/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh


# Bundles from the default repo declared above.
antigen bundles <<EOBUNDLES

command-not-found
svn
git
zsh-users/zsh-completions src
zsh-users/zsh-history-substring-search
zsh-users/zsh-syntax-highlighting
rsync
pip
rsync
python
history
tmux
vundle

EOBUNDLES

# Load the theme.
#antigen theme robbyrussell
#antigen theme sindresorhus/pure pure
antigen theme gentoo

# Tell antigen that you're done.
antigen apply

# Other stuff
autoload -U zmv
alias mmv='noglob zmv -W'
