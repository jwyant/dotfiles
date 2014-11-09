source ~/src/antigen/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh


# Bundles from the default repo declared above.
antigen bundles <<EOBUNDLES

pip

# Guess what to install when running an unknown command.
command-not-found

# Helper for extracting different types of archives.
extract

# Help working with version control systems.
svn
git

# nicoulaj's moar completion files for zsh
zsh-users/zsh-completions src

# ZSH port of Fish shell's history search feature.
zsh-users/zsh-history-substring-search

# Syntax highlighting bundle.
zsh-users/zsh-syntax-highlighting

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
