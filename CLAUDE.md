# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository managed with [Chezmoi](https://www.chezmoi.io/). It contains configuration files for a development environment that works across macOS and Ubuntu systems.

## Key Commands

### Chezmoi Operations
- `chezmoi apply` - Apply dotfiles changes to the system
- `chezmoi diff` - Preview changes before applying
- `chezmoi add ~/.config/someconfig` - Add a new config file to management
- `chezmoi edit ~/.zshrc` - Edit the source file (with templates)
- `chezmoi update` - Pull and apply latest changes

The user needs to run chezmoi commands manually because of an interaction with bitwarden.
Tell the user which commands you want them to run, so they can run it and tell you the result.

### Development Tools
- Package management: Uses `asdf` for managing language/tool versions
- Container management: Podman is configured (Docker aliases available)
- Editor: Neovim with extensive LSP and plugin configuration

### Common Aliases (defined in dot_aliases.tmpl)
- `c` - chezmoi
- `v` - nvim
- `gs` - git status
- `gaa` - git add -A
- `gcm` - git commit -m
- `gp` - git push
- `gpurm` - git fetch --all && git pull --rebase --autostash origin main

## Architecture & Structure

### Chezmoi Conventions
- Files prefixed with `dot_` become dotfiles (e.g., `dot_zshrc` → `~/.zshrc`)
- Files ending with `.tmpl` use Go templating for OS-specific configurations
- Files prefixed with `private_` have restricted permissions
- Scripts prefixed with `run_onchange_` execute when their contents change

### Key Components
1. **Shell Configuration**: Zsh with Oh My Zsh on macOS, Bash on Linux
2. **Neovim Setup**: Comprehensive configuration in `private_dot_config/nvim/`
   - Uses lazy.nvim for plugin management
   - AI integrations: CodeCompanion, Copilot, Avante
   - LSP support via mason.nvim
3. **Version Management**: asdf handles multiple language versions
4. **Installation Scripts**: Sequential scripts handle system setup:
   - `run_onchange_before_00_install_system_packages.sh.tmpl` - System packages
   - `run_onchange_before_05_install_asdf.sh.tmpl` - asdf installation
   - `run_onchange_before_10_install_packages.sh.tmpl` - Language/tool installation

### Template Variables
The templates use these OS-specific conditions:
- `{{ if eq .chezmoi.os "darwin" }}` - macOS-specific
- `{{ if eq .chezmoi.os "linux" }}` - Linux-specific
- `{{ if eq .chezmoi.osRelease.id "ubuntu" }}` - Ubuntu-specific

## Important Notes

- API keys (Anthropic, Tavily) are managed via Bitwarden integration
- SSH agent is managed via systemd on Linux
- Fonts included: CodeNewRoman Nerd Font family
- Ollama configured for AMD GPU (RX 6700 XT) with HSA_OVERRIDE_GFX_VERSION=10.3.0
