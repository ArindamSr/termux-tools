#!/usr/bin/env bash
# Ultimate Termux Phone Manager Dashboard
# All-in-one suite for file organization, media ripping, wireless sharing, and app launching.

# Colors for UI
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Ensure storage is safely linked
init_storage() {
    if [ ! -d "$HOME/storage" ]; then
        echo -e "${YELLOW}[!] Setting up Android storage links...${NC}"
        termux-setup-storage
        sleep 3
    fi
}

show_menu() {
    clear
    echo -e "${CYAN}===========================================${NC}"
    echo -e "${GREEN}      ULTIMATE PHONE CONTROL DASHBOARD      ${NC}"
    echo -e "${CYAN}===========================================${NC}"
    echo -e "${YELLOW}1)${NC} Bulk Image Organizer (Sort Camera Roll)"
    echo -e "${YELLOW}2)${NC} Wireless Phone-to-PC Share (Start Server)"
    echo -e "${YELLOW}3)${NC} Lightning File Finder (Search Device)"
    echo -e "${YELLOW}4)${NC} Universal Media Ripper (Video/Audio Downloader)"
    echo -e "${YELLOW}5)${NC} App Fast-Launcher (Open Android Apps)"
    echo -e "${YELLOW}6)${NC} Text Editor Portal (Quick Notes & Docs)"
    echo -e "${YELLOW}7)${NC} Exit Dashboard"
    echo -e "${CYAN}===========================================${NC}"
    echo -n "Select an option [1-7]: "
}

# 1. Bulk Image Organizer
organize_images() {
    echo -e "\n${GREEN}[+] Starting Bulk Image Organizer...${NC}"
    init_storage
    CAMERA_DIR="$HOME/storage/dcim/Camera"
    TARGET_DIR="$HOME/storage/pictures/Organized_Photos"

    if [ ! -d "$CAMERA_DIR" ]; then
        echo -e "${RED}[!] Error: Camera directory not found at $CAMERA_DIR${NC}"
        read -p "Press [Enter] to return..."
        return
    fi

    mkdir -p "$TARGET_DIR/Screenshots" "$TARGET_DIR/Photos"
    screenshot_count=0
    photo_count=0

    for file in "$CAMERA_DIR"/*; do
        if [[ -f "$file" && "$file" =~ \.(jpg|jpeg|png|webp|JPG|JPEG|PNG)$ ]]; then
            filename=$(basename "$file")
            if [[ "$filename" == *"Screenshot"* || "$filename" == *"screenshot"* ]]; then
                mv "$file" "$TARGET_DIR/Screenshots/"
                ((screenshot_count++))
            else
                if [[ "$filename" =~ (20[0-9]{2})[-_]?([0-1][0-9]) ]]; then
                    YEAR="${BASH_REMATCH[1]}"
                    MONTH="${BASH_REMATCH[2]}"
                else
                    YEAR=$(date -r "$file" +"%Y")
                    MONTH=$(date -r "$file" +"%m")
                fi
                MONTH_DIR="$TARGET_DIR/Photos/$YEAR-$MONTH"
                mkdir -p "$MONTH_DIR"
                mv "$file" "$MONTH_DIR/"
                ((photo_count++))
            fi
        fi
    done
    echo -e "${GREEN}[✓] Success! screenshots moved: $screenshot_count, photos sorted: $photo_count.${NC}"
    read -p "Press [Enter] to return..."
}

# 2. Wireless Phone-to-PC Share
wireless_share() {
    echo -e "\n${GREEN}[+] Initializing Wireless HTTP Server...${NC}"
    init_storage
    ip_addr=$(ifconfig wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}')
    if [ -z "$ip_addr" ]; then
        ip_addr=$(ip a show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
    fi
    
    if [ -z "$ip_addr" ]; then
        echo -e "${RED}[!] Connection Error: Ensure you are linked to Wi-Fi or Hotspot.${NC}"
    else
        echo -e "${YELLOW}[!] Server running on your local network!${NC}"
        echo -e "${CYAN}--> On your PC browser, go to: http://$ip_addr:8080${NC}"
        echo -e "${RED}Press [CTRL + C] inside Termux to shut down the server.${NC}\n"
        cd "$HOME/storage" && python -m http.server 8080
    fi
    read -p "Press [Enter] to return..."
}

# 3. Lightning File Finder
file_finder() {
    echo -e "\n${GREEN}[+] Lightning File Finder${NC}"
    init_storage
    echo -n "Enter partial or full filename to search: "
    read -r search_term
    echo -e "${CYAN}[*] Searching phone storage (this may take a moment)...${NC}"
    find "$HOME/storage" -iname "*$search_term*" 2>/dev/null
    echo ""
    read -p "Search complete. Press [Enter] to return..."
}

# 4. Universal Media Ripper
media_ripper() {
    echo -e "\n${GREEN}[+] Universal Media Ripper${NC}"
    init_storage
    echo -n "Paste video/playlist URL: "
    read -r media_url
    echo -e "Choose format:\n1) Video (MP4)\n2) Audio Only (MP3)"
    echo -n "Selection [1-2]: "
    read -r format_opt
    
    DOWNLOAD_DIR="$HOME/storage/downloads/TermuxRippedMedia"
    mkdir -p "$DOWNLOAD_DIR" && cd "$DOWNLOAD_DIR" || exit
    
    if [ "$format_opt" == "2" ]; then
        yt-dlp -x --audio-format mp3 "$media_url"
    else
        yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" "$media_url"
    fi
    echo -e "${GREEN}[✓] Saved into Phone Downloads -> TermuxRippedMedia folder.${NC}"
    read -p "Press [Enter] to return..."
}

# 5. App Fast-Launcher
app_launcher() {
    echo -e "\n${GREEN}[+] Android App Fast-Launcher${NC}"
    echo -e "Select app to launch:\n1) WhatsApp\n2) YouTube\n3) Android Settings\n4) Chrome"
    echo -n "Selection [1-4]: "
    read -r app_opt
    case $app_opt in
        1) am start -n com.whatsapp/.Main ;;
        2) am start -n com.google.android.youtube/com.google.android.apps.youtube.app.watchwhile.WatchWhileActivity ;;
        3) am start -a android.settings.SETTINGS ;;
        4) am start -n com.android.chrome/com.google.android.apps.chrome.Main ;;
        *) echo -e "${RED}[!] Invalid Choice.${NC}" ;;
    esac
    sleep 1
}

# 6. Text Editor Portal
text_portal() {
    echo -e "\n${GREEN}[+] Text Editor Portal${NC}"
    NOTES_DIR="$HOME/storage/documents/TermuxNotes"
    mkdir -p "$NOTES_DIR"
    echo -e "1) Create New Note\n2) Open/Edit Existing Note"
    echo -n "Selection [1-2]: "
    read -r note_opt
    if [ "$note_opt" == "1" ]; then
        echo -n "Enter title for new note (e.g., shopping.txt): "
        read -r note_title
        nano "$NOTES_DIR/$note_title"
    else
        echo -e "${CYAN}[*] Current saved notes:${NC}"
        ls "$NOTES_DIR"
        echo -n "Enter exact filename to edit: "
        read -r edit_title
        nano "$NOTES_DIR/$edit_title"
    fi
}

# Main Event Loop
while true; do
    show_menu
    read -r opt
    case $opt in
        1) organize_images ;;
        2) wireless_share ;;
        3) file_finder ;;
        4) media_ripper ;;
        5) app_launcher ;;
        6) text_portal ;;
        7) echo -e "\n${YELLOW}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "\n${RED}[!] Invalid option!${NC}"; sleep 1 ;;
    esac
done
