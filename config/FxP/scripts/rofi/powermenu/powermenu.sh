#!/usr/bin/env bash
# Rofi Power Menu (Catppuccin Macchiato) with button style

rofi_theme="$HOME/.config/FxP/themes/rofi/powermenu/catppuccin-macchiato.rasi"

options="  Lock\n  Logout\n  Reboot\n  Shutdown"

chosen=$(echo -e "$options" | rofi \
    -theme "$rofi_theme" \
    -show-icons \
    -format "i" \
    -dmenu -p "" \
    -no-fixed-num-lines \
    -mesg "󰐥  Power Menu")

case $chosen in
    0) hyprlock ;;
    1) hyprctl dispatch exit 0 ;;
    2) systemctl reboot ;;
    3) systemctl poweroff ;;
esac

