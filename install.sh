#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_DIR="$DOTFILES_DIR/stow"

# ── Colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

info()    { echo -e "${GREEN}[dotfiles]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[dotfiles]${RESET} $*"; }
error()   { echo -e "${RED}[dotfiles]${RESET} $*" >&2; }

# ── OS Detection ──────────────────────────────────────────────────────────────
detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos"; return ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows"; return ;;
    esac
    if [ -f /etc/os-release ]; then
        local id
        id="$(. /etc/os-release && echo "${ID:-unknown}")"
        case "$id" in
            arch|cachyos|endeavouros|manjaro) echo "arch" ;;
            fedora|rhel|centos) echo "fedora" ;;
            debian) echo "debian" ;;
            ubuntu|pop|linuxmint) echo "ubuntu" ;;
            *) echo "unknown" ;;
        esac
    else
        echo "unknown"
    fi
}

OS="$(detect_os)"
info "Detected OS: $OS"

# ── Package name map ──────────────────────────────────────────────────────────
# Arrays indexed by: 0=brew 1=pacman 2=dnf 3=apt 4=winget
pkg_brew()   { local -n _p=$1; echo "${_p[0]}"; }
pkg_pacman() { local -n _p=$1; echo "${_p[1]}"; }
pkg_dnf()    { local -n _p=$1; echo "${_p[2]}"; }
pkg_apt()    { local -n _p=$1; echo "${_p[3]}"; }
pkg_winget() { local -n _p=$1; echo "${_p[4]}"; }

declare -A PKG_fish=(    [0]=fish       [1]=fish       [2]=fish       [3]=fish       [4]="" )
declare -A PKG_starship=([0]=starship   [1]=starship   [2]=starship   [3]=starship   [4]=Starship.Starship )
declare -A PKG_eza=(     [0]=eza        [1]=eza        [2]=eza        [3]=eza        [4]="" )
declare -A PKG_bat=(     [0]=bat        [1]=bat        [2]=bat        [3]=bat        [4]=sharkdp.bat )
declare -A PKG_fd=(      [0]=fd         [1]=fd         [2]=fd-find    [3]=fd-find    [4]=sharkdp.fd )
declare -A PKG_ripgrep=( [0]=ripgrep    [1]=ripgrep    [2]=ripgrep    [3]=ripgrep    [4]=BurntSushi.ripgrep.MSVC )
declare -A PKG_fzf=(     [0]=fzf        [1]=fzf        [2]=fzf        [3]=fzf        [4]=junegunn.fzf )
declare -A PKG_zoxide=(  [0]=zoxide     [1]=zoxide     [2]=zoxide     [3]=zoxide     [4]=ajeetdsouza.zoxide )
declare -A PKG_tmux=(    [0]=tmux       [1]=tmux       [2]=tmux       [3]=tmux       [4]="" )
declare -A PKG_stow=(    [0]=stow       [1]=stow       [2]=stow       [3]=stow       [4]="" )
declare -A PKG_direnv=(  [0]=direnv     [1]=direnv     [2]=direnv     [3]=direnv     [4]="" )
declare -A PKG_uv=(      [0]=uv         [1]=uv         [2]=uv         [3]=uv         [4]="" )
declare -A PKG_jq=(      [0]=jq         [1]=jq         [2]=jq         [3]=jq         [4]=jqlang.jq )
declare -A PKG_git=(     [0]=git        [1]=git        [2]=git        [3]=git        [4]=Git.Git )
declare -A PKG_curl=(    [0]=curl       [1]=curl       [2]=curl       [3]=curl       [4]="" )
declare -A PKG_delta=(   [0]=git-delta  [1]=git-delta  [2]=git-delta  [3]=git-delta  [4]="" )

# All packages to install (order matters: stow needed early)
ALL_PACKAGES=(git curl stow fish starship eza bat fd ripgrep fzf zoxide tmux direnv uv jq delta)

# ── Package install helpers ───────────────────────────────────────────────────
is_installed() { command -v "$1" &>/dev/null; }

install_pkg() {
    local pkg="$1"
    local varname="PKG_${pkg}"
    local -n pkg_map="$varname" 2>/dev/null || { warn "Unknown package: $pkg, skipping"; return; }

    local pkg_name
    case "$OS" in
        macos)   pkg_name="${pkg_map[0]}" ;;
        arch)    pkg_name="${pkg_map[1]}" ;;
        fedora)  pkg_name="${pkg_map[2]}" ;;
        debian|ubuntu) pkg_name="${pkg_map[3]}" ;;
        windows) pkg_name="${pkg_map[4]}" ;;
        *) warn "Unsupported OS for package $pkg"; return ;;
    esac

    [ -z "$pkg_name" ] && { warn "No $OS package for $pkg, skipping"; return; }

    # Check if already installed (use the logical name for command check)
    local cmd="$pkg"
    # Override command name for packages where binary differs from package name
    case "$pkg" in
        fd)      [[ "$OS" == "debian" || "$OS" == "ubuntu" ]] && cmd="fdfind" || cmd="fd" ;;
        bat)     [[ "$OS" == "debian" || "$OS" == "ubuntu" ]] && cmd="batcat" || cmd="bat" ;;
        ripgrep) cmd="rg" ;;
        delta)   cmd="delta" ;;
    esac

    if is_installed "$cmd"; then
        info "$pkg already installed, skipping"
        return
    fi

    info "Installing $pkg ($pkg_name)..."
    case "$OS" in
        macos)   brew install "$pkg_name" ;;
        arch)    sudo pacman -S --noconfirm "$pkg_name" ;;
        fedora)  sudo dnf install -y "$pkg_name" ;;
        debian|ubuntu) sudo apt install -y "$pkg_name" ;;
        windows) winget install "$pkg_name" ;;
    esac
}

