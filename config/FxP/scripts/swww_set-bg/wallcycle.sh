#!/usr/bin/env bash
# 󰉋  SWWW Wallpaper Manager (Syntax Verified)

# CONFIGURATION
WALL_DIR="$HOME/.config/FxP/wallpapers"
TMP_DIR="$HOME/.config/FxP/tmp"
INITIAL_WALL="$WALL_DIR/default/linux-1.png"
DURATION=3
PID_FILE="/tmp/swww_wallpaper.pid"
SWWW_LOG="/tmp/swww-daemon.log"

# CLEANUP FUNCTION
cleanup() {
    [[ -f "$PID_FILE" ]] && rm -f "$PID_FILE"
    exit 0
}
trap cleanup INT TERM EXIT

# CREATE DIRECTORIES
mkdir -p "$TMP_DIR" "$WALL_DIR/tmp" || exit 1

# SAFE SWWW INIT
init_swww() {
    if ! pgrep -x "swww-daemon" >/dev/null; then
        echo "Starting swww daemon..."
        swww-daemon 2>"$SWWW_LOG" &
        sleep 1
        
        if ! pgrep -x "swww-daemon" >/dev/null; then
            echo "Failed to start swww-daemon! Check $SWWW_LOG"
            exit 1
        fi
        
        [[ ! -f "$WALL_DIR/tmp/current_wall" ]] && set_wallpaper "$INITIAL_WALL"
    fi
}

# WALLPAPER SETTER
set_wallpaper() {
    local src="$1"
    local dest="$TMP_DIR/curr_wall.png"
    
    # Convert to PNG if needed
    if [[ "${src##*.}" != "png" ]]; then
        convert "$src" "$dest" 2>/dev/null || cp "$src" "$dest"
    else
        cp "$src" "$dest"
    fi
    
    # Apply with retry logic
    for _ in {1..3}; do
        if swww img "$dest" \
            --transition-type "grow" \
            --transition-duration "$DURATION" 2>/dev/null; then
            echo "$dest" > "$WALL_DIR/tmp/current_wall"
            notify-send -i "$dest" "Wallpaper Changed" "$(basename "$src")"
            return 0
        fi
        sleep 0.5
    done
    
    echo "Failed to set wallpaper after 3 attempts"
    return 1
}

# GET RANDOM WALLPAPER
get_random_wallpaper() {
    local wallpapers=()
    while IFS= read -r -d $'\0' file; do
        [[ "$file" != "$INITIAL_WALL" ]] && wallpapers+=("$file")
    done < <(find "$WALL_DIR" -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) \
        -print0 2>/dev/null)
    
    [[ ${#wallpapers[@]} -eq 0 ]] && return 1
    echo "${wallpapers[RANDOM % ${#wallpapers[@]}]}"
}

# MAIN EXECUTION
init_swww
echo $$ > "$PID_FILE"

if wallpaper=$(get_random_wallpaper); then
    set_wallpaper "$wallpaper"
else
    echo "No wallpapers found in $WALL_DIR"
fi