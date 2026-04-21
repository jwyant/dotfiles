# dotfiles

Cross-platform dotfiles managed by [GNU Stow](https://www.gnu.org/software/stow/). Targets macOS and Linux (Arch/CachyOS, Fedora, Debian/Ubuntu). Dracula theme throughout.

## Tools configured

| Category | Tools |
|---|---|
| Shell | fish, starship |
| Search | eza, bat, fd, ripgrep, fzf, zoxide |
| Dev | uv, direnv |
| Terminal | Ghostty, tmux |
| Git | delta |

## Install

```sh
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script detects your OS, installs all packages via the native package manager, installs JetBrainsMono Nerd Font, deploys configs via stow, and sets fish as your default shell.

## Manual steps after install

- Set `user.name` and `user.email` in `~/.gitconfig`
- Log out and back in for the default shell change to take effect
- On macOS: set Ghostty as your default terminal in System Settings

## Deploying configs

Deploy everything at once:

```sh
cd ~/dotfiles
stow */
```

Each package is also independently deployable:

```sh
cd ~/dotfiles
stow fish       # just fish config
stow starship   # just starship
stow tmux       # just tmux
```
