#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#       TERMUX MOBILE TACTICAL CONTROL DASHBOARD
# ============================================================
#       One-command launcher + automatic setup
#       GitHub: https://github.com/ArindamSr/termux-tools
# ============================================================

# ---------------- COLORS ----------------

GREEN='\033[0;32m'
LIGHT_GREEN='\033[1;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
FLASH_RED='\033[5;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# ---------------- CONFIG ----------------

REPO="https://github.com/ArindamSr/termux-tools.git"
INSTALL_DIR="$HOME/termux-tools"
LAUNCHER="$PREFIX/bin/ttools"

# ============================================================
#                  BASIC FUNCTIONS
# ============================================================

pause_screen() {
    echo
    read -p "Press [Enter] to return..."
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================================
#              AUTOMATIC DEPENDENCY SETUP
# ============================================================

setup_dependencies() {

    echo -e "${CYAN}"
    echo "=========================================================="
    echo "          TERMUX TOOLS ENVIRONMENT CHECK"
    echo "=========================================================="
    echo -e "${NC}"

    missing=()

    command_exists git || missing+=("git")
    command_exists python || missing+=("python")
    command_exists nano || missing+=("nano")
    command_exists yt-dlp || missing+=("yt-dlp")
    command_exists termux-battery-status || missing+=("termux-api")

    if [ "${#missing[@]}" -eq 0 ]; then
        echo -e "${GREEN}[✓] All required tools are installed.${NC}"
        return
    fi

    echo -e "${YELLOW}[!] Missing components detected:${NC}"

    for item in "${missing[@]}"; do
        echo -e "    ${RED}•${NC} $item"
    done

    echo
    echo -e "${CYAN}[*] Installing missing components...${NC}"

    pkg update -y >/dev/null 2>&1

    # Install normal packages
    pkg install -y git python nano >/dev/null 2>&1

    # yt-dlp
    if ! command_exists yt-dlp; then
        pkg install -y yt-dlp >/dev/null 2>&1
    fi

    # Termux API
    if ! command_exists termux-battery-status; then
        pkg install -y termux-api >/dev/null 2>&1
    fi

    echo
    echo -e "${GREEN}[✓] Environment setup complete.${NC}"
}

# ============================================================
#                   STORAGE SETUP
# ============================================================

init_storage() {

    if [ ! -d "$HOME/storage" ]; then

        echo
        echo -e "${YELLOW}[!] Android storage permission required.${NC}"
        echo -e "${CYAN}[*] Opening Android storage permission dialog...${NC}"

        if command_exists termux-setup-storage; then
            termux-setup-storage
            sleep 2
        else
            echo -e "${RED}[!] termux-api/storage tools unavailable.${NC}"
        fi
    fi
}

# ============================================================
#               CREATE GLOBAL COMMAND
# ============================================================

create_launcher() {

    if [ ! -d "$INSTALL_DIR" ]; then
        return
    fi

    cat > "$LAUNCHER" <<'LAUNCHER_EOF'
#!/data/data/com.termux/files/usr/bin/bash

REPO="https://github.com/ArindamSr/termux-tools.git"
INSTALL_DIR="$HOME/termux-tools"

# If installation is missing, restore it
if [ ! -d "$INSTALL_DIR/.git" ]; then

    echo "[!] Termux Tools installation not found."
    echo "[+] Downloading from GitHub..."

    rm -rf "$INSTALL_DIR"

    git clone "$REPO" "$INSTALL_DIR" || {
        echo "[!] Failed to download repository."
        exit 1
    }
fi

cd "$INSTALL_DIR" || exit 1

# Automatically update from GitHub
echo "[+] Checking GitHub for updates..."

git pull --ff-only 2>/dev/null || true

chmod +x menu.sh

# Run dashboard
exec bash menu.sh
LAUNCHER_EOF

    chmod +x "$LAUNCHER"
}

# ============================================================
#                    FIRST RUN SETUP
# ============================================================

first_run_setup() {

    setup_dependencies
    init_storage

    # If this script is not inside the repository,
    # automatically clone the repository.

    if [ ! -d "$INSTALL_DIR/.git" ]; then

        echo
        echo -e "${CYAN}[*] Installing Termux Tools repository...${NC}"

        if command_exists git; then

            rm -rf "$INSTALL_DIR"

            git clone "$REPO" "$INSTALL_DIR"

            if [ $? -ne 0 ]; then
                echo -e "${RED}[!] GitHub download failed.${NC}"
                return 1
            fi

        else
            echo -e "${RED}[!] Git is not installed.${NC}"
            return 1
        fi
    fi

    chmod +x "$INSTALL_DIR/menu.sh"

    create_launcher

    echo
    echo -e "${GREEN}==========================================================${NC}"
    echo -e "${GREEN}             TERMUX TOOLS READY${NC}"
    echo -e "${GREEN}==========================================================${NC}"
    echo
    echo -e "You can now launch everything using:"
    echo
    echo -e "       ${LIGHT_GREEN}ttools${NC}"
    echo
    echo -e "${GREEN}==========================================================${NC}"
}

# ============================================================
#                 AUTOMATIC INITIALIZATION
# ============================================================

setup_dependencies

# Make sure storage exists
init_storage

# If this script is running from the repository,
# create the global launcher.

if [ -d "$INSTALL_DIR/.git" ]; then
    create_launcher
fi

# ============================================================
#                    DASHBOARD MENU
# ============================================================

show_menu() {

    clear

    echo -e "${GREEN}┌────────────────────────────────────────────────────────┐${NC}"
    echo -e "${GREEN}│${LIGHT_GREEN}  [!] TACTICAL MOBILE DATA RECON & MANAGEMENT MATRIX ${GREEN}│${NC}"
    echo -e "${GREEN}└────────────────────────────────────────────────────────┘${NC}"

    echo -e " ${CYAN}SYSTEM STATUS:${NC} ONLINE   ${CYAN}STORAGE:${NC} LINKED   ${CYAN}KERNEL:${NC} SECURE"

    echo -e "${GREEN}──────────────────────────────────────────────────────────${NC}"

    echo -e "  ${LIGHT_GREEN}[1]${NC} Bulk Image Organizer (Scrape & Clear Clutter)"
    echo -e "  ${LIGHT_GREEN}[2]${NC} Wireless Phone-to-PC File Drop (Local Web Node)"
    echo -e "  ${LIGHT_GREEN}[3]${NC} Universal Media Ripper & Audio Extractor (yt-dlp)"
    echo -e "  ${LIGHT_GREEN}[4]${NC} Android Application Fast-Launcher Engine"
    echo -e "  ${LIGHT_GREEN}[5]${NC} Text Editor Portal & Code Notes Workspace"

    echo -e "  ${RED}──[ ADVANCED AUTOMATIONS & CYBER SIMULATIONS ]──${NC}"

    echo -e "  ${YELLOW}[6]${NC} Automated Thermal Battery Watchdog (Overheat Alert)"
    echo -e "  ${YELLOW}[7]${NC} Interactive Cyber-Threat Matrix (Hacker Simulator)"
    echo -e "  ${RED}[8] Emergency Terminal Killswitch (Exit)${NC}"

    echo -e "${GREEN}──────────────────────────────────────────────────────────${NC}"

    echo -n " [?] Input Terminal Directive [1-8]: "
}

# ============================================================
#                  1. IMAGE ORGANIZER
# ============================================================

organize_images() {

    echo -e "\n${GREEN}[+] Executing File Organization Operations...${NC}"

    init_storage

    CAMERA_DIR="$HOME/storage/dcim/Camera"
    TARGET_DIR="$HOME/storage/pictures/Organized_Photos"

    if [ ! -d "$CAMERA_DIR" ]; then

        echo -e "${RED}[!] Camera directory not found:${NC}"
        echo "$CAMERA_DIR"

        pause_screen
        return
    fi

    mkdir -p \
        "$TARGET_DIR/Screenshots" \
        "$TARGET_DIR/Photos"

    sc_count=0
    ph_count=0

    shopt -s nullglob

    for file in "$CAMERA_DIR"/*; do

        if [[ -f "$file" && "$file" =~ \.(jpg|jpeg|png|webp|JPG|JPEG|PNG|WEBP)$ ]]; then

            filename=$(basename "$file")

            echo -e "${CYAN}[*] Processing: $filename${NC}"

            if [[ "$filename" == *"Screenshot"* || "$filename" == *"screenshot"* ]]; then

                mv "$file" "$TARGET_DIR/Screenshots/"
                ((sc_count++))

            else

                YEAR=$(date -r "$file" +"%Y")
                MONTH=$(date -r "$file" +"%m")

                mkdir -p "$TARGET_DIR/Photos/$YEAR-$MONTH"

                mv "$file" "$TARGET_DIR/Photos/$YEAR-$MONTH/"

                ((ph_count++))
            fi
        fi
    done

    shopt -u nullglob

    echo
    echo -e "${GREEN}[✓] Operation complete.${NC}"
    echo -e "${CYAN}Screenshots organized:${NC} $sc_count"
    echo -e "${CYAN}Photos organized:${NC} $ph_count"

    pause_screen
}

# ============================================================
#               2. WIRELESS FILE SHARING
# ============================================================

wireless_share() {

    echo -e "\n${GREEN}[+] Initializing Wireless Web Data Node...${NC}"

    init_storage

    ip_addr=""

    if command_exists ip; then
        ip_addr=$(ip addr show wlan0 2>/dev/null |
            grep -m1 'inet ' |
            awk '{print $2}' |
            cut -d/ -f1)
    fi

    if [ -z "$ip_addr" ]; then

        echo -e "${RED}[!] Wi-Fi interface IP could not be detected.${NC}"
        echo -e "${YELLOW}[!] Connect your phone to Wi-Fi or hotspot first.${NC}"

        pause_screen
        return
    fi

    echo
    echo -e "${YELLOW}[!] Local Web Server Active${NC}"
    echo
    echo -e "${LIGHT_GREEN}--> Open this address on your PC:${NC}"
    echo
    echo -e "${LIGHT_GREEN}    http://$ip_addr:8080${NC}"
    echo
    echo -e "${RED}[!] Press CTRL+C to stop the server.${NC}"
    echo

    cd "$HOME/storage" || return

    python -m http.server 8080
}

# ============================================================
#                3. MEDIA DOWNLOADER
# ============================================================

media_ripper() {

    echo -e "\n${GREEN}[+] Initializing Universal Media Downloader...${NC}"

    init_storage

    if ! command_exists yt-dlp; then

        echo -e "${YELLOW}[!] yt-dlp is not installed.${NC}"
        echo -e "${CYAN}[*] Installing yt-dlp...${NC}"

        pkg install -y yt-dlp
    fi

    echo
    echo -n " [?] Paste Target Video Source URL: "
    read -r media_url

    if [ -z "$media_url" ]; then

        echo -e "${RED}[!] No URL entered.${NC}"
        pause_screen
        return
    fi

    DOWNLOAD_DIR="$HOME/storage/downloads/TermuxRippedMedia"

    mkdir -p "$DOWNLOAD_DIR"

    cd "$DOWNLOAD_DIR" || return

    echo
    echo -e "${CYAN}[*] Downloading media...${NC}"

    yt-dlp "$media_url"

    echo
    echo -e "${GREEN}[✓] Download operation complete.${NC}"
    echo -e "${CYAN}Location:${NC}"
    echo "$DOWNLOAD_DIR"

    pause_screen
}

# ============================================================
#                  4. APP LAUNCHER
# ============================================================

app_launcher() {

    echo -e "\n${GREEN}[+] Mapping Android Application Manager...${NC}"

    echo
    echo " 1) WhatsApp"
    echo " 2) YouTube"
    echo " 3) Android Settings"
    echo " 4) Google Chrome"
    echo " 5) Back"
    echo

    echo -n " [?] Select application [1-5]: "
    read -r app_opt

    case "$app_opt" in

        1)
            am start -n com.whatsapp/.Main
            ;;

        2)
            am start -n com.google.android.youtube/com.google.android.apps.youtube.app.watchwhile.WatchWhileActivity
            ;;

        3)
            am start -a android.settings.SETTINGS
            ;;

        4)
            am start -n com.android.chrome/com.google.android.apps.chrome.Main
            ;;

        5)
            return
            ;;

        *)
            echo -e "${RED}[!] Invalid application selection.${NC}"
            ;;
    esac

    sleep 1
}

# ============================================================
#                    5. TEXT EDITOR
# ============================================================

text_portal() {

    echo -e "\n${GREEN}[+] Opening Local Text Workspace...${NC}"

    echo
    echo -n " [?] File name (example: notes.txt): "

    read -r note_title

    if [ -z "$note_title" ]; then

        echo -e "${RED}[!] Filename cannot be empty.${NC}"
        pause_screen
        return
    fi

    nano "$HOME/$note_title"
}

# ============================================================
#              6. BATTERY WATCHDOG
# ============================================================

battery_watchdog() {

    clear

    echo -e "${YELLOW}=======================================================${NC}"
    echo -e "       [!] AUTOMATED THERMAL SYSTEM GUARD ACTIVE"
    echo -e "${YELLOW}=======================================================${NC}"

    echo
    echo -e "${CYAN}[*] Monitoring battery every 5 seconds...${NC}"
    echo -e "${RED}[!] Press CTRL+C to terminate.${NC}"
    echo

    sleep 1

    while true; do

        stats=$(termux-battery-status 2>/dev/null)

        pct=$(echo "$stats" |
            sed -n 's/.*"percentage":[[:space:]]*\([0-9]*\).*/\1/p')

        temp=$(echo "$stats" |
            sed -n 's/.*"temperature":[[:space:]]*\([0-9.]*\).*/\1/p')

        if [ -z "$pct" ]; then
            pct="N/A"
        fi

        if [ -z "$temp" ]; then
            temp="N/A"
        fi

        echo -e "-> ${GREEN}[GUARD DATA]${NC} Battery Charge: ${LIGHT_GREEN}${pct}%${NC} | Temperature: ${YELLOW}${temp}°C${NC}"

        # Battery alert
        if [[ "$pct" =~ ^[0-9]+$ ]] && [ "$pct" -ge 80 ]; then

            if command_exists termux-toast; then
                termux-toast "Battery Protection: Battery is at ${pct}%"
            fi

            if command_exists termux-vibrate; then
                termux-vibrate -d 300
            fi
        fi

        # Temperature alert
        if [[ "$temp" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then

            hot=$(awk "BEGIN {print ($temp >= 42)}")

            if [ "$hot" -eq 1 ]; then

                echo -e "${FLASH_RED}[CRITICAL WARNING] HIGH TEMPERATURE DETECTED!${NC}"

                if command_exists termux-vibrate; then
                    termux-vibrate -d 1000
                fi
            fi
        fi

        sleep 5
    done
}

# ============================================================
#                 7. CYBER SIMULATOR
# ============================================================

cyber_simulator() {

    clear

    echo -e "${GREEN}[+] Booting Cryptographic Simulation Layer...${NC}"
    sleep 1

    ports_arr=(22 80 443 8080 3306 21 445)

    for i in {1..80}; do

        rand1=$((RANDOM % 255))
        rand2=$((RANDOM % 255))
        rand3=$((RANDOM % 255))
        rand4=$((RANDOM % 255))

        rand_port=${ports_arr[$((RANDOM % ${#ports_arr[@]}))]}

        if [ $((i % 4)) -eq 0 ]; then

            echo -e "${FLASH_RED}[SIMULATION] INTRUSION EVENT${NC} Port signature :$rand_port"

        elif [ $((i % 3)) -eq 0 ]; then

            echo -e "${CYAN}[SIMULATION]${NC} Routing data through encrypted tunnel -> ${rand1}.${rand2}.${rand3}.${rand4}"

        else

            echo -e "${GREEN}[OK]${NC} Processing handshake [0x${rand1}FF${rand3}A:${rand_port}]... ${LIGHT_GREEN}SUCCESS${NC}"
        fi

        sleep 0.04
    done

    echo
    echo -e "${YELLOW}=== NETWORK TELEMETRY SIMULATION COMPLETE ===${NC}"
    echo
    echo -e " Local Interfaces: ${LIGHT_GREEN}wlan0, lo, rmnet_data0${NC}"
    echo -e " Simulation Status: ${LIGHT_GREEN}STABLE${NC}"
    echo

    pause_screen
}

# ============================================================
#                     MAIN LOOP
# ============================================================

while true; do

    show_menu

    read -r opt

    case "$opt" in

        1)
            organize_images
            ;;

        2)
            wireless_share
            ;;

        3)
            media_ripper
            ;;

        4)
            app_launcher
            ;;

        5)
            text_portal
            ;;

        6)
            battery_watchdog
            ;;

        7)
            cyber_simulator
            ;;

        8)
            clear
            echo
            echo -e "${YELLOW}[!] Shutting down tactical interfaces...${NC}"
            echo -e "${GREEN}[✓] Session terminated. Goodbye!${NC}"
            echo
            exit 0
            ;;

        *)
            echo
            echo -e "${RED}[!] Directive unreadable. Re-input parameter.${NC}"
            sleep 1
            ;;
    esac

done
