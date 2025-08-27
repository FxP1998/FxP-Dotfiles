#!/bin/bash
pid=$(hyprctl activewindow -j | grep -oP '(?<="pid": )\d+')
if [ -n "$pid" ]; then
    kill -9 $pid
    hyprctl notify -1 4000 "rgb(2ecc40)" "Force kill: Success"
else
    hyprctl notify -1 4000 "rgb(ff4136)" "Force kill: No active window!"
fi

