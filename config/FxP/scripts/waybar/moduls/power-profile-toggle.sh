#!/bin/bash

current=$(powerprofilesctl get)

case "$current" in
  performance)
    powerprofilesctl set power-saver
    ;;
  power-saver)
    powerprofilesctl set balanced
    ;;
  balanced)
    powerprofilesctl set performance
    ;;
esac

