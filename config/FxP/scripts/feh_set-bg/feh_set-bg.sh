#!/bin/bash
# ~/.config/FxP/scripts/set-initial-wallpaper.sh
# This runs once at boot via exec-once

INITIAL_WALL="$HOME/.config/FxP/wallpapers/default/punk.png"
feh --no-fehbg --bg-scale "$INITIAL_WALL"
