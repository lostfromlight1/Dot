#!/usr/bin/env bash

# Define the save directory
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

# Generate a timestamped filename
FILE="$DIR/Screenshot_$(date +%Y%m%d_%H%M%S).png"

# Check the argument passed from Hyprland
case "$1" in
    full)
        # Capture the entire screen
        grim "$FILE"
        ;;
    area)
        # Freeze the screen and let the user select a region
        grim -g "$(slurp)" "$FILE"
        ;;
    *)
        echo "Usage: $0 {full|area}"
        exit 1
        ;;
esac

# If the file was successfully created
if [ -f "$FILE" ]; then
    # 1. Automatically copy to Wayland clipboard
    wl-copy < "$FILE"
    
    # 2. Send a notification to SwayNC with a thumbnail
    notify-send -a "Screenshot" -i "$FILE" "Screenshot Captured" "Saved to Pictures/Screenshots and copied to clipboard."
    
    # 3. Open Swappy to immediately draw or blur text
    swappy -f "$FILE"
fi
