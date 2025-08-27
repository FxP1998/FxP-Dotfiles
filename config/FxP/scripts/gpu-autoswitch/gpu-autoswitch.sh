#!/bin/bash

APPS_LIST="$HOME/.config/gpu-switch/apps.conf"
LOGFILE="$HOME/.local/share/gpu-autoswitch.log"

mkdir -p "$(dirname "$LOGFILE")"

while true; do
    while read -r app; do
        # Check if app is running WITHOUT AMD vars
        if pgrep -x "$app" > /dev/null; then
            # Kill Intel version
            pkill -x "$app"

            # Relaunch on AMD
            echo "$(date): Relaunching $app on AMD GPU" >> "$LOGFILE"
            DRI_PRIME=1 LIBVA_DRIVER_NAME=radeonsi "$app" &
        fi
    done < "$APPS_LIST"
    sleep 2
done

