#!/bin/bash
# Outputs one of the pywal colors to use in waybar
cat ~/.cache/wal/colors.json | jq -r '.colors.color1'
