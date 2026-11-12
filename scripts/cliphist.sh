#!/bin/bash

ScrDir=$(dirname "$(realpath "$0")")
roconf="$HOME/.config/rofi/clipboard.rasi"

# Get hyprland border and width
hypr_border=$(hyprctl -j getoption decoration:rounding | jq '.int')
hypr_width=$(hyprctl -j getoption general:border_size | jq '.int')

# Hyprland border styling
wind_border=$(( hypr_border * 5 / 2 ))
elem_border=$([ "$hypr_border" -eq 0 ] && echo "5" || echo "$hypr_border")
r_override="window {border: ${hypr_width}px; border-radius: ${wind_border}px;} entry {border-radius: ${elem_border}px;} element {border-radius: ${elem_border}px;}"

# Font override (GTK monospace font)
fnt_override=$(gsettings get org.gnome.desktop.interface monospace-font-name | awk '{gsub(/'\''/,""); print $NF}')
fnt_override="configuration {font: \"JetBrainsMono Nerd Font ${fnt_override}\";}"

# Actions (The ${pos} variable has been completely removed)
case $1 in
    c)  cliphist list | rofi -dmenu -theme-str "entry { placeholder: \"Copy...\";} ${r_override}" -theme-str "${fnt_override}" -config "$roconf" | cliphist decode | wl-copy ;;
    d)  cliphist list | rofi -dmenu -theme-str "entry { placeholder: \"Delete...\";} ${r_override}" -theme-str "${fnt_override}" -config "$roconf" | cliphist delete ;;
    w)  if [ "$(echo -e "Yes\nNo" | rofi -dmenu -theme-str "entry { placeholder: \"Clear Clipboard History?\";} ${r_override}" -theme-str "${fnt_override}" -config "$roconf")" == "Yes" ]; then
            cliphist wipe
        fi ;;
    f)  cliphist list | wc -l ;;
    *)  echo "Usage: cliphist.sh [c|d|w|f]"
        echo "  c : copy from history"
        echo "  d : delete from history"
        echo "  w : wipe history"
        echo "  f : print history count, can be used as waybar module"
        exit 1 ;;
esac
