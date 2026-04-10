#!/bin/bash
# ============================================
# 🍎 Ubuntu → macOS Developer Setup Script
# ============================================
# Autor: Hector
# Versión: 2.0
# Fecha: 2026-04-08
# Compatible: Ubuntu 22.04+ / 24.04 LTS (GNOME 42+)
#
# Uso:
#   chmod +x setup-macos-ubuntu.sh
#   ./setup-macos-ubuntu.sh
#
# ⚠️  Requiere sudo. Cierra sesión después de ejecutar.
# ⚠️  Funciona en cualquier PC nueva con Ubuntu + GNOME.
#
# Incluye:
#   • WhiteSur Dark theme + icons + cursor
#   • Dock macOS-style (bottom, autohide, transparent)
#   • Terminator terminal (Tokyo Night + Nerd Font)
#   • Starship prompt (Tokyo Night)
#   • CLI power tools (eza, bat, btop, fzf, zoxide, ripgrep, fd, tldr)
#   • GNOME Extensions (Blur My Shell, Clipboard Indicator, Caffeine)
#   • VS Code Tokyo Night theme
#   • Git global config with useful aliases
#   • macOS-style keyboard shortcuts
#   • GRUB theme (macOS boot screen)
#   • Custom wallpaper
# ============================================

# Don't use set -e — we handle errors gracefully per step
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

print_header() {
    echo ""
    echo -e "${PURPLE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${PURPLE}${BOLD}  🍎 $1${NC}"
    echo -e "${PURPLE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_step() {
    echo -e "${CYAN}  ➜ $1${NC}"
}

print_done() {
    echo -e "${GREEN}  ✓ $1${NC}"
}

print_warn() {
    echo -e "${RED}  ⚠ $1${NC}"
}

# ============================================
# CHECK PREREQUISITES
# ============================================
print_header "Checking Prerequisites"

if [ "$(id -u)" -eq 0 ]; then
    print_warn "Don't run this script as root! Run as normal user (sudo will be asked when needed)"
    exit 1
fi

if ! command -v gnome-shell &> /dev/null; then
    print_warn "GNOME Shell not found. This script requires GNOME desktop."
    exit 1
fi

