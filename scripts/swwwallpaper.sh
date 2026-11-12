#!/bin/bash

# --- Lock File Management ---
lock_file="/tmp/wallpapers_$(id -u)_swwwallpaper.lock"

cleanup() {
    rm -f "$lock_file"
}
trap cleanup EXIT

if [ -e "$lock_file" ]; then
    pid=$(cat "$lock_file")
    if [ -d "/proc/$pid" ]; then
        cmdline=$(tr '\0' ' ' < "/proc/$pid/cmdline")
        if [[ "$cmdline" == *swwwallpaper.sh* ]]; then
            exit 1
        else
            awww query || awww-daemon
            rm -f "$lock_file"
        fi
    else
        rm -f "$lock_file"
    fi
fi

echo $$ > "$lock_file"

# --- Wallpaper Update & Cache Generation ---
wall_update() {
    local x_wall="$1"
    local theme_name="$2"
    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/swww/$theme_name"
    local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/swww"

    mkdir -p "$cache_dir"
    mkdir -p "$config_dir"

    local cache_img=$(basename "$x_wall")

    # 1. Update the main symlink IMMEDIATELY
    ln -fs "${x_wall}" "${config_dir}/wall.set"

    # 2. Fire AWWW immediately so there is ZERO delay
    awww img "${x_wall}" \
        --transition-bezier .43,1.19,1,.4 \
        --transition-type grow \
        --transition-duration 0.7 \
        --transition-fps 60 \
        --invert-y \
        --transition-pos "$(hyprctl cursorpos)"

    # 3. Generate caches completely in the background (Non-blocking)
    if [ ! -f "${cache_dir}/${cache_img}.rofi" ]; then
        magick "${x_wall}"[0] -strip -resize 2000 -gravity center -extent 2000 -quality 90 "${cache_dir}/${cache_img}.rofi" &
    fi

    if [ ! -f "${cache_dir}/${cache_img}.blur" ]; then
        magick "${x_wall}"[0] -strip -scale 10% -blur 0x3 -resize 100% "${cache_dir}/${cache_img}.blur" &
    fi

    # Symlink the caches
    ln -fs "${cache_dir}/${cache_img}.rofi" "${config_dir}/wall.rofi"
    ln -fs "${cache_dir}/${cache_img}.blur" "${config_dir}/wall.blur"
}

# --- Wallpaper Cycling Logic ---
wall_change() {
    local x_switch=$1
    local current_wall=$(readlink "${XDG_CONFIG_HOME:-$HOME/.config}/swww/wall.set")

    if [ -z "$current_wall" ] || [ ! -f "$current_wall" ]; then
        current_wall=$(find "$HOME/Pictures/Wallpapers" -type f | head -n 1)
    fi

    local theme_name=$(basename "$(dirname "$current_wall")")
    local theme_dir=$(dirname "$current_wall")

    if [ ! -d "$theme_dir" ]; then
        echo "Error: Directory '$theme_dir' not found."
        exit 1
    fi

    mapfile -d '' wall_list < <(find "$theme_dir" -type f \( -iname "*.gif" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0 | sort -z)

    local current_index=0
    for (( i=0; i<${#wall_list[@]}; i++ )); do
        if [ "${wall_list[i]}" == "${current_wall}" ]; then
            current_index=$i
            break
        fi
    done

    if [ "$x_switch" == "n" ]; then
        next_index=$(( (current_index + 1) % ${#wall_list[@]} ))
    elif [ "$x_switch" == "p" ]; then
        next_index=$(( (current_index - 1 + ${#wall_list[@]}) % ${#wall_list[@]} ))
    else
        exit 1
    fi

    wall_update "${wall_list[next_index]}" "$theme_name"
}

# Ensure daemon is running
awww query || { awww-daemon & sleep 0.5; }

# --- Argument Parsing ---
case "$1" in
    -n) wall_change "n" ;;
    -p) wall_change "p" ;;
    -s)
        if [ -f "$2" ]; then
            theme_name=$(basename "$(dirname "$2")")
            wall_update "$2" "$theme_name"
        else
            exit 1
        fi
        ;;
esac
