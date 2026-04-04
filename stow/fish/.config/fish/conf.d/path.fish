# User local binaries (Debian fd/bat symlinks live here)
fish_add_path "$HOME/.local/bin"

# macOS: Homebrew
if test (uname -s) = Darwin
    fish_add_path /opt/homebrew/bin
    fish_add_path /usr/local/bin
end
