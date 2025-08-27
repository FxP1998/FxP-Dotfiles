#!/bin/bash

profile=$(powerprofilesctl get)

case "$profile" in
    performance)
        echo "⚡ Performance"
        ;;
    balanced)
        echo "🧠 Balanced"
        ;;
    power-saver)
        echo "  Power Saver"
        ;;
    *)
        echo "❓Unknown"
        ;;
esac

