# === GPU Auto-Switch (Intel + AMD Hybrid Setup) ===

This README contains **everything in one place**: the script, config, systemd service, and setup commands.  
Copy-paste step by step and you’ll be ready.

---

## 📂 Step 1: Create Script + Configs

```bash
mkdir -p ~/.config/FxP/scripts/gpu-autoswitch

cat > ~/.config/FxP/scripts/gpu-autoswitch/gpu-autoswitch.sh << 'EOF'
#!/usr/bin/env bash
# GPU Auto-Switch Daemon
# Watches for apps in apps.conf and runs them on AMD GPU

APP_LIST="$HOME/.config/FxP/scripts/gpu-autoswitch/apps.conf"
LOGFILE="$HOME/.local/share/gpu-autoswitch.log"

mkdir -p "$(dirname "$LOGFILE")"

echo "[INFO] GPU AutoSwitch started at $(date)" >> "$LOGFILE"

while true; do
    while read -r app; do
        [[ -z "$app" || "$app" == \#* ]] && continue

        # Check if process is running with Intel
        pids=$(pgrep -x "$app")
        for pid in $pids; do
            # If not already using AMD, restart under AMD
            if ! grep -q "DRI_PRIME=1" "/proc/$pid/environ" 2>/dev/null; then
                echo "[SWITCH] Restarting $app on AMD GPU (PID=$pid)" >> "$LOGFILE"
                kill -9 "$pid"
                DRI_PRIME=1 nohup "$app" >/dev/null 2>&1 &
            fi
        done
    done < "$APP_LIST"
    sleep 5
done
EOF

chmod +x ~/.config/FxP/scripts/gpu-autoswitch/gpu-autoswitch.sh



## === Step 2: Add Apps List ===

cat > ~/.config/FxP/scripts/gpu-autoswitch/apps.conf << 'EOF'
# Apps that should run on AMD GPU
mpv
obs
wf-recorder
firefox
chromium
EOF




## === Step 3: Create Systemd Service ===

mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/gpu-autoswitch.service << 'EOF'
[Unit]
Description=GPU Auto-Switch Daemon
After=graphical.target

[Service]
ExecStart=%h/.config/FxP/scripts/gpu-autoswitch/gpu-autoswitch.sh
Restart=always

[Install]
WantedBy=default.target
EOF




## === Step 4: Enable Service ===

systemctl --user daemon-reload
systemctl --user enable --now gpu-autoswitch.service


## === Check status === 
systemctl --user status gpu-autoswitch.service

## === restart ===
systemctl --user restart gpu-autoswitch.service

## == check logs ===
tail -f ~/.local/share/gpu-autoswitch.log

