#!/usr/bin/env bash
# Termux Mobile Tactical Control Dashboard
# Features deep Android automation wrapped in a high-tech terminal matrix interface

# Colors for a sleek, intimidating hacking aesthetic
GREEN='\033[0;32m'
LIGHT_GREEN='\033[1;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
FLASH_RED='\033[5;31m'
NC='\033[0m'

init_storage() {
    if [ ! -d "$HOME/storage" ]; then
        echo -e "${YELLOW}[!] Mapping system storage framework...${NC}"
        termux-setup-storage
        sleep 2
    fi
}

# The Hollywood Hacking Matrix Banner
show_menu() {
    clear
    echo -e "${GREEN}┌────────────────────────────────────────────────────────┐${NC}"
    echo -e "${GREEN}│${LIGHT_GREEN}  [!] TACTICAL MOBILE DATA RECON & MANAGEMENT MATRIX   ${GREEN}│${NC}"
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

# 1. Bulk Image Organizer
organize_images() {
    echo -e "\n${GREEN}[+] Executing File Scrape Operations...${NC}"
    init_storage
    CAMERA_DIR="$HOME/storage/dcim/Camera"
    TARGET_DIR="$HOME/storage/pictures/Organized_Photos"

    if [ ! -d "$CAMERA_DIR" ]; then
        echo -e "${RED}[!] Error: Targeted file pathway not found: $CAMERA_DIR${NC}"
        read -p "Press [Enter] to cycle..."
        return
    fi

    mkdir -p "$TARGET_DIR/Screenshots" "$TARGET_DIR/Photos"
    sc_count=0; ph_count=0

    for file in "$CAMERA_DIR"/*; do
        if [[ -f "$file" && "$file" =~ \.(jpg|jpeg|png|webp|JPG|JPEG|PNG)$ ]]; then
            filename=$(basename "$file")
            echo -e "${CYAN}[*] Intercepting: $filename${NC}"
            if [[ "$filename" == *"Screenshot"* || "$filename" == *"screenshot"* ]]; then
                mv "$file" "$TARGET_DIR/Screenshots/"
                ((sc_count++))
            else
                YEAR=$(date -r "$file" +"%Y"); MONTH=$(date -r "$file" +"%m")
                mkdir -p "$TARGET_DIR/Photos/$YEAR-$MONTH"
                mv "$file" "$TARGET_DIR/Photos/$YEAR-$MONTH/"
                ((ph_count++))
            fi
        fi
    done
    echo -e "${GREEN}[✓] Operation Successful. Screenshots Isolated: $sc_count | Sorted Photos: $ph_count${NC}"
    read -p "Press [Enter] to return..."
}

# 2. Wireless File Sharing Link
wireless_share() {
    echo -e "\n${GREEN}[+] Initializing Wireless Web Data Node...${NC}"
    init_storage
    ip_addr=$(ifconfig wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}')
    if [ -z "$ip_addr" ]; then ip_addr=$(ip a show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1); fi
    
    if [ -z "$ip_addr" ]; then
        echo -e "${RED}[!] Local Network Interface Offline. Connect to Wi-Fi/Hotspot.${NC}"
    else
        echo -e "${YELLOW}[!] Web Server Broadcasting! Access via external local browser:${NC}"
        echo -e "${LIGHT_GREEN}--> Target Link: http://$ip_addr:8080${NC}"
        echo -e "${RED}[!] To terminate server broadcast, press [CTRL + C]${NC}\n"
        cd "$HOME/storage" && python -m http.server 8080
    fi
    read -p "Press [Enter] to return..."
}

# 3. Media Downloader Engine
media_ripper() {
    echo -e "\n${GREEN}[+] Initializing Universal Media Stream Extraction...${NC}"
    init_storage
    echo -n " [?] Paste Target Video Source URL: "
    read -r media_url
    DOWNLOAD_DIR="$HOME/storage/downloads/TermuxRippedMedia"
    mkdir -p "$DOWNLOAD_DIR" && cd "$DOWNLOAD_DIR" || exit
    echo -e "${CYAN}[*] Fetching encryption layers and ripping video streams...${NC}"
    yt-dlp "$media_url"
    echo -e "${GREEN}[✓] Payload intercept complete. File dropped into /Downloads/TermuxRippedMedia/${NC}"
    read -p "Press [Enter] to return..."
}

# 4. App Fast-Launcher
app_launcher() {
    echo -e "\n${GREEN}[+] Mapping Android Component Manager...${NC}"
    echo -e " 1) WhatsApp  2) YouTube  3) Android Settings  4) Google Chrome Browser"
    echo -n " [?] Select target component to inject [1-4]: "
    read -r app_opt
    case $app_opt in
        1) am start -n com.whatsapp/.Main ;;
        2) am start -n com.google.android.youtube/com.google.android.apps.youtube.app.watchwhile.WatchWhileActivity ;;
        3) am start -a android.settings.SETTINGS ;;
        4) am start -n com.android.chrome/com.google.android.apps.chrome.Main ;;
        *) echo -e "${RED}[!] Injection failed: Invalid target signature.${NC}" ;;
    esac
    sleep 1
}

# 5. Note Workspace
text_portal() {
    echo -e "\n${GREEN}[+] Opening Secure Local Text Framework...${NC}"
    echo -n " [?] Title of file to compile (e.g., system_logs.txt): "
    read -r note_title
    nano "$HOME/$note_title"
}

# 6. Automated Thermal Battery Watchdog
battery_watchdog() {
    clear
    echo -e "${YELLOW}=======================================================${NC}"
    echo -e "   [!] AUTOMATED THERMAL SYSTEM GUARD & DAEMON ACTIVE  "
    echo -e "${YELLOW}=======================================================${NC}"
    echo -e "${CYAN}[*] Monitoring loop initialized. Running security cycle every 5 seconds...${NC}"
    echo -e "${RED}[!] Press [CTRL + C] to terminate the monitoring daemon.${NC}\n"
    sleep 1
    
    while true; do
        # Extract temperature and percentage values using system commands
        stats=$(termux-battery-status 2>/dev/null)
        pct=$(echo "$stats" | grep -i "percentage" | tr -cd '0-9')
        temp=$(echo "$stats" | grep -i "temperature" | tr -cd '0-9')
        # Format temperature decimal point
        real_temp="${temp:0:2}.${temp:2:1}"
        
        echo -e "-> ${GREEN}[GUARD DATA]${NC} Battery Charge: ${LIGHT_GREEN}${pct}%${NC} | Motherboard Temperature: ${YELLOW}${real_temp}°C${NC}"
        
        # Trigger physical feedback alerts if rules match
        if [ "$pct" -ge 80 ]; then
            termux-toast "Battery Protection Triggered: Charged to stable 80%"
            termux-vibrate -d 300
        fi
        
        # Check for overheat parameters
        if [ "${temp:0:2}" -ge 42 ]; then
            echo -e "${FLASH_RED}[CRITICAL WARNING] HARDWARE OVERHEATING DETECTED!${NC}"
            termux-vibrate -d 1000
        fi
        sleep 5
    done
}

# 7. Interactive Cyber-Threat Matrix (Hollywood Hacker Simulator)
cyber_simulator() {
    clear
    echo -e "${GREEN}[+] Booting Decryption Cryptographic Layer...${NC}"
    sleep 1
    
    # Fast scrolling matrix sequence
    for i in {1..80}; do
        rand1=$((RANDOM % 255)); rand2=$((RANDOM % 255)); rand3=$((RANDOM % 255)); rand4=$((RANDOM % 255))
        ports_arr=(22 80 443 8080 3306 21 445)
        rand_port=${ports_arr[$((RANDOM % 7))]}
        
        if [ $((i % 4)) -eq 0 ]; then
            echo -e "${FLASH_RED}[CRITICAL INTRUSION DETECTED]${NC} Port Scan matching signature on Local Host :$rand_port"
        elif [ $((i % 3)) -eq 0 ]; then
            echo -e "${CYAN}[INFO]${NC} Routing outgoing data blocks through encryption tunnel -> Proxy IP: $rand1.$rand2.$rand3.$rand4"
        else
            echo -e "${GREEN}[OK]${NC} Decrypting system handshake array packet [0x${rand1}FF${rand3}A:${rand_port}]... ${LIGHT_GREEN}SUCCESS${NC}"
        fi
        usleep 40000
    done

    echo -e "\n${YELLOW}=== NETWORK TELEMETRY SWEEP COMPLETE ===${NC}"
    echo -e " Local Interfaces Scanned: ${LIGHT_GREEN}wlan0, lo, rmnet_data0${NC}"
    echo -e " Cryptographic Grid Status: ${LIGHT_GREEN}STABLE & DECRYPTED${NC}"
    echo -e "${RED}Warning: Screen tracking records compiled.${NC}\n"
    read -p "Press [Enter] to disconnect from matrix network..."
}

# Main Event Execution Loop
while true; do
    show_menu
    read -r opt
    case $opt in
        1) organize_images ;;
        2) wireless_share ;;
        3) media_ripper ;;
        4) app_launcher ;;
        5) text_portal ;;
        6) battery_watchdog ;;
        7) cyber_simulator ;;
        8) echo -e "\n${YELLOW}[!] Shutting down tactical interfaces... Goodbye!${NC}"; exit 0 ;;
        *) echo -e "\n${RED}[!] Directive unreadable. Re-input parameter.${NC}"; sleep 1 ;;
    esac
done
