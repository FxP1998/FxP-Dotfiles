#!/bin/zsh

sink=$(pactl info | grep 'Default Sink' | cut -d':' -f2 | xargs)
current=$(pactl get-sink-volume "$sink" | grep -oP '\d+%' | head -1 | tr -d '%')

new_volume=$((current - 10))

if [ $new_volume -lt 0 ]; then
    new_volume=0
fi

pactl set-sink-volume "$sink" ${new_volume}%

