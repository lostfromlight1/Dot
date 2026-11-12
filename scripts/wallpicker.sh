#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Picker" "Directory $WALLPAPER_DIR not found!"
    exit 1
fi

cd "$WALLPAPER_DIR" || exit

mapfile -t wallpapers < <(find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | sed 's|^\./||' | sort)

if [ ${#wallpapers[@]} -eq 0 ]; then
    notify-send "Wallpaper Picker" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# We use printf and \x00 to guarantee the Rofi hidden formatting works
selected=$(
    for wall in "${wallpapers[@]}"; do
        printf "%s\x00icon\x1f%s\n" "$wall" "$WALLPAPER_DIR/$wall"
    done | rofi -dmenu -i -show-icons -p " " -config "~/.config/rofi/wallpicker.rasi"
)

if [ -n "$selected" ]; then
    full_path="$WALLPAPER_DIR/$selected"
    
    # 1. Run your normal swww script for the desktop transition
    ~/.config/scripts/swwwallpaper.sh -s "$full_path"
    
    # 2. Tell HyprPanel to update its theme and wallpaper!
    hyprpanel sw "$full_path"
fi
