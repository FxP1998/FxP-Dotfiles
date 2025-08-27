#!/bin/bash

# ── Nerd Font Icons ───────────────────────────────────────────
icon_start=""          # nf-fa-code
icon_config=""         # nf-seti-config
icon_home=""           # nf-fa-home
icon_copy=""           # nf-fa-share_square_o
icon_check=""          # nf-fa-check_circle
icon_warn=""           # nf-fa-warning
icon_error=""          # nf-fa-times_circle
icon_git=""            # nf-dev-git
icon_add=""            # nf-fa-plus
icon_commit=""         # nf-oct-git_commit
icon_pull=""           # nf-fa-long_arrow_left
icon_push=""           # nf-fa-long_arrow_up
icon_spinner=('⠋' '⠙' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
icon_done=""           # nf-fa-check
icon_cleanup=""        # nf-oct-trashcan
icon_notify=""         # nf-fa-bullhorn
icon_time=""           # nf-fa-clock_o
icon_key=""            # nf-fa-key
icon_link=""           # nf-fa-link

# ── Colors ───────────────────────────────────────────────────
RED='\e[31m'; GREEN='\e[32m'; YELLOW='\e[33m'; CYAN='\e[36m'
MAGENTA='\e[35m'; BOLD='\e[1m'; NC='\e[0m'

# ── GitHub Config ────────────────────────────────────────────
GITHUB_REPO_OWNER="FxP1998"
GITHUB_REPO_NAME="FxP"
EXPECTED_REPO="$GITHUB_REPO_OWNER/$GITHUB_REPO_NAME"
GIT_BRANCH="main"
GITHUB_REMOTE="origin"

# ── Backup Config ────────────────────────────────────────────
CONFIG_BACKUP_DIR="$HOME/FxP/config"
HOME_BACKUP_DIR="$HOME/FxP/home"
TEMP_BACKUP_DIR="$HOME/FxP_backup"
# Clean old backup first to avoid piling up
rm -rf "$TEMP_BACKUP_DIR"
mkdir -p "$TEMP_BACKUP_DIR"


# ── Files to Backup ──────────────────────────────────────────
CONFIG_FILES_TO_BACKUP=(
    "$HOME/.config/alacritty"
    "$HOME/.config/gtk-4.0"
    "$HOME/.config/gtk-3.0"
    "$HOME/.config/htop"
    "$HOME/.config/btop"
    "$HOME/.config/hypr"
    "$HOME/.config/hypr.default"
    "$HOME/.config/cava"
    "$HOME/.config/kitty"
    "$HOME/.config/mpv"
    "$HOME/.config/nwg-look"
    "$HOME/.config/waybar"
    "$HOME/.config/nautilus"
    "$HOME/.config/yazi"
    "$HOME/.config/obs-studio"
    "$HOME/.config/xsettingsd"
    "$HOME/.config/FxP"
    "$HOME/.config/starship"
    "$HOME/.config/xdg-desktop-portal"
    "$HOME/.config/xdg-desktop-portal-kderc"
    "$HOME/.config/zed"
    "$HOME/.config/systemd"
    "$HOME/.config/rofi"
    "$HOME/.config/kde.org"
    "$HOME/.config/menus"
    "$HOME/.config/qt5ct"
    "$HOME/.config/qt6ct"
    "$HOME/.config/qtvirtualkeyboard"
    "$HOME/.config/session"
    "$HOME/.config/dolphinrc"
    "$HOME/.config/electron-flags.conf"
    "$HOME/.config/kate"
    "$HOME/.config/nvim"
)

HOME_FILES_TO_BACKUP=(
    "$HOME/.icons"
    "$HOME/.fonts"
    "$HOME/.themes"
    "$HOME/.zshrc"
    "$HOME/.bashrc"
    "$HOME/.vimrc"
    "$HOME/.gtkrc-2.0"
    "$HOME/.vim"
)

# ── Logging Functions ────────────────────────────────────────
log()        { echo -e "${CYAN}${icon_time}  [$(date +"%H:%M:%S")]${NC} $1"; }
notify()     { command -v notify-send &>/dev/null && notify-send "${icon_notify} Backup Script" "$1"; }
log_success(){ echo -e "${GREEN}${icon_check}  $1${NC}"; }
log_warn()   { echo -e "${YELLOW}${icon_warn}  $1${NC}"; }
log_error()  { echo -e "${RED}${icon_error}  $1${NC}"; }

# ── Spinner ─────────────────────────────────────────────────
spinner() {
    local pid=$1; local msg=$2; local delay=0.1; local i=0
    while kill -0 $pid 2>/dev/null; do
        printf "\r${MAGENTA}${icon_spinner[i % ${#icon_spinner[@]}]}${NC} $msg"
        ((i++)); sleep $delay
    done
    printf "\r"
}

# ── Git Protection Functions ────────────────────────────────
verify_github_repo() {
    local current_remote=$(git remote get-url "$GITHUB_REMOTE" 2>/dev/null)

    if [ -z "$current_remote" ]; then
        log_error "Not in a Git repository!"
        return 1
    fi

    # Normalize SSH and HTTPS → extract "owner/repo"
    local repo_part_current=$(echo "$current_remote" \
        | tr '[:upper:]' '[:lower:]' \
        | sed -E 's#(git@|https://)github\.com[:/]##; s#\.git$##')

    local repo_part_expected=$(echo "$EXPECTED_REPO" | tr '[:upper:]' '[:lower:]')

    log "Debug - Repo part from current: '$repo_part_current'"
    log "Debug - Repo part from expected: '$repo_part_expected'"

    if [[ "$repo_part_current" != "$repo_part_expected" ]]; then
        log_error "DANGER: Wrong repository detected!"
        log_error "Expected: $EXPECTED_REPO"
        log_error "Current:  $current_remote"
        log_error "Comparison: '$repo_part_current' != '$repo_part_expected'"
        return 1
    fi

    log_success "Repository verification passed: $repo_part_current"
    return 0
}

# ── SSH Setup Wizard ────────────────────────────────────────
setup_ssh_authentication() {
    log "${icon_key} Starting SSH authentication setup..."

    local ssh_key_file="$HOME/.ssh/id_ed25519"
    if [ ! -f "$ssh_key_file" ] && [ ! -f "$HOME/.ssh/id_rsa" ]; then
        log_warn "No SSH key found. Generating a new one..."
        read -rp "Enter your GitHub email address: " github_email
        ssh-keygen -t ed25519 -C "$github_email" -f "$ssh_key_file"
        log_success "SSH key generated at: $ssh_key_file"
    else
        if [ -f "$ssh_key_file" ]; then
            log_success "Using existing SSH key: $ssh_key_file"
        else
            ssh_key_file="$HOME/.ssh/id_rsa"
            log_success "Using existing SSH key: $ssh_key_file"
        fi
    fi

    eval "$(ssh-agent -s)" > /dev/null
    ssh-add "$ssh_key_file"

    log "${icon_add} Please add this SSH key to your GitHub account:"
    cat "${ssh_key_file}.pub"
    echo -e "\nVisit: https://github.com/settings/ssh/new"

    read -rp "Have you added the key to GitHub? (y/N): " user_response
    if [[ ! "$user_response" =~ ^[Yy]$ ]]; then
        log_error "SSH key was not added. Cannot continue."
        return 1
    fi

    git remote set-url "$GITHUB_REMOTE" "git@github.com:${GITHUB_REPO_OWNER}/${GITHUB_REPO_NAME}.git"
    log_success "SSH authentication setup complete!"
    return 0
}

# ── Git Push with Retry ─────────────────────────────────────
git_push_with_retry() {
    local attempt=1
    local max_attempts=3

    while [ $attempt -le $max_attempts ]; do
        log "${icon_push} Push attempt $attempt/$max_attempts..."
        if git push origin main; then
            return 0   # ✅ success, stop here
        fi
        attempt=$((attempt + 1))
        sleep 2
    done

    return 1   # ❌ failed after retries
}
# ── Main Script ─────────────────────────────────────────────
main() {
    echo -e "${BOLD}${icon_start}  Starting FxP Backup & Push Script...${NC}"
    notify "Backup script started"

    # 1. Backup existing ~/.FxP
    log "${icon_copy} Backing up old ~/FxP..."
    mkdir -p "$TEMP_BACKUP_DIR"
    cp -r "$HOME/FxP"/* "$TEMP_BACKUP_DIR" 2>/dev/null && \
        log_success "Old backup saved to $TEMP_BACKUP_DIR" || \
        log_warn "No previous backup available"

    # 2. Fresh backup dirs
    log "${icon_config} Creating fresh backup directories..."
    mkdir -p "$CONFIG_BACKUP_DIR" "$HOME_BACKUP_DIR"

    # 3. Backup config files
    log "${icon_config} Backing up config files..."
    for item in "${CONFIG_FILES_TO_BACKUP[@]}"; do
        name=$(basename "$item")
        if [ -e "$item" ]; then
            # Exclude .git folders for nested repos (but keep FxP repo intact)
            if [[ "$item" == "$HOME/.config/FxP" ]]; then
                # Special case: keep FxP repo with its .git
                cp -r "$item" "$CONFIG_BACKUP_DIR"/ 2>/dev/null && \
                    log_success "Config (repo): $name" || log_warn "Failed: $name"
            else
              rsync -a --exclude='.git' "$item" "$CONFIG_BACKUP_DIR"/ 2>/dev/null && \
                    log_success "Config: $name" || log_warn "Failed: $name"
            fi
        else
          log_warn "Config: $name not found"
        fi
    done


    # 4. Home backup
    log "${icon_home} Backing up home files..."
    for item in "${HOME_FILES_TO_BACKUP[@]}"; do
        name=$(basename "$item")
        if [ -e "$item" ]; then
            cp -r "$item" "$HOME_BACKUP_DIR"/ 2>/dev/null && \
                log_success "Home: $name" || log_warn "Failed: $name"
        else
            log_warn "Home: $name not found"
        fi
    done

    # 5. Git operations
    cd "$HOME/FxP" || { log_error "Cannot enter ~/FxP"; exit 1; }

    log "${icon_git} Verifying repository..."
    verify_github_repo || { log_error "ABORTING: Repository verification failed"; exit 1; }

    log "${icon_add} Staging changes..."
    git add . || { log_error "Failed to stage changes"; exit 1; }

    log "${icon_commit} Committing changes..."
    git commit -m "FxP: Git pushed & committed via automatic script [$TIMESTAMP]" || log_warn "No new changes"

    log "${icon_pull} Updating from remote..."
    git pull --rebase "$GITHUB_REMOTE" "$GIT_BRANCH" || { log_error "Failed to update from remote"; exit 1; }

log "${icon_push} Pushing changes..."
if git_push_with_retry; then
    log_success "${icon_done} Push successful"
    notify "Backup completed successfully"

    log "${icon_cleanup} Cleaning up backup directory..."
    rm -rf "$TEMP_BACKUP_DIR" 2>/dev/null && log_success "Backup directory cleared"

    echo -e "${BOLD}${GREEN}${icon_done}  Backup & Push Finished Successfully!${NC}"
    exit 0
else
    log_error "FATAL: Failed to push backup"
    log_warn "Backup preserved at: $TEMP_BACKUP_DIR"
    notify "Backup failed: Could not push. Backup preserved."
    exit 1
fi

}

main "$@"

