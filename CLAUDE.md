# CLAUDE.md

## Project Summary

This is a cross-platform dotfiles repository. It uses GNU Stow to symlink configs from `stow/` into `$HOME`. The `install.sh` script detects the OS, installs tools via native package managers, installs Nerd Fonts, deploys configs via stow, and sets fish as the default shell. The Dracula theme is applied consistently to every tool.

Read `SPEC.md` for the full specification before doing any work.

## Key Decisions — Do Not Deviate

- **Stow-based**: every tool's config lives under `stow/<toolname>/` mirroring the home directory structure. No custom symlink logic.
- **Native package managers only**: brew (macOS), pacman (Arch/CachyOS), dnf (Fedora), apt (Debian/Ubuntu). No snap, flatpak, or cargo install. winget for Windows as a distant nice-to-have.
- **Fish shell**: this is the only shell being configured. No bash/zsh rc files.
- **Starship prompt**: single-line, left-aligned. OS icon → user@host → dir → git → language → duration → prompt char. Use the Dracula palette. Compact — no multi-line prompt.
- **Dracula theme everywhere**: Ghostty, starship, fzf, bat, tmux status bar. Use the official Dracula hex values from SPEC.md.
- **Nerd Fonts assumed**: JetBrainsMono Nerd Font is the primary. All configs can use Nerd Font glyphs freely.
- **Ghostty is the terminal**: configure it with Dracula, JetBrainsMono Nerd Font, sensible defaults. macOS-specific options are fine (Ghostty ignores unknown platform options).
- **tmux, not zellij**: prefix is `C-a`, vi-style navigation, Dracula status bar, true color support.
- **Delta for git diffs**: configured in .gitconfig with Dracula theme.
- **No fisher**: fish plugins are managed manually via conf.d files and functions, not a plugin manager.

## Architecture Rules

- `install.sh` must be a single POSIX-compatible shell script (#!/bin/sh or #!/usr/bin/env bash). It must NOT require fish to already be installed.
- The install script must be idempotent — safe to re-run.
- Each stow package must be independently deployable: `stow -t ~ fish` should work without requiring starship to also be stowed.
- Config files should have comments explaining non-obvious settings.
- Handle Debian/Ubuntu quirks: `fd-find` binary name, `batcat` binary name. Create fish aliases or symlinks.

## File Naming and Paths

- All config files use their standard XDG paths under `~/.config/` where the tool supports it.
- The `.tmux.conf` goes in `$HOME` (tmux doesn't use XDG by default).
- The `.gitconfig` goes in `$HOME`.

## Style Rules for Configs

- TOML files: use inline comments sparingly, group related settings.
- Fish files: use `set -gx` for exports, `set -g` for non-exported globals.
- Keep all configs concise. Don't add commented-out options "for reference" — if it's not active, don't include it. The user can read docs.

## Testing

- Test the install script logic mentally for each OS path before writing.
- Validate starship.toml syntax: all module names must match starship's actual module names.
- Validate fish syntax: fish uses `end` not `fi`, `else if` not `elif`, etc.
- The tmux config should not depend on any tmux plugin manager (no TPM). Keep it self-contained.

## What NOT to Build

- No editor configs (neovim, vim, vscode).
- No desktop/WM configs.
- No SSH config.
- No cloud CLI tooling.
- No system utility configs (btop, dust, etc.).
- No fisher or fish plugin manager.
- No zellij.

## Order of Implementation

1. Repository structure and README
2. `install.sh` with OS detection + package installation + font installation + stow deployment
3. `stow/fish/` — config.fish, aliases, greeting, path
4. `stow/starship/` — starship.toml with Dracula palette and single-line format
5. `stow/ghostty/` — Ghostty config with Dracula
6. `stow/tmux/` — tmux.conf with Dracula status bar
7. `stow/git/` — gitconfig with delta integration + global gitignore
8. `stow/bat/` — bat config pointing to Dracula theme
9. `stow/fzf/` — fzf Dracula colors and fd integration via fish conf.d
10. `stow/direnv/` — direnv.toml
