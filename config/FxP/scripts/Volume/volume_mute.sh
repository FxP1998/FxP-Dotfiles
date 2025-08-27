#!/bin/zsh

sink=$(pactl info | grep 'Default Sink' | cut -d':' -f2 | xargs)
pactl set-sink-mute "$sink" toggle

