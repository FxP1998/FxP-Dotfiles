#!/bin/bash

# Get current brightness (percentage)
current=$(brightnessctl get)
max=$(brightnessctl max)
min_brightness=05
max_brightness=100

# Convert current brightness to percentage
current_percent=$((100 * current / max))

# Get action: "up" or "down"
action=$1

if [ "$action" == "up" ]; then
    new_brightness=$((current_percent + 05))
    if [ $new_brightness -gt $max_brightness ]; then
        new_brightness=$max_brightness
    fi
elif [ "$action" == "down" ]; then
    new_brightness=$((current_percent - 05))
    if [ $new_brightness -lt $min_brightness ]; then
        new_brightness=$min_brightness
    fi
else
    echo "Usage: $0 up|down"
    exit 1
fi

# Set the brightness (convert back to absolute value)
new_value=$((new_brightness * max / 100))
brightnessctl set $new_value

