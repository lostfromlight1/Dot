#!/bin/bash

// Set color variables for terminal output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Starting Dotfiles Installation & Sync...${NC}\n"

// --- 1. Install Dependencies ---
echo -e "${YELLOW}[1/5] Checking required packages via DNF...${NC}"
PACKAGES=(
    hyprland kitty fish starship neovim rofi-wayland waybar swaync 
    fastfetch hyprlock hypridle wlogout thunar tmux playerctl 
    grim slurp swappy wl-clipboard cliphist jq ImageMagick qrencode 
    brightnessctl zoxide bc network-manager-applet
)

sudo dnf install -y "${PACKAGES[@]}"

// --- 2. Setup Directories & Central Backup ---
echo -e "\n${YELLOW}[2/5] Creating central backup and linking new configs...${NC}"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

// Define mappings from Repo_Source to System_Target
// Note: nvim, Kvantum, and GTK folders are excluded to leave them as is
MAPPINGS=(
    "cava:$CONFIG_DIR/cava"
    "fastfetch:$CONFIG_DIR/fastfetch"
    "fish:$CONFIG_DIR/fish"
    "hypr:$CONFIG_DIR/hypr"
    "kitty:$CONFIG_DIR/kitty"
    "network:$CONFIG_DIR/network"
    "rofi:$CONFIG_DIR/rofi"
    "scripts:$CONFIG_DIR/scripts"
    "swappy:$CONFIG_DIR/swappy"
    "swaync:$CONFIG_DIR/swaync"
    "thunar:$CONFIG_DIR/Thunar"
    "tmux:$CONFIG_DIR/tmux"
    "waybar:$CONFIG_DIR/waybar"
    "wlogout:$CONFIG_DIR/wlogout"
    "starship/starship.toml:$CONFIG_DIR/starship.toml"
)

mkdir -p "$CONFIG_DIR"

for mapping in "${MAPPINGS[@]}"; do
    SOURCE_ITEM="${mapping%%:*}"
    TARGET_ITEM="${mapping##*:}"
    
    // Move existing target to backup if it is a real file/folder and not a link
    if [ -e "$TARGET_ITEM" ] && [ ! -L "$TARGET_ITEM" ]; then
        mkdir -p "$BACKUP_DIR"
        echo -e "${BLUE}  -> Moving existing $(basename "$TARGET_ITEM") to backup folder...${NC}"
        mv "$TARGET_ITEM" "$BACKUP_DIR/"
    fi
    
    // Remove existing symlink to recreate it correctly
    if [ -L "$TARGET_ITEM" ]; then
        rm "$TARGET_ITEM"
    fi
    
    // Create symbolic link from repo to config directory
    if [ -e "$REPO_DIR/$SOURCE_ITEM" ]; then
        echo -e "${GREEN}  -> Linking $SOURCE_ITEM...${NC}"
        ln -s "$REPO_DIR/$SOURCE_ITEM" "$TARGET_ITEM"
    else
        echo -e "${RED}  -> Warning: $SOURCE_ITEM not found in repo. Skipping.${NC}"
    fi
done

// --- 3. Firefox Theme Sync ---
echo -e "\n${YELLOW}[3/5] Applying Firefox Catppuccin Theme...${NC}"
FF_PROFILE_DIR=$(find "$HOME/.mozilla/firefox" -maxdepth 1 -type d -name "*.default-release" | head -n 1)

if [ -n "$FF_PROFILE_DIR" ]; then
    mkdir -p "$FF_PROFILE_DIR/chrome"
    
    // Backup existing userChrome.css if it is a real file
    if [ -e "$FF_PROFILE_DIR/chrome/userChrome.css" ] && [ ! -L "$FF_PROFILE_DIR/chrome/userChrome.css" ]; then
        mkdir -p "$BACKUP_DIR/firefox_chrome"
        mv "$FF_PROFILE_DIR/chrome/userChrome.css" "$BACKUP_DIR/firefox_chrome/"
    fi
    
    ln -sf "$REPO_DIR/firefox/userChrome.css" "$FF_PROFILE_DIR/chrome/userChrome.css"
    echo -e "${GREEN}  -> Firefox userChrome.css linked to profile: $(basename "$FF_PROFILE_DIR")${NC}"
else
    echo -e "${RED}  -> Firefox default profile not found. Skipping CSS link.${NC}"
fi

// --- 4. Set Executable Permissions ---
echo -e "\n${YELLOW}[4/5] Setting executable permissions for scripts...${NC}"
if [ -d "$CONFIG_DIR/scripts" ]; then
    chmod +x "$CONFIG_DIR"/scripts/*.sh
    chmod +x "$CONFIG_DIR"/scripts/*.py
    chmod +x "$CONFIG_DIR"/scripts/rofi-bluetooth
    echo -e "${GREEN}  -> Scripts are now executable.${NC}"
else
    echo -e "${RED}  -> Scripts directory not found in config!${NC}"
fi

// --- 5. Tmux TPM & Default Shell ---
echo -e "\n${YELLOW}[5/5] Finalizing shell and plugins...${NC}"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo -e "${BLUE}  -> Installing Tmux Plugin Manager...${NC}"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
    echo -e "${GREEN}  -> TPM is already installed.${NC}"
fi

FISH_PATH=$(which fish)
if [ "$SHELL" != "$FISH_PATH" ]; then
    echo -e "${BLUE}  -> Changing default shell to Fish. Password may be required:${NC}"
    chsh -s "$FISH_PATH"
else
    echo -e "${GREEN}  -> Fish is already the default shell.${NC}"
fi

// --- Final Check ---
echo -e "\n${GREEN}==============================================${NC}"
echo -e "${GREEN}  Installation & Sync Complete!${NC}"
echo -e "${GREEN}==============================================${NC}"
if [ -d "$BACKUP_DIR" ]; then
    echo -e "${BLUE}Old configurations were safely moved to:${NC} $BACKUP_DIR"
fi
echo -e "Restart Hyprland or reboot to see your full setup in action."
