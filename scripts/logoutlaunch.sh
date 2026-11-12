#!/bin/bash

# Check if wlogout is already running
if pgrep -x "wlogout" > /dev/null; then
    pkill -x "wlogout"
    exit 0
fi

# Paths
wLayout="${XDG_CONFIG_HOME:-$HOME/.config}/wlogout/layout"
wlTmplt="${XDG_CONFIG_HOME:-$HOME/.config}/wlogout/style.css"

if [ ! -f "$wLayout" ] || [ ! -f "$wlTmplt" ]; then
    echo "ERROR: layout or style.css not found..."
    exit 1
fi

hypr_border=$(hyprctl -j getoption decoration:rounding | jq '.int')
hypr_width=$(hyprctl -j getoption general:border_size | jq '.int')

x_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
y_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')
hypr_scale=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .scale')

wlColms=6
export mgn=$(awk "BEGIN {printf \"%d\", $y_mon * 28 / $hypr_scale}")
export hvr=$(awk "BEGIN {printf \"%d\", $y_mon * 23 / $hypr_scale}")
export fntSize=$(awk "BEGIN {printf \"%d\", ($y_mon * 2) / 130}")

export BtnCol="rgba(205, 214, 244, 1)" # Mocha text
export WindBg="rgba(30, 30, 46, 0.6)"  # Mocha base with 60% opacity

# Border radius
export active_rad=$(( hypr_border * 5 ))
export button_rad=$(( hypr_border * 2 ))

# Write all vars to style template 
wlStyle=$(envsubst < "$wlTmplt")

# Launch wlogout
wlogout -b "$wlColms" -c 0 -r 0 -m 0 \
    --layout "$wLayout" \
    --css <(echo "$wlStyle") \
    --protocol layer-shell