GNOME_VERSION=$(gnome-shell --version | grep -oP '\d+' | head -1)
LSB_DESC=$(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')
print_done "Detected GNOME Shell $GNOME_VERSION on $LSB_DESC"

# ============================================
# PHASE 1: SYSTEM PACKAGES
# ============================================
print_header "Phase 1: Installing System Packages"

print_step "Updating package lists..."
sudo apt update -qq

# Base dependencies (may be missing on minimal installs)
print_step "Installing base dependencies..."
sudo apt install -y git curl wget unzip zsh software-properties-common -qq

print_step "Installing Terminator + GNOME tools..."
sudo apt install -y terminator gnome-tweaks gnome-shell-extensions -qq

print_step "Installing developer CLI tools..."
sudo apt install -y btop bat fzf ripgrep fd-find imagemagick -qq

print_step "Installing eza (modern ls)..."
sudo apt install -y eza -qq 2>/dev/null || {
    print_step "eza not in default repos, adding gierens repo..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
    sudo apt update -qq
    sudo apt install -y eza -qq
}

print_step "Installing fastfetch..."
sudo apt install -y fastfetch -qq 2>/dev/null || {
    print_step "fastfetch not in default repos, adding PPA..."
    sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
    sudo apt update -qq
    sudo apt install -y fastfetch -qq
}

# Zoxide (smart cd)
print_step "Installing zoxide..."
if ! command -v zoxide &> /dev/null; then
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash 2>/dev/null
    print_done "zoxide installed"
else
    print_done "zoxide already installed"
fi

# TLDR (simplified man pages)
print_step "Installing tldr..."
pip3 install --user --break-system-packages tldr 2>/dev/null || pip3 install --user tldr 2>/dev/null
print_done "tldr installed"

# Set ZSH as default shell
if [ "$SHELL" != "/usr/bin/zsh" ] && [ "$SHELL" != "/bin/zsh" ]; then
    print_step "Setting ZSH as default shell..."
    chsh -s "$(which zsh)"
    print_done "ZSH set as default shell (takes effect on next login)"
else
    print_done "ZSH is already the default shell"
fi

# Set Terminator as default terminal
print_step "Setting Terminator as default terminal..."
sudo update-alternatives --set x-terminal-emulator /usr/bin/terminator 2>/dev/null || true
print_done "Terminator set as default terminal"

print_done "All system packages installed"

# ============================================
# PHASE 2: THEMES & ICONS
# ============================================
print_header "Phase 2: Installing Themes & Icons"

mkdir -p ~/.themes ~/.icons ~/.local/share/fonts

# WhiteSur GTK Theme
print_step "Downloading WhiteSur GTK Theme..."
TMPDIR=$(mktemp -d)
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git "$TMPDIR/gtk-theme" 2>/dev/null
print_step "Installing WhiteSur Dark (Monterey style + Shell theme)..."
"$TMPDIR/gtk-theme/install.sh" -c dark -m -l --shell -i apple -p 45 2>&1 | tail -5

# WhiteSur Icon Theme
print_step "Downloading WhiteSur Icon Theme..."
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-icon-theme.git "$TMPDIR/icon-theme" 2>/dev/null
print_step "Installing WhiteSur Icons (bold + alternative)..."
"$TMPDIR/icon-theme/install.sh" -a -b 2>&1 | tail -3

# WhiteSur GDM / Shell Theme
print_step "Installing WhiteSur Shell/GDM theme..."
sudo "$TMPDIR/gtk-theme/tweaks.sh" -g -b default 2>&1 | tail -3

# macOS Cursor
print_step "Downloading macOS Cursor..."
curl -fsSL https://github.com/ful1e5/apple_cursor/releases/latest/download/macOS.tar.xz -o "$TMPDIR/macOS-cursor.tar.xz"
mkdir -p "$TMPDIR/macOS-cursor"
tar xf "$TMPDIR/macOS-cursor.tar.xz" -C "$TMPDIR/macOS-cursor"
cp -r "$TMPDIR/macOS-cursor/macOS" ~/.icons/
cp -r "$TMPDIR/macOS-cursor/macOS-White" ~/.icons/

# Cleanup tmp
rm -rf "$TMPDIR"

print_done "Themes, icons, and cursor installed"

# ============================================
# PHASE 3: FONTS
# ============================================
print_header "Phase 3: Installing Fonts"

# JetBrains Mono Nerd Font
print_step "Downloading JetBrains Mono Nerd Font..."
FONT_TMP=$(mktemp -d)
curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz -o "$FONT_TMP/JetBrainsMono.tar.xz"
mkdir -p ~/.local/share/fonts/JetBrainsMono
tar xf "$FONT_TMP/JetBrainsMono.tar.xz" -C ~/.local/share/fonts/JetBrainsMono
print_done "JetBrains Mono Nerd Font installed"

# SF Pro Display
print_step "Downloading SF Pro Display..."
curl -fsSL https://github.com/sahibjotsaggu/San-Francisco-Pro-Fonts/archive/refs/heads/master.zip -o "$FONT_TMP/sf-pro.zip"
unzip -q -o "$FONT_TMP/sf-pro.zip" -d "$FONT_TMP"
mkdir -p ~/.local/share/fonts/SFPro
cp "$FONT_TMP"/San-Francisco-Pro-Fonts-master/*.otf ~/.local/share/fonts/SFPro/ 2>/dev/null || true
cp "$FONT_TMP"/San-Francisco-Pro-Fonts-master/*.ttf ~/.local/share/fonts/SFPro/ 2>/dev/null || true
print_done "SF Pro Display installed"

rm -rf "$FONT_TMP"

# Refresh font cache
print_step "Refreshing font cache..."
fc-cache -f > /dev/null 2>&1
print_done "Font cache updated"

# ============================================
# PHASE 4: GNOME EXTENSIONS
# ============================================
print_header "Phase 4: Installing GNOME Extensions"

# Install gnome-extensions-cli
print_step "Installing gnome-extensions-cli..."
pip3 install --user --break-system-packages gnome-extensions-cli 2>/dev/null || \
pip3 install --user gnome-extensions-cli 2>/dev/null
GEXT="$HOME/.local/bin/gext"

# Blur My Shell
print_step "Installing Blur My Shell..."
$GEXT install blur-my-shell@aunetx 2>&1 | tail -2
gnome-extensions enable blur-my-shell@aunetx 2>/dev/null
print_done "Blur My Shell installed & enabled"

# Clipboard Indicator
print_step "Installing Clipboard Indicator..."
$GEXT install clipboard-indicator@tudmotu.com 2>&1 | tail -2
gnome-extensions enable clipboard-indicator@tudmotu.com 2>/dev/null
print_done "Clipboard Indicator installed & enabled"

# Caffeine
print_step "Installing Caffeine..."
$GEXT install caffeine@patapon.info 2>&1 | tail -2
gnome-extensions enable caffeine@patapon.info 2>/dev/null
print_done "Caffeine installed & enabled"

# Astra Monitor (replaces Vitals — modern, compact system monitor)
print_step "Installing Astra Monitor..."
$GEXT install monitor@astraext.github.io 2>&1 | tail -2
gnome-extensions enable monitor@astraext.github.io 2>/dev/null
gnome-extensions disable Vitals@CoreCoding.com 2>/dev/null || true
print_done "Astra Monitor installed & enabled (Vitals disabled)"

# Configure Astra Monitor: compact CPU graph + RAM bar + Network graph
print_step "Configuring Astra Monitor (Tokyo Night style)..."
dconf write /org/gnome/shell/extensions/astra-monitor/processor-header-show true
dconf write /org/gnome/shell/extensions/astra-monitor/memory-header-show true
dconf write /org/gnome/shell/extensions/astra-monitor/network-header-show true
dconf write /org/gnome/shell/extensions/astra-monitor/storage-header-show false
dconf write /org/gnome/shell/extensions/astra-monitor/gpu-header-show false
dconf write /org/gnome/shell/extensions/astra-monitor/sensors-header-show false
dconf write /org/gnome/shell/extensions/astra-monitor/processor-header-graph true
dconf write /org/gnome/shell/extensions/astra-monitor/processor-header-graph-width 30
dconf write /org/gnome/shell/extensions/astra-monitor/processor-header-percentage false
dconf write /org/gnome/shell/extensions/astra-monitor/processor-header-bars false
dconf write /org/gnome/shell/extensions/astra-monitor/memory-header-bars true
dconf write /org/gnome/shell/extensions/astra-monitor/memory-header-graph false
dconf write /org/gnome/shell/extensions/astra-monitor/memory-header-percentage false
dconf write /org/gnome/shell/extensions/astra-monitor/network-header-graph true
dconf write /org/gnome/shell/extensions/astra-monitor/network-header-graph-width 30
dconf write /org/gnome/shell/extensions/astra-monitor/network-header-io false
dconf write /org/gnome/shell/extensions/astra-monitor/processor-header-graph-color1 "'rgba(122,162,247,1.0)'"
dconf write /org/gnome/shell/extensions/astra-monitor/processor-header-graph-color2 "'rgba(247,118,142,1.0)'"
dconf write /org/gnome/shell/extensions/astra-monitor/memory-header-bars-color1 "'rgba(158,206,106,1.0)'"
dconf write /org/gnome/shell/extensions/astra-monitor/memory-header-bars-color2 "'rgba(158,206,106,0.3)'"
dconf write /org/gnome/shell/extensions/astra-monitor/network-header-io-graph-color1 "'rgba(125,207,255,1.0)'"
dconf write /org/gnome/shell/extensions/astra-monitor/network-header-io-graph-color2 "'rgba(224,175,104,1.0)'"
dconf write /org/gnome/shell/extensions/astra-monitor/theme-style "'dark'"
print_done "Astra Monitor: CPU graph + RAM bar + Network graph (Tokyo Night)"

# Enable User Themes
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null
print_done "All GNOME extensions installed"

# ============================================
# PHASE 5: STARSHIP PROMPT
# ============================================
print_header "Phase 5: Installing Starship Prompt"

if ! command -v starship &> /dev/null; then
    print_step "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y > /dev/null 2>&1
    print_done "Starship installed"
else
    print_done "Starship already installed"
fi

# Starship config (Tokyo Night theme)
print_step "Configuring Starship (Tokyo Night)..."
mkdir -p ~/.config
cat > ~/.config/starship.toml << 'STARSHIP_EOF'
# ============================================
# 🚀 Starship Prompt - Tokyo Night Dev Theme
# ============================================

command_timeout = 5000
scan_timeout = 30

format = """
[╭─](bold #7aa2f7)$os$username$hostname$directory$git_branch$git_status$git_state$python$nodejs$rust$golang$java$docker_context$package$cmd_duration
[╰─](bold #7aa2f7)$character"""

right_format = """$time"""

[character]
success_symbol = "[❯](bold #9ece6a)"
error_symbol = "[❯](bold #f7768e)"
vimcmd_symbol = "[❮](bold #bb9af7)"

[os]
disabled = false
style = "bold #7aa2f7"

[os.symbols]
Ubuntu = " "
Macos = " "
Linux = " "
Windows = "󰍲 "

[username]
show_always = false
style_user = "bold #c0caf5"
style_root = "bold #f7768e"
format = "[$user]($style) "

[hostname]
ssh_only = true
style = "bold #bb9af7"
format = "at [$hostname]($style) "

[directory]
truncation_length = 3
truncation_symbol = "…/"
style = "bold #7aa2f7"
read_only = " 󰌾"
read_only_style = "bold #f7768e"
format = "[$path]($style)[$read_only]($read_only_style) "

[directory.substitutions]
"Documents" = "󰈙 "
"Downloads" = " "
"Desktop" = "󰇄 "
"Projects" = "󰲋 "

[git_branch]
symbol = " "
style = "bold #bb9af7"
format = "on [$symbol$branch(:$remote_branch)]($style) "

[git_status]
style = "bold #e0af68"
format = '([$all_status$ahead_behind]($style) )'
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
conflicted = "=${count}"
untracked = "?${count}"
stashed = "\\$${count}"
modified = "!${count}"
staged = "+${count}"
renamed = "»${count}"
deleted = "✘${count}"

[git_state]
style = "bold #e0af68"

[python]
symbol = " "
style = "bold #e0af68"
format = 'via [${symbol}(${version} )(\\($virtualenv\\) )]($style)'

[nodejs]
symbol = " "
style = "bold #9ece6a"
format = 'via [$symbol($version )]($style)'

[rust]
symbol = "🦀 "
style = "bold #f7768e"
format = 'via [$symbol($version )]($style)'

[golang]
symbol = " "
style = "bold #73daca"
format = 'via [$symbol($version )]($style)'

[java]
symbol = " "
style = "bold #f7768e"
format = 'via [$symbol($version )]($style)'

[docker_context]
symbol = " "
style = "bold #7dcfff"
format = 'via [$symbol$context]($style) '

[package]
symbol = "󰏗 "
style = "bold #e0af68"
format = 'is [$symbol$version]($style) '

[cmd_duration]
min_time = 2_000
style = "bold #565f89"
format = "took [$duration]($style) "

[time]
disabled = false
style = "bold #565f89"
format = '[$time]($style)'
time_format = "%H:%M"

[memory_usage]
disabled = true

[battery]
disabled = true
STARSHIP_EOF

print_done "Starship configured with Tokyo Night theme"

# ============================================
# PHASE 6: ZSH PLUGINS & CONFIG
# ============================================
print_header "Phase 6: Configuring ZSH"

# Install Oh My ZSH if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_step "Installing Oh My ZSH..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_done "Oh My ZSH installed"
else
    print_done "Oh My ZSH already installed"
fi

# ZSH Plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    print_step "Installing zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null
    print_done "zsh-autosuggestions installed"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    print_step "Installing zsh-syntax-highlighting..."
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null
    print_done "zsh-syntax-highlighting installed"
fi

# Backup existing .zshrc
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
    print_step "Existing .zshrc backed up"
fi

# Write new .zshrc
print_step "Writing new .zshrc..."
cat > "$HOME/.zshrc" << 'ZSHRC_EOF'
# ============================================
# 🍎 ZSH Configuration - macOS Developer Style
# ============================================

# Path to Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Theme: disabled (using Starship instead)
ZSH_THEME=""

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  docker
  sudo
  web-search
  copypath
  copyfile
  jsontools
)

source $ZSH/oh-my-zsh.sh

# ============================================
# 📦 Environment Variables
# ============================================

export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.pub-cache/bin"
export PATH="$PATH:$HOME/.npm-global/bin"
export EDITOR='code'
export LANG=en_US.UTF-8

# NVM (if installed)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Local env loader
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# ============================================
# 🎨 Aliases - Developer macOS Style
# ============================================

# Modern replacements
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first --git'
alias lt='eza --tree --icons --level=2'
alias l='eza -l --icons --sort=modified'
alias cat='batcat --style=auto'
alias top='btop'
alias fd='fdfind'
alias rg='rg --smart-case'
alias help='tldr'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -15'
alias gd='git diff'

# System
alias ports='ss -tulanp'
alias myip='curl -s ifconfig.me'
alias weather='curl wttr.in/?format=3'
alias update='sudo apt update && sudo apt upgrade -y'
alias cleanup='sudo apt autoremove -y && sudo apt autoclean'

# Quick info
alias fetch='fastfetch'
alias sysinfo='fastfetch'

# Theme toggle
alias dark='theme-dark'
alias light='theme-light'
alias toggle='theme-toggle'

# Python
alias py='python3'
alias venv='python3 -m venv'
alias activate='source ./venv/bin/activate'

# Docker
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dimg='docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"'

# ============================================
# 🚀 Starship Prompt
# ============================================
eval "$(starship init zsh)"

# ============================================
# 🔍 FZF (Fuzzy Finder)
# ============================================
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=bg+:#1a1b26,fg+:#c0caf5,hl:#bb9af7,hl+:#7aa2f7,border:#565f89'
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git 2>/dev/null || find . -type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ============================================
# 📂 Zoxide (Smart cd)
# ============================================
eval "$(zoxide init zsh)" 2>/dev/null

# ============================================
# 🖥️ Fastfetch Greeting
# ============================================
if command -v fastfetch &> /dev/null && [[ $- == *i* ]] && [ -z "$VSCODE_PID" ]; then
    fastfetch --logo small
fi
ZSHRC_EOF

print_done "ZSH configured with plugins, aliases, fzf, zoxide, and fastfetch"

# ============================================
# PHASE 7: TERMINATOR CONFIG
# ============================================
print_header "Phase 7: Configuring Terminator (Tokyo Night)"

gsettings set org.gnome.desktop.default-applications.terminal exec 'terminator'
gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-x'

mkdir -p ~/.config/terminator
cat > ~/.config/terminator/config << 'TERMINATOR_EOF'
[global_config]
  suppress_multiple_term_dialog = True
  title_transmit_fg_color = "#c0caf5"
  title_transmit_bg_color = "#1a1b26"
  title_inactive_fg_color = "#565f89"
  title_inactive_bg_color = "#16161e"
[keybindings]
[profiles]
  [[default]]
    cursor_shape = ibeam
    cursor_color = "#c0caf5"
    font = JetBrainsMono Nerd Font 12
    use_system_font = False
    foreground_color = "#c0caf5"
    background_color = "#1a1b26"
    background_darkness = 0.92
    background_type = transparent
    palette = "#15161e:#f7768e:#9ece6a:#e0af68:#7aa2f7:#bb9af7:#7dcfff:#a9b1d6:#414868:#f7768e:#9ece6a:#e0af68:#7aa2f7:#bb9af7:#7dcfff:#c0caf5"
    scrollback_lines = 5000
    show_titlebar = False
[layouts]
  [[default]]
    [[[window0]]]
      type = Window
      parent = ""
    [[[child1]]]
      type = Terminal
      parent = window0
[plugins]
TERMINATOR_EOF

print_done "Terminator configured: Tokyo Night + JetBrains Mono Nerd Font 12"

# ============================================
# PHASE 8: GNOME SETTINGS
# ============================================
print_header "Phase 8: Applying GNOME Settings"

# GTK Theme
print_step "Applying WhiteSur Dark theme..."
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Icon Theme
print_step "Applying WhiteSur icons..."
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'

# Cursor Theme
print_step "Applying macOS cursor..."
gsettings set org.gnome.desktop.interface cursor-theme 'macOS'
gsettings set org.gnome.desktop.interface cursor-size 24

# Fonts
print_step "Applying SF Pro Display + JetBrains Mono..."
gsettings set org.gnome.desktop.interface font-name 'SF Pro Display 11'
gsettings set org.gnome.desktop.interface document-font-name 'SF Pro Display 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 11'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'SF Pro Display Bold 11'

# Font rendering
gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'
gsettings set org.gnome.desktop.interface font-hinting 'slight'

# Window buttons left (macOS style) — WM + GTK3 + GTK4
print_step "Moving window buttons to left..."
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'

mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0

cat > ~/.config/gtk-3.0/settings.ini << 'GTK3_EOF'
[Settings]
gtk-decoration-layout=close,minimize,maximize:
GTK3_EOF

cat > ~/.config/gtk-4.0/settings.ini << 'GTK4_EOF'
[Settings]
gtk-decoration-layout=close,minimize,maximize:
GTK4_EOF

print_done "Window buttons set to left (WM + GTK3 + GTK4)"

# Shell theme
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark'
print_done "Shell theme applied"

# ============================================
# PHASE 9: DOCK CONFIGURATION
# ============================================
print_header "Phase 9: Configuring Dock (macOS Style)"

print_step "Setting dock to bottom, autohide, no gap..."
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'DYNAMIC'
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.6

# Autohide without gap
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false
gsettings set org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen true
gsettings set org.gnome.shell.extensions.dash-to-dock hide-delay 0.1
gsettings set org.gnome.shell.extensions.dash-to-dock show-delay 0.0
gsettings set org.gnome.shell.extensions.dash-to-dock require-pressure-to-show false
gsettings set org.gnome.shell.extensions.dash-to-dock pressure-threshold 0.0

gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style 'DOTS'
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash true
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
gsettings set org.gnome.shell.extensions.dash-to-dock animate-show-apps true
gsettings set org.gnome.shell.extensions.dash-to-dock animation-time 0.15
gsettings set org.gnome.shell.extensions.dash-to-dock apply-custom-theme false
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true

print_done "Dock configured: bottom, autohide instant, transparent, no gap"

# ============================================
# PHASE 10: WALLPAPER
# ============================================
print_header "Phase 10: Setting Wallpaper"

mkdir -p ~/Pictures
WALLPAPER="$HOME/Pictures/tux-developer-wallpaper.png"

# Auto-detect screen resolution
SCREEN_RES=$(xdpyinfo 2>/dev/null | grep dimensions | awk '{print $2}')
if [ -z "$SCREEN_RES" ]; then
    SCREEN_RES=$(xrandr 2>/dev/null | grep ' connected' | head -1 | grep -oP '\d+x\d+' | head -1)
fi
RES_W=$(echo "$SCREEN_RES" | cut -dx -f1)
RES_H=$(echo "$SCREEN_RES" | cut -dx -f2)
: ${RES_W:=3840} ${RES_H:=2160}  # Fallback to 4K
print_step "Detected screen resolution: ${RES_W}x${RES_H}"

if [ ! -f "$WALLPAPER" ]; then
    print_step "Generating developer wallpaper at ${RES_W}x${RES_H} with ImageMagick..."
    if command -v convert &> /dev/null; then
        # Create a universal blue-gray gradient wallpaper (works for dark & light themes)
        convert -size ${RES_W}x${RES_H} \
            \( xc:'#334456' xc:'#5a7a98' +append \) \
            \( xc:'#465B71' xc:'#6e8da8' +append \) \
            -append -resize ${RES_W}x${RES_H}\! -blur 0x60 \
            \( -size ${RES_W}x${RES_H} plasma:fractal -blur 0x40 -normalize \
               -fill '#4a6580' -colorize 92% \) \
            -compose screen -composite \
            "$WALLPAPER" 2>/dev/null && \
        print_done "Wallpaper generated (${RES_W}x${RES_H})" || {
            # Simpler fallback
            convert -size ${RES_W}x${RES_H} \
                -define gradient:angle=135 \
                gradient:'#334456'-'#5a7a98' \
                "$WALLPAPER" 2>/dev/null
            print_done "Simple gradient wallpaper generated"
        }
    else
        print_warn "ImageMagick not found — skipping wallpaper generation"
        print_warn "Place your wallpaper at: $WALLPAPER"
    fi
else
    print_done "Wallpaper already exists at $WALLPAPER"
fi

if [ -f "$WALLPAPER" ]; then
    gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER"
    gsettings set org.gnome.desktop.background picture-options 'zoom'
    gsettings set org.gnome.desktop.screensaver picture-uri "file://$WALLPAPER"
    print_done "Wallpaper applied"
fi

# ============================================
# PHASE 11: VS CODE THEME
# ============================================
print_header "Phase 11: VS Code Tokyo Night Theme"

if command -v code &> /dev/null; then
    print_step "Installing Tokyo Night extension..."
    code --install-extension enkia.tokyo-night 2>/dev/null
    
    # Set Tokyo Night as default theme
    VSCODE_SETTINGS="$HOME/.config/Code/User/settings.json"
    mkdir -p "$(dirname "$VSCODE_SETTINGS")"
    if [ -f "$VSCODE_SETTINGS" ]; then
        # Only add theme if not already set
        if ! grep -q 'tokyo-night' "$VSCODE_SETTINGS" 2>/dev/null; then
            # Use python to safely merge JSON
            python3 -c "
import json, os
path = os.path.expanduser('$VSCODE_SETTINGS')
try:
    with open(path) as f: cfg = json.load(f)
except: cfg = {}
cfg['workbench.colorTheme'] = 'Tokyo Night'
cfg['editor.fontFamily'] = \"'JetBrainsMono Nerd Font', 'Droid Sans Mono', monospace\"
cfg['editor.fontSize'] = 14
cfg['terminal.integrated.fontFamily'] = 'JetBrainsMono Nerd Font'
cfg['terminal.integrated.fontSize'] = 13
with open(path, 'w') as f: json.dump(cfg, f, indent=4)
" 2>/dev/null
            print_done "VS Code configured: Tokyo Night + JetBrains Mono"
        else
            print_done "VS Code already has Tokyo Night"
        fi
    else
        cat > "$VSCODE_SETTINGS" << 'VSCODE_EOF'
{
    "workbench.colorTheme": "Tokyo Night",
    "editor.fontFamily": "'JetBrainsMono Nerd Font', 'Droid Sans Mono', monospace",
    "editor.fontSize": 14,
    "terminal.integrated.fontFamily": "JetBrainsMono Nerd Font",
    "terminal.integrated.fontSize": 13
}
VSCODE_EOF
        print_done "VS Code configured: Tokyo Night + JetBrains Mono"
    fi
else
    print_warn "VS Code not found — install it and run: code --install-extension enkia.tokyo-night"
fi

# ============================================
# PHASE 12: GIT GLOBAL CONFIG
# ============================================
print_header "Phase 12: Git Global Configuration"

print_step "Setting up developer-friendly git config..."
git config --global init.defaultBranch main
git config --global core.editor "code --wait"
git config --global color.ui auto
git config --global pull.rebase false
git config --global push.autoSetupRemote true
git config --global credential.helper store

# Useful aliases
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.lg "log --oneline --graph --decorate --all -20"
git config --global alias.last "log -1 HEAD --stat"
git config --global alias.unstage "reset HEAD --"
git config --global alias.amend "commit --amend --no-edit"
git config --global alias.wip "!git add -A && git commit -m 'WIP'"

print_done "Git configured with aliases: st, co, br, ci, lg, last, unstage, amend, wip"

# ============================================
# PHASE 13: KEYBOARD SHORTCUTS
# ============================================
print_header "Phase 13: Keyboard Shortcuts"

# Super+E = Files
gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"

# Custom: Super+T = Terminator
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Terminator'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'terminator'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>t'

print_done "Shortcuts: Super+E=Files, Super+T=Terminator"

# ============================================
# PHASE 14: GNOME EXTRAS
# ============================================
print_header "Phase 14: Final GNOME Touches"

# Clock
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface clock-show-weekday true

# Hot corners off
gsettings set org.gnome.desktop.interface enable-hot-corners false

# Smooth animations
gsettings set org.gnome.desktop.interface enable-animations true

# Show battery percentage
gsettings set org.gnome.desktop.interface show-battery-percentage true

# Touchpad (macOS-style)
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true

# Set dock favorites (Terminator, not GNOME Terminal)
gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'google-chrome.desktop', 'code.desktop', 'terminator.desktop', 'org.gnome.Settings.desktop']"

print_done "All GNOME extras applied"

# ============================================
# PHASE 15: GRUB THEME (macOS Boot Screen)
# ============================================
print_header "Phase 15: GRUB Theme (macOS Boot Screen)"

print_step "Installing Tela GRUB theme..."
GRUB_TMP=$(mktemp -d)
git clone --depth=1 https://github.com/vinceliuice/grub2-themes.git "$GRUB_TMP/grub-theme" 2>/dev/null
if [ -d "$GRUB_TMP/grub-theme" ]; then
    sudo "$GRUB_TMP/grub-theme/install.sh" -b -t tela 2>&1 | tail -3
    rm -rf "$GRUB_TMP"
    print_done "Tela GRUB theme installed (visible on next reboot)"
else
    print_warn "Could not download GRUB theme — skipping"
fi

# ============================================
# PHASE 16: DARK/LIGHT THEME TOGGLE
# ============================================
print_header "Phase 16: Dark/Light Theme Toggle"

mkdir -p ~/.local/bin

# theme-dark script
print_step "Creating theme-dark script..."
cat > ~/.local/bin/theme-dark << 'DARK_EOF'
#!/bin/bash
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark'
mkdir -p ~/.config/terminator
cat > ~/.config/terminator/config << 'EOF'
[global_config]
  suppress_multiple_term_dialog = True
  title_transmit_fg_color = "#c0caf5"
  title_transmit_bg_color = "#1a1b26"
  title_inactive_fg_color = "#565f89"
  title_inactive_bg_color = "#16161e"
[keybindings]
[profiles]
  [[default]]
    cursor_shape = ibeam
    cursor_color = "#c0caf5"
    font = JetBrainsMono Nerd Font 12
    use_system_font = False
    foreground_color = "#c0caf5"
    background_color = "#1a1b26"
    background_darkness = 0.92
    background_type = transparent
    palette = "#15161e:#f7768e:#9ece6a:#e0af68:#7aa2f7:#bb9af7:#7dcfff:#a9b1d6:#414868:#f7768e:#9ece6a:#e0af68:#7aa2f7:#bb9af7:#7dcfff:#c0caf5"
    scrollback_lines = 5000
    show_titlebar = False
[layouts]
  [[default]]
    [[[window0]]]
      type = Window
      parent = ""
    [[[child1]]]
      type = Terminal
      parent = window0
[plugins]
EOF
VSCODE_SETTINGS="$HOME/.config/Code/User/settings.json"
if [ -f "$VSCODE_SETTINGS" ]; then
    python3 -c "
import json
with open('$VSCODE_SETTINGS') as f: cfg = json.load(f)
cfg['workbench.colorTheme'] = 'Tokyo Night'
with open('$VSCODE_SETTINGS', 'w') as f: json.dump(cfg, f, indent=4)
" 2>/dev/null
fi
[ -f "$HOME/Pictures/tux-developer-wallpaper.png" ] && {
    gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Pictures/tux-developer-wallpaper-light.png"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/Pictures/tux-developer-wallpaper.png"
    gsettings set org.gnome.desktop.background picture-options 'zoom'
}
echo "dark" > ~/.config/.theme-mode
echo "🌙 Dark Mode activated — restart Terminator for terminal changes"
DARK_EOF

# theme-light script
print_step "Creating theme-light script..."
cat > ~/.local/bin/theme-light << 'LIGHT_EOF'
#!/bin/bash
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Light'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur'
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Light'
mkdir -p ~/.config/terminator
cat > ~/.config/terminator/config << 'EOF'
[global_config]
  suppress_multiple_term_dialog = True
  title_transmit_fg_color = "#3760bf"
  title_transmit_bg_color = "#e1e2e7"
  title_inactive_fg_color = "#8990b3"
  title_inactive_bg_color = "#d0d5e3"
[keybindings]
[profiles]
  [[default]]
    cursor_shape = ibeam
    cursor_color = "#3760bf"
    font = JetBrainsMono Nerd Font 12
    use_system_font = False
    foreground_color = "#3760bf"
    background_color = "#e1e2e7"
    background_darkness = 0.95
    background_type = transparent
    palette = "#e9e9ed:#f52a65:#587539:#8c6c3e:#2e7de9:#9854f1:#007197:#6172b0:#a1a6c5:#f52a65:#587539:#8c6c3e:#2e7de9:#9854f1:#007197:#3760bf"
    scrollback_lines = 5000
    show_titlebar = False
[layouts]
  [[default]]
    [[[window0]]]
      type = Window
      parent = ""
    [[[child1]]]
      type = Terminal
      parent = window0
[plugins]
EOF
VSCODE_SETTINGS="$HOME/.config/Code/User/settings.json"
if [ -f "$VSCODE_SETTINGS" ]; then
    python3 -c "
import json
with open('$VSCODE_SETTINGS') as f: cfg = json.load(f)
cfg['workbench.colorTheme'] = 'Tokyo Night Light'
with open('$VSCODE_SETTINGS', 'w') as f: json.dump(cfg, f, indent=4)
" 2>/dev/null
fi
[ -f "$HOME/Pictures/tux-developer-wallpaper.png" ] && {
    gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Pictures/tux-developer-wallpaper-light.png"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/Pictures/tux-developer-wallpaper.png"
    gsettings set org.gnome.desktop.background picture-options 'zoom'
}
echo "light" > ~/.config/.theme-mode
echo "☀️ Light Mode activated — restart Terminator for terminal changes"
LIGHT_EOF

# theme-toggle script
print_step "Creating theme-toggle script..."
cat > ~/.local/bin/theme-toggle << 'TOGGLE_EOF'
#!/bin/bash
CURRENT=$(cat ~/.config/.theme-mode 2>/dev/null || echo "dark")
if [ "$CURRENT" = "dark" ]; then
    theme-light
else
    theme-dark
fi
TOGGLE_EOF

chmod +x ~/.local/bin/theme-dark ~/.local/bin/theme-light ~/.local/bin/theme-toggle
echo "dark" > ~/.config/.theme-mode

print_done "Theme toggle: 'dark', 'light', 'toggle' commands available"

# ============================================
# DONE!
# ============================================
print_header "Setup Complete! 🎉"

echo ""
echo -e "${GREEN}${BOLD}  Everything has been installed and configured:${NC}"
echo ""
echo -e "  ${CYAN}Theme:${NC}       WhiteSur-Dark (Monterey style)"
echo -e "  ${CYAN}Icons:${NC}       WhiteSur-dark"
echo -e "  ${CYAN}Cursor:${NC}      macOS"
echo -e "  ${CYAN}Fonts:${NC}       SF Pro Display + JetBrains Mono Nerd Font"
echo -e "  ${CYAN}Dock:${NC}        Bottom, autohide instant, transparent (no gap)"
echo -e "  ${CYAN}Wallpaper:${NC}   Developer dark gradient"
echo -e "  ${CYAN}Top Bar:${NC}     WhiteSur Shell + Blur My Shell (glass blur)"
echo -e "  ${CYAN}Buttons:${NC}     Left side (WM + GTK3 + GTK4)"
echo -e "  ${CYAN}Terminal:${NC}    Terminator (Tokyo Night + Nerd Font)"
echo -e "  ${CYAN}Prompt:${NC}      Starship (Tokyo Night)"
echo -e "  ${CYAN}Plugins:${NC}     zsh-autosuggestions, zsh-syntax-highlighting"
echo -e "  ${CYAN}CLI Tools:${NC}   eza, bat, btop, fzf, zoxide, ripgrep, fd, tldr, fastfetch"
echo -e "  ${CYAN}Extensions:${NC}  Blur My Shell, Astra Monitor, Clipboard, Caffeine"
echo -e "  ${CYAN}VS Code:${NC}     Tokyo Night + JetBrains Mono"
echo -e "  ${CYAN}Git:${NC}         Global config + aliases (st, co, lg, amend, wip)"
echo -e "  ${CYAN}Shortcuts:${NC}   Super+E=Files, Super+T=Terminator"
echo -e "  ${CYAN}GRUB:${NC}        Tela macOS-style boot screen"
echo -e "  ${CYAN}Toggle:${NC}      'dark' / 'light' / 'toggle' commands"
echo ""
echo -e "${PURPLE}${BOLD}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${PURPLE}${BOLD}  ⚠️  Log out and log back in for full effect!${NC}"
echo -e "${PURPLE}${BOLD}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${CYAN}Quick test:${NC}  Open Terminator and run: ${GREEN}fastfetch${NC}"
echo -e "  ${CYAN}FZF:${NC}         Press ${GREEN}Ctrl+R${NC} for fuzzy history search"
echo -e "  ${CYAN}Zoxide:${NC}      Use ${GREEN}z <folder>${NC} instead of cd"
echo -e "  ${CYAN}TLDR:${NC}        Run ${GREEN}help tar${NC} for simplified man pages"
echo -e "  ${CYAN}Dark mode:${NC}   Run ${GREEN}dark${NC} in terminal"
echo -e "  ${CYAN}Light mode:${NC}  Run ${GREEN}light${NC} in terminal"
echo -e "  ${CYAN}Toggle:${NC}      Run ${GREEN}toggle${NC} to switch"
echo ""
