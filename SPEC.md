# Dotfiles Specification

## Overview

Cross-platform dotfiles repo managed by GNU Stow, targeting macOS and Linux (Arch/CachyOS, Fedora, Debian/Ubuntu). Windows is a distant nice-to-have (winget only, no WSL assumed). The terminal emulator (Ghostty) is the single source of truth for colors — all other tools use ANSI color names only, never hex codes.

## Repository Structure

```
dotfiles/
├── install.sh              # Main bootstrap script
├── README.md
├── CLAUDE.md
├── stow/
│   ├── fish/
│   │   └── .config/fish/
│   │       ├── config.fish
│   │       ├── conf.d/
│   │       │   ├── aliases.fish
│   │       │   └── path.fish
│   │       └── functions/
│   │           └── fish_greeting.fish
│   ├── starship/
│   │   └── .config/starship.toml
│   ├── ghostty/
│   │   └── .config/ghostty/
│   │       └── config
│   ├── tmux/
│   │   └── .tmux.conf
│   ├── git/
│   │   ├── .gitconfig
│   │   └── .config/git/
│   │       └── ignore
│   ├── bat/
│   │   └── .config/bat/
│   │       └── config
│   ├── fzf/
│   │   └── .config/fish/conf.d/
│   │       └── fzf.fish
│   └── direnv/
│       └── .config/direnv/
│           └── direnv.toml
```

## Tool Inventory

### Shell & Prompt
| Tool | Purpose | Config location |
|------|---------|-----------------|
| fish | Default shell | `~/.config/fish/` |
| starship | Cross-shell prompt | `~/.config/starship.toml` |

### Navigation & Search
| Tool | Purpose | Replaces |
|------|---------|----------|
| eza | Modern ls with icons, git, tree | ls |
| bat | Syntax-highlighted cat | cat |
| fd | Fast find alternative | find |
| ripgrep (rg) | Fast grep alternative | grep |
| fzf | Fuzzy finder for everything | — |
| zoxide | Smart cd that learns | cd |

### Dev Environment
| Tool | Purpose |
|------|---------|
| uv | Python package/project manager |
| direnv | Per-directory env vars |

### Terminal & Multiplexer
| Tool | Purpose |
|------|---------|
| ghostty | GPU-accelerated terminal emulator |
| tmux | Terminal multiplexer |

### Infrastructure
| Tool | Purpose |
|------|---------|
| stow | Symlink manager for dotfiles |

### Theme & Fonts
| Component | Choice |
|-----------|--------|
| Color theme | Set in terminal emulator only (Ghostty built-in theme switcher). All other tools use ANSI color names. |
| Font | JetBrainsMono Nerd Font (primary), FiraCode Nerd Font (fallback) |

## Install Script Behavior

### OS Detection

```
detect_os() → "macos" | "arch" | "fedora" | "debian" | "ubuntu" | "windows" | "unknown"
```

- macOS: check `uname -s` = Darwin
- Linux: parse `/etc/os-release` for ID field (arch, cachyos→arch, fedora, debian, ubuntu)
- CachyOS is Arch-based, use pacman
- Windows: check for MINGW/MSYS or `$OS` = Windows_NT

### Package Manager Mapping

| OS | Manager | Install command |
|----|---------|-----------------|
| macOS | brew | `brew install <pkg>` |
| Arch/CachyOS | pacman | `sudo pacman -S --noconfirm <pkg>` |
| Fedora | dnf | `sudo dnf install -y <pkg>` |
| Debian/Ubuntu | apt | `sudo apt install -y <pkg>` |
| Windows | winget | `winget install <pkg>` |

### Package Name Mapping

```
fish        → [fish, fish, fish, fish, —]
bat         → [bat, bat, bat, bat, sharkdp.bat]
fd          → [fd, fd, fd, fd-find, sharkdp.fd]
ripgrep     → [ripgrep, ripgrep, ripgrep, ripgrep, BurntSushi.ripgrep.MSVC]
eza         → [eza, eza, eza, eza, —]
fzf         → [fzf, fzf, fzf, fzf, junegunn.fzf]
zoxide      → [zoxide, zoxide, zoxide, zoxide, ajeetdsouza.zoxide]
starship    → [starship, starship, starship, starship, Starship.Starship]
tmux        → [tmux, tmux, tmux, tmux, —]
stow        → [stow, stow, stow, stow, —]
direnv      → [direnv, direnv, direnv, direnv, —]
uv          → [uv, uv, uv, uv, —]
jq          → [jq, jq, jq, jq, jqlang.jq]
delta       → [git-delta, git-delta, git-delta, git-delta, —]
```

Note: `fd` is `fd-find` on Debian/Ubuntu and the binary is `fdfind`. Create a symlink `fd → fdfind`. Similarly `bat` may be `batcat` on older Debian — handle with symlink.

### Install Flow

