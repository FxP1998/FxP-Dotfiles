#!/bin/bash

cava | while read -r line; do
  # Parse cava output line
  bars=$(echo "$line" | sed 's/ /▁/g')
  echo "{\"text\": \"$bars\", \"class\": \"cava\"}"
done

