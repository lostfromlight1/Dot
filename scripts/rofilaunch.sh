#!/bin/bash

# --- HYPRLAND DYNAMIC BORDERS ---
# Reads your current Hyprland config so Rofi's borders perfectly match your windows
hypr_border=$(hyprctl -j getoption decoration:rounding | jq '.int')
hypr_width=$(hyprctl -j getoption general:border_size | jq '.int')

# Border radius math
wind_border=$(( hypr_border * 2 ))
elem_border=$([ "$hypr_border" -eq 0 ] && echo "10" || echo $(( hypr_border * 2 )))

r_override="window {border: ${hypr_width}px; border-radius: ${wind_border}px;} element {border-radius: ${elem_border}px;}"

# --- DETERMINE MODE ---
# Force the default mode to 'drun' (App Launcher) so it never gets confused
r_mode="drun"

if [[ "$1" == "f" ]]; then
    r_mode="filebrowser"
fi

# --- LAUNCH ROFI ---
rofi -show "$r_mode" -theme-str "${r_override}" -config "$HOME/.config/rofi/config.rasi"
