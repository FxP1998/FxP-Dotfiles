#!/bin/bash
# hyprshot.sh -- Smart Hyprland Screenshot Script
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
STAMP="$(date +%Y%m%d-%H%M%S)"
ICON_SUCCESS="󰄴"    # Nerd Font: camera
ICON_ERROR=""      # NF: x-circle
ICON_SAVE="󰄬"      # NF: floppy

# Make sure the screenshot directory exists
mkdir -p "$SCREENSHOT_DIR"

case "$1" in
    full)
        grim "$SCREENSHOT_DIR/screenshot-$STAMP.png" && \
        notify-send "$ICON_SUCCESS Screenshot" "$ICON_SAVE Saved to $SCREENSHOT_DIR" || \
        notify-send "$ICON_ERROR Oops!" "Screenshot failed"
        ;;
    region)
        slurp | grim -g - "$SCREENSHOT_DIR/screenshot-$STAMP.png" && \
        notify-send "$ICON_SUCCESS Region Screenshot" "$ICON_SAVE Saved to $SCREENSHOT_DIR" || \
        notify-send "$ICON_ERROR Oops!" "Screenshot failed"
        ;;
    *)
        notify-send "$ICON_ERROR Usage" "hyprshot.sh [full|region]"
        ;;
esac