# ── Prerequisites ─────────────────────────────────────────────────────────────
install_prerequisites() {
    info "Installing prerequisites..."
    case "$OS" in
        macos)
            if ! is_installed brew; then
                info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            ;;
        arch)    sudo pacman -Sy --noconfirm ;;
        fedora)  sudo dnf check-update -y || true ;;
        debian|ubuntu) sudo apt update -y ;;
    esac
}

# ── Nerd Fonts ────────────────────────────────────────────────────────────────
install_nerd_fonts() {
    info "Installing JetBrainsMono Nerd Font..."

    local font_version="v3.2.1"
    local font_name="JetBrainsMono"
    local archive="${font_name}.zip"
    local url="https://github.com/ryanoasis/nerd-fonts/releases/download/${font_version}/${archive}"

    local font_dir
    case "$OS" in
        macos)   font_dir="$HOME/Library/Fonts" ;;
        *)       font_dir="$HOME/.local/share/fonts" ;;
    esac
    mkdir -p "$font_dir"

    # Check if already installed
    if ls "$font_dir"/JetBrainsMono*.ttf &>/dev/null 2>&1; then
        info "JetBrainsMono Nerd Font already installed, skipping"
        return
    fi

    local tmp
    tmp="$(mktemp -d)"
    trap "rm -rf '$tmp'" EXIT

    info "Downloading $archive..."
    curl -fsSL "$url" -o "$tmp/$archive"
    unzip -q "$tmp/$archive" -d "$tmp/fonts"
    find "$tmp/fonts" -name "*.ttf" -not -name "*Windows*" -exec cp {} "$font_dir/" \;

    if [[ "$OS" != "macos" ]]; then
        fc-cache -fv >/dev/null 2>&1
    fi
    info "JetBrainsMono Nerd Font installed"
}

# ── Stow configs ──────────────────────────────────────────────────────────────
deploy_configs() {
    info "Deploying configs via stow..."
    cd "$STOW_DIR"

    local packages=(fish starship ghostty tmux git bat fzf direnv)
    for pkg in "${packages[@]}"; do
        if [ ! -d "$pkg" ]; then
            warn "stow/$pkg not found, skipping"
            continue
        fi
        # Warn about conflicts (files that exist and are not stow symlinks)
        stow --no-folding -t ~ --restow "$pkg" 2>&1 | while IFS= read -r line; do
            if echo "$line" | grep -q "existing target"; then
                warn "Conflict in $pkg: $line"
                warn "Backup your existing config and re-run, or delete the conflicting file."
            fi
        done || warn "stow $pkg had issues, check output above"
        info "Stowed $pkg"
    done
}

# ── Set default shell ─────────────────────────────────────────────────────────
set_default_shell() {
    local fish_path
    fish_path="$(command -v fish 2>/dev/null || true)"
    [ -z "$fish_path" ] && { warn "fish not found, skipping shell change"; return; }

    if [[ "$SHELL" == "$fish_path" ]]; then
        info "fish is already the default shell"
        return
    fi

    # Ensure fish is in /etc/shells
    if ! grep -qF "$fish_path" /etc/shells 2>/dev/null; then
        info "Adding $fish_path to /etc/shells"
        echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
    fi

    info "Setting fish as default shell..."
    chsh -s "$fish_path"
}

# ── Debian/Ubuntu quirks ──────────────────────────────────────────────────────
handle_debian_quirks() {
    [[ "$OS" != "debian" && "$OS" != "ubuntu" ]] && return

    # fd-find installs as 'fdfind' — create symlink if missing
    if is_installed fdfind && ! is_installed fd; then
        info "Creating fd → fdfind symlink..."
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    fi

    # bat may install as 'batcat' — create symlink if missing
    if is_installed batcat && ! is_installed bat; then
        info "Creating bat → batcat symlink..."
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    if [[ "$OS" == "unknown" ]]; then
        error "Unsupported OS. Exiting."
        exit 1
    fi

    if [[ "$OS" == "windows" ]]; then
        warn "Windows support is minimal. Only packages with winget entries will be installed."
        warn "tmux, stow, and fish are not available on Windows — skipping."
    fi

    install_prerequisites
    install_nerd_fonts

    info "Installing packages..."
    for pkg in "${ALL_PACKAGES[@]}"; do
        install_pkg "$pkg"
    done

    handle_debian_quirks
    deploy_configs

    if [[ "$OS" != "windows" ]]; then
        set_default_shell
    fi

    # Check for stale Ghostty config on macOS
    if [[ "$OS" == "macos" ]]; then
        local ghostty_appdata="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
        if [[ -f "$ghostty_appdata" && ! -L "$ghostty_appdata" ]]; then
            warn "Found a Ghostty config at:"
            warn "  $ghostty_appdata"
            warn "This may conflict with the stowed config at ~/.config/ghostty/config."
            warn "Review and remove it if you want the stowed config to be the only one."
        fi
    fi

    echo ""
    info "Done! Manual steps remaining:"
    echo "  1. Set user.name and user.email in ~/.gitconfig"
    echo "  2. Log out and back in for the shell change to take effect"
    if [[ "$OS" == "macos" ]]; then
        echo "  3. Set Ghostty as your default terminal in System Settings > Desktop & Dock"
    fi
}

main "$@"