1. Detect OS
2. Install prerequisites (git, curl, stow)
3. Install Nerd Fonts (JetBrainsMono) — download from GitHub releases to `~/.local/share/fonts` (Linux) or `~/Library/Fonts` (macOS), then `fc-cache -fv` on Linux
4. Install all packages via native package manager
5. Set fish as default shell (`chsh -s $(which fish)`)
6. Run `stow` for each config directory: `cd dotfiles/stow && stow -t ~ fish starship ghostty tmux git bat fzf direnv`
7. On macOS: warn if `~/Library/Application Support/com.mitchellh.ghostty/config` exists as a real file
8. Print summary of what was installed and any manual steps needed

### Idempotency

- Check if a tool is already installed before installing (`command -v <tool>`)
- Stow with `--restow` flag to handle re-runs cleanly
- Don't clobber existing configs without asking — if a target file exists and isn't a symlink from stow, warn the user and skip (or offer backup)

## Configuration Details

### Starship (starship.toml)

Single-line prompt. Left side only. Format:

```
[SSH icon] [OS icon] user@host  ~/dir   branch !1 ❯
```

- SSH icon: only shown when `$SSH_CONNECTION` is set (via `[env_var.SSH_CONNECTION]`)
- OS icon: via `[os]` module with `disabled = false` and full `[os.symbols]` table
- Nerd Font icons set via `symbol` field in each module — sourced from the official `nerd-font-symbols.toml` preset (never typed/generated directly)
- **ANSI color names only** — no hex, no palette. Use: `bold red`, `bold green`, `bold cyan`, `bold magenta`, `bold yellow`, `bold white`, `bold blue`
- Language/env modules (python, nodejs, rust, golang, ruby, java, etc.) only shown when relevant files detected

### Fish Shell (config.fish)

- Source starship: `starship init fish | source`
- Source zoxide: `zoxide init fish | source`
- Source direnv: `direnv hook fish | source`
- Explicitly source `~/.config/fish/conf.d/*.fish` to support manual `source config.fish`
- Set `EDITOR` to `vim`

### Fish Aliases (aliases.fish)

```fish
alias ls='eza -al --color=always --group-directories-first --icons'
alias la='eza -a --color=always --group-directories-first --icons'
alias ll='eza -l --color=always --group-directories-first --icons'
alias lt='eza -aT --color=always --group-directories-first --icons'
alias l.="eza -a | grep -e '^\.'"

alias cat "bat --style=plain --paging=never"
alias catp "bat"
alias grep "rg"
alias .. "cd .."
alias ... "cd ../.."
alias .... "cd ../../.."
```

### Ghostty Config

```
font-family = JetBrainsMono Nerd Font
font-size = 14
font-thicken = true
minimum-contrast = 1.3
cursor-style = block
cursor-style-blink = false
mouse-hide-while-typing = true
window-padding-x = 8
window-padding-y = 4
confirm-close-surface = false

macos-titlebar-style = tabs
macos-option-as-alt = true

# Auto Theme
config-file = ?auto/theme.ghostty
```

No hardcoded `theme =` or `palette =` entries. Theme is managed via Ghostty's built-in theme switcher which writes to `auto/theme.ghostty`.

### tmux (.tmux.conf)

- Set default terminal to support true color
- ANSI color references (`colour0`–`colour15`) in status bar — no hex codes
- Status bar: session name (magenta/colour5), hostname + time (bright_black/colour8)
- Prefix key: `C-a`, vi-style pane navigation, mouse support, windows/panes start at 1

### bat Config

```
--theme="ansi"
--italic-text=always
--style=numbers,changes
```

### fzf (fzf.fish)

Layout only — no color flags:

```fish
set -gx FZF_DEFAULT_OPTS "--height=40% --layout=reverse --border"
set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git"
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -gx FZF_ALT_C_COMMAND "fd --type d --hidden --follow --exclude .git"
```

### Git Config (.gitconfig)

- Delta as pager with `syntax-theme = ansi`, line numbers, side-by-side
- `pull.rebase = true`, `init.defaultBranch = main`, `push.autoSetupRemote = true`
- Placeholder `user.name` and `user.email`

### Global Gitignore

`.DS_Store`, `Thumbs.db`, `*.swp`, `*.swo`, `.idea/`, `.vscode/`, `*.pyc`, `__pycache__/`, `.env`, `.envrc`, `.direnv/`, `node_modules/`

### direnv (direnv.toml)

```toml
[global]
load_dotenv = true
```

## Windows Notes (Low Priority)

- Only tools with winget packages will be installable
- tmux is not available on Windows natively — skip
- Ghostty config path on Windows: `%APPDATA%\ghostty\config`
- Fish is not native on Windows — skip
- The install script should gracefully skip unavailable tools on Windows

## Testing Expectations

- The install script should be testable in a Docker container for each Linux distro
- Each stow package should be independently stow-able
- Starship config should render correctly with `starship explain` and `starship timings`

## Out of Scope

- Editor configs (neovim, vim, etc.)
- Desktop environment / window manager configs
- SSH configs
- Cloud CLI tools
- Any tool not listed in the Tool Inventory above
- Hardcoded color palettes in tool configs
