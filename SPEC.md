# Dotfiles Specification

## Overview

Cross-platform dotfiles repo managed by GNU Stow, targeting macOS and Linux (Arch/CachyOS, Fedora, Debian/Ubuntu). Windows is a distant nice-to-have (winget only, no WSL assumed). The Dracula theme is applied consistently across all tools. Ghostty is the terminal emulator. Nerd Fonts are always available.

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
│   │       │   ├── dracula.fish       # Dracula color variables for fish
│   │       │   └── path.fish
│   │       └── functions/
│   │           └── fish_greeting.fish  # suppress or customize greeting
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
│   │       └── ignore                 # global gitignore
│   ├── bat/
│   │   └── .config/bat/
│   │       └── config
│   ├── fzf/
│   │   └── .config/fish/conf.d/
│   │       └── fzf.fish               # fzf keybindings + Dracula colors
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
| Color theme | Dracula everywhere |
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

Some packages have different names across managers. The script must maintain a map:

```
# Example: package_name → [brew, pacman, dnf, apt, winget]
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
```

Note: `fd` is `fd-find` on Debian/Ubuntu and the binary is `fdfind`. The install script should create a symlink or fish alias `fd → fdfind` on Debian/Ubuntu. Similarly `bat` may be `batcat` on older Debian — handle with alias.

### Install Flow

1. Detect OS
2. Install prerequisites (git, curl, stow)
3. Install Nerd Fonts (JetBrainsMono) — download from GitHub releases to `~/.local/share/fonts` (Linux) or `~/Library/Fonts` (macOS), then `fc-cache -fv` on Linux
4. Install all packages via native package manager
5. Set fish as default shell (`chsh -s $(which fish)`)
6. Run `stow` for each config directory: `cd dotfiles/stow && stow -t ~ fish starship ghostty tmux git bat fzf direnv`
7. Print summary of what was installed and any manual steps needed

### Idempotency

- Check if a tool is already installed before installing (`command -v <tool>`)
- Stow with `--restow` flag to handle re-runs cleanly
- Don't clobber existing configs without asking — if a target file exists and isn't a symlink from stow, warn the user and skip (or offer backup)

## Configuration Details

### Starship (starship.toml)

Single-line prompt. Left side only. Must show:

1. **OS icon** — Nerd Font icon for the current OS (  macOS,  Arch,  Fedora,  Debian,  Ubuntu,  Windows)
2. **user@hostname** — dimmed when local, highlighted when SSH
3. **Directory** — truncated to 3 components, home replaced with ~
4. **Git branch + status** — branch name, dirty/clean indicator, ahead/behind
5. **Language/environment** — show active python venv, node version, rust version, go version etc. ONLY when relevant files are detected in current directory
6. **Command duration** — show if last command took >2 seconds
7. **Prompt character** — `❯` green on success, red on error

Use the Dracula palette:

```toml
[palettes.dracula]
background = "#282a36"
current_line = "#44475a"
foreground = "#f8f8f2"
comment = "#6272a4"
cyan = "#8be9fd"
green = "#50fa7b"
orange = "#ffb86c"
pink = "#ff79c6"
purple = "#bd93f9"
red = "#ff5555"
yellow = "#f1fa8c"
```

The prompt format string should be a single line, compact, no newlines between sections. Example output:

```
 user@host ~/projects/myapp  main ✚  v3.12  2s ❯
```

### Fish Shell (config.fish)

- Source starship: `starship init fish | source`
- Source zoxide: `zoxide init fish | source`
- Source direnv: `direnv hook fish | source`
- Set fzf Dracula colors via `FZF_DEFAULT_OPTS`
- Set `EDITOR` to user preference (leave as `vim` as sane default, easily changed)
- Suppress fish greeting

### Fish Aliases (aliases.fish)

```fish
# ls → eza
alias ls "eza --icons --group-directories-first"
alias ll "eza -la --icons --group-directories-first --git"
alias la "eza -a --icons --group-directories-first"
alias lt "eza --tree --level=2 --icons"

# cat → bat
alias cat "bat --style=plain --paging=never"
alias catp "bat"

# find → fd (handle Debian fd-find)
# grep → rg
alias grep "rg"

# navigation
alias .. "cd .."
alias ... "cd ../.."
alias .... "cd ../../.."
```

### Ghostty Config

```
theme = Dracula
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
```

macOS-specific (Ghostty handles this natively):
```
macos-titlebar-style = tabs
macos-option-as-alt = true
```

### tmux (.tmux.conf)

- Set default terminal to support true color: `set -g default-terminal "tmux-256color"` and `set -ga terminal-overrides ",*256col*:Tc"`
- Dracula-themed status bar (manually defined colors, no plugin dependency)
- Status bar: left = session name, right = hostname + date/time
- Prefix key: `C-a` (rebind from `C-b`)
- Vi-style pane navigation: `bind h/j/k/l` for pane movement
- Mouse support enabled
- Start window/pane numbering at 1
- Reasonable history limit (10000)
- Reload config binding: `prefix + r`

### bat Config

```
--theme="Dracula"
--italic-text=always
--style=numbers,changes
```

### fzf Dracula Colors (fzf.fish)

```fish
set -gx FZF_DEFAULT_OPTS "\
  --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 \
  --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 \
  --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 \
  --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4 \
  --height=40% --layout=reverse --border"
set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git"
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -gx FZF_ALT_C_COMMAND "fd --type d --hidden --follow --exclude .git"
```

### Git Config (.gitconfig)

- Set delta as the pager: `[core] pager = delta`
- Delta config section with Dracula theme, line numbers, side-by-side
- Sensible defaults: `pull.rebase = true`, `init.defaultBranch = main`, `push.autoSetupRemote = true`
- Leave `user.name` and `user.email` as placeholders for the user to fill in

### Global Gitignore

Standard ignores: `.DS_Store`, `Thumbs.db`, `*.swp`, `*.swo`, `.idea/`, `.vscode/`, `*.pyc`, `__pycache__/`, `.env`, `.direnv/`, `node_modules/`

### direnv (direnv.toml)

```toml
[global]
load_dotenv = true
```

## Windows Notes (Low Priority)

- Only tools with winget packages will be installable
- tmux is not available on Windows natively — skip
- Ghostty config path on Windows: `%APPDATA%\ghostty\config`
- Fish is not native on Windows — the Windows path would use PowerShell + starship as a minimal fallback
- The install script should gracefully skip unavailable tools on Windows and print what was skipped

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
