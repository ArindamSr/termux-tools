#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# TERMUX TOOLS // CYBERDECK v3
# Single-file menu.sh
# ============================================================
# Optional:
#   Termux:API app + package: termux-api
#   Python
#   yt-dlp
#   gpg
#   AI uses BYOK: configure Gemini API key + model from the AI menu.
#   Configuration is stored at ~/.termux-tools/config (chmod 600).
#
# AI Command Pilot is intentionally confirmation-based.
# It does NOT blindly execute arbitrary AI-generated commands.
# ============================================================

set -u
export PATH="$PREFIX/bin:$PATH"

# ---------- UI ----------
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[38;5;51m'
BLUE='\033[38;5;75m'
GREEN='\033[38;5;82m'
YELLOW='\033[38;5;220m'
RED='\033[38;5;203m'
MAGENTA='\033[38;5;213m'
WHITE='\033[38;5;255m'
GRAY='\033[38;5;245m'

APP_NAME="TERMUX TOOLS"
APP_VERSION="CYBERDECK 3.0"
LOG_DIR="$HOME/.termux-tools"
EVENT_LOG="$LOG_DIR/events.log"
CONFIG="$LOG_DIR/config"
mkdir -p "$LOG_DIR"
touch "$EVENT_LOG" "$CONFIG"

event() {
    printf '%s | %s\n' "$(date '+%F %T')" "$*" >> "$EVENT_LOG"
}

line() { printf '%b\n' "${GRAY}────────────────────────────────────────────────────────────${RESET}"; }
pause() { printf "\n%b" "${DIM}Press Enter to continue...${RESET}"; read -r; }
ok() { printf "%b\n" "${GREEN}✓${RESET} $*"; event "$*"; }
warn() { printf "%b\n" "${YELLOW}⚠${RESET} $*"; }
err() { printf "%b\n" "${RED}✗${RESET} $*"; }
title() {
    clear
    printf "%b\n" "${CYAN}${BOLD}"
    printf "╔══════════════════════════════════════════════════════════╗\n"
    printf "║              ◈  TERMUX TOOLS  ◈                         ║\n"
    printf "║                 %s                 ║\n" "$APP_VERSION"
    printf "╚══════════════════════════════════════════════════════════╝${RESET}\n"
}
section() {
    printf "\n%b\n" "${MAGENTA}${BOLD}▸ $1${RESET}"
    line
}
need_cmd() {
    command -v "$1" >/dev/null 2>&1
}
ensure_pkg() {
    local cmd="$1" pkg="${2:-$1}"
    if need_cmd "$cmd"; then return 0; fi
    warn "$cmd is not installed."
    printf "Install package '%s' now? [y/N]: " "$pkg"
    read -r ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        pkg install -y "$pkg" || { err "Installation failed."; return 1; }
    else
        return 1
    fi
}

# ---------- Storage ----------
init_storage() {
    if [[ ! -d "$HOME/storage" ]]; then
        if need_cmd termux-setup-storage; then
            termux-setup-storage
            sleep 2
        else
            err "termux-setup-storage is unavailable. Install Termux:API."
            return 1
        fi
    fi
    ok "Storage access initialized."
}

# ---------- Original tools ----------
image_organizer() {
    title; section "01 // BULK IMAGE ORGANIZER"
    init_storage || { pause; return; }
    local src="$HOME/storage/shared/DCIM"
    local dest="$HOME/storage/shared/Pictures/Sorted"
    mkdir -p "$dest"
    if [[ ! -d "$src" ]]; then err "DCIM folder not found."; pause; return; fi

    local count=0
    while IFS= read -r -d '' f; do
        ext="${f##*.}"; ext="${ext,,}"
        case "$ext" in
            jpg|jpeg|png|webp|gif|heic|heif)
                month="$(date -r "$f" '+%Y-%m' 2>/dev/null || echo unknown)"
                mkdir -p "$dest/$month"
                cp -n "$f" "$dest/$month/" && ((count++))
            ;;
        esac
    done < <(find "$src" -type f -print0 2>/dev/null)
    ok "Copied $count image(s) into $dest"
    pause
}

file_drop() {
    title; section "02 // LOCAL FILE DROP"
    ensure_pkg python python || { pause; return; }
    init_storage || { pause; return; }
    local dir="$HOME/storage/shared"
    local ip
    ip="$(ip route 2>/dev/null | awk '/src/ {print $9; exit}')"
    [[ -z "$ip" ]] && ip="YOUR_PHONE_IP"
    printf "%b\n" "${CYAN}Serving:${RESET} $dir"
    printf "%b\n" "${CYAN}URL:${RESET}    http://$ip:8080"
    printf "%b\n" "${YELLOW}LAN only. Use only on networks/devices you control or are authorized to use.${RESET}"
    event "Started local file drop on port 8080"
    cd "$dir" || return
    python -m http.server 8080 --bind 0.0.0.0
}

media_downloader() {
    title; section "03 // MEDIA DOWNLOADER"
    ensure_pkg yt-dlp || { pause; return; }
    init_storage || { pause; return; }
    printf "URL: "
    read -r url
    [[ -z "$url" ]] && { pause; return; }
    local out="$HOME/storage/shared/Download/%(title)s.%(ext)s"
    mkdir -p "$HOME/storage/shared/Download"
    yt-dlp -o "$out" "$url"
    event "yt-dlp download requested"
    pause
}

app_launcher() {
    title; section "04 // ANDROID APP LAUNCHER"
    printf "%b\n" "1) WhatsApp\n2) YouTube\n3) Settings\n4) Chrome\n5) Open URL\n0) Back"
    printf "Select: "; read -r c
    case "$c" in
        1) am start -n com.whatsapp/.Main >/dev/null 2>&1 || am start -a android.intent.action.VIEW -d "https://wa.me/" ;;
        2) am start -a android.intent.action.VIEW -d "https://youtube.com" ;;
        3) am start -a android.settings.SETTINGS ;;
        4) am start -a android.intent.action.VIEW -d "https://google.com" ;;
        5) printf "URL: "; read -r u; am start -a android.intent.action.VIEW -d "$u" ;;
    esac
    event "Android launcher option: $c"
    pause
}

nano_editor() {
    title; section "05 // NANO"
    ensure_pkg nano || { pause; return; }
    printf "File path (Enter for ~/termux-note.txt): "
    read -r f
    [[ -z "$f" ]] && f="$HOME/termux-note.txt"
    nano "$f"
    event "Edited file with nano: $f"
}

battery_watchdog() {
    title; section "06 // BATTERY WATCHDOG"
    if ! need_cmd termux-battery-status; then
        warn "Install Termux:API app and package 'termux-api'."
        pause; return
    fi
    while true; do
        data="$(termux-battery-status 2>/dev/null || true)"
        pct="$(printf '%s' "$data" | sed -n 's/.*"percentage":[[:space:]]*\([0-9]*\).*/\1/p')"
        status="$(printf '%s' "$data" | sed -n 's/.*"status":[[:space:]]*"\([^"]*\)".*/\1/p')"
        clear
        printf "%b\n" "${CYAN}${BOLD}🔋 BATTERY WATCHDOG${RESET}"
        printf "\n${WHITE}Battery:${RESET} ${GREEN}%s%%${RESET}\n" "${pct:-?}"
        printf "${WHITE}Status:${RESET}  %s\n" "${status:-unknown}"
        printf "\n${DIM}Refreshing every 3 seconds. Ctrl+C to stop.${RESET}\n"
        sleep 3
    done
}

cyber_rain() {
    title; section "07 // REAL EVENT CODE RAIN"
    printf "%b\n" "${DIM}This visualizes events recorded by Termux Tools itself; it is not fake intrusion output and does not claim to monitor all Android activity.${RESET}"
    event "Opened real event code rain"
    while true; do
        printf "\033[2J\033[H"
        printf "%b\n" "${GREEN}${BOLD}╔══════════════ REAL EVENT STREAM ══════════════╗${RESET}"
        tail -n 28 "$EVENT_LOG" 2>/dev/null | while IFS= read -r l; do
            printf "%b\n" "${GREEN}$(printf '%s' "$l" | tr ' ' '·')${RESET}"
        done
        printf "\n%b\n" "${DIM}Ctrl+C to return.${RESET}"
        sleep 1
    done
}

# ---------- Cyber features ----------
morse_flashlight() {
    title; section "08 // FLASHLIGHT MORSE MODE"
    if ! need_cmd termux-torch; then
        err "termux-torch unavailable. Install Termux:API."
        pause; return
    fi
    printf "Text to transmit: "
    read -r text
    [[ -z "$text" ]] && { pause; return; }
    text="${text^^}"
    declare -A M=(
      [A]=".-" [B]="-..." [C]="-.-." [D]="-.." [E]="." [F]="..-."
      [G]="--." [H]="...." [I]=".." [J]=".---" [K]="-.-" [L]=".-.."
      [M]="--" [N]="-." [O]="---" [P]=".--." [Q]="--.-" [R]=".-."
      [S]="..." [T]="-" [U]="..-" [V]="...-" [W]=".--" [X]="-..-"
      [Y]="-.--" [Z]="--.." [0]="-----" [1]=".----" [2]="..---"
      [3]="...--" [4]="....-" [5]="....." [6]="-...." [7]="--..."
      [8]="---.." [9]="----."
    )
    local ch code symbol
    for ((i=0;i<${#text};i++)); do
        ch="${text:i:1}"
        [[ "$ch" == " " ]] && { sleep .6; continue; }
        code="${M[$ch]:-}"
        for ((j=0;j<${#code};j++)); do
            symbol="${code:j:1}"
            termux-torch on; [[ "$symbol" == "." ]] && sleep .15 || sleep .45
            termux-torch off; sleep .15
        done
        sleep .3
    done
    ok "Morse transmission complete."
    event "Morse transmission completed"
    pause
}

secret_channel() {
    title; section "09 // SECRET CHANNEL — LOCAL LAN"
    ensure_pkg python python || { pause; return; }
    printf "%b\n" "${YELLOW}Use only between devices/networks you own or have permission to use.${RESET}"
    printf "1) Start channel server\n2) Connect to another phone\n0) Back\nSelect: "
    read -r c
    case "$c" in
      1)
        printf "Port [5050]: "; read -r port; [[ -z "$port" ]] && port=5050
        python - "$port" <<'PY'
import socket,sys,threading
port=int(sys.argv[1]); s=socket.socket(); s.setsockopt(socket.SOL_SOCKET,socket.SO_REUSEADDR,1)
s.bind(("0.0.0.0",port)); s.listen(1)
print("Listening on port",port)
conn,addr=s.accept(); print("Connected:",addr)
def rx():
    while True:
        try:
            d=conn.recv(4096)
            if not d: break
            print("\n[peer]",d.decode(errors="replace"),"\n> ",end="",flush=True)
        except: break
threading.Thread(target=rx,daemon=True).start()
while True:
    try:
        m=input("> ")
        if m.lower()=="/quit": break
        conn.sendall(m.encode())
    except: break
conn.close()
PY
        ;;
      2)
        printf "Peer IP: "; read -r ip
        printf "Port [5050]: "; read -r port; [[ -z "$port" ]] && port=5050
        python - "$ip" "$port" <<'PY'
import socket,sys,threading
ip=sys.argv[1]; port=int(sys.argv[2]); s=socket.socket(); s.connect((ip,port))
def rx():
    while True:
        try:
            d=s.recv(4096)
            if not d: break
            print("\n[peer]",d.decode(errors="replace"),"\n> ",end="",flush=True)
        except: break
threading.Thread(target=rx,daemon=True).start()
while True:
    try:
        m=input("> ")
        if m.lower()=="/quit": break
        s.sendall(m.encode())
    except: break
s.close()
PY
        ;;
    esac
    event "Secret channel menu used"
    pause
}

voice_console() {
    title; section "10 // VOICE CYBER CONSOLE"
    if ! need_cmd termux-speech-to-text; then
        err "termux-speech-to-text unavailable. Install Termux:API."
        pause; return
    fi
    printf "%b\n" "${DIM}Safe built-in commands only. Say: flashlight, battery, storage, rain, exit.${RESET}"
    while true; do
        printf "\n%b" "${CYAN}🎙 Listening...${RESET}\n"
        spoken="$(termux-speech-to-text 2>/dev/null | tr '[:upper:]' '[:lower:]' || true)"
        printf "Heard: %s\n" "$spoken"
        case "$spoken" in
          *flashlight*) need_cmd termux-torch && termux-torch on; sleep 2; termux-torch off ;;
          *battery*) termux-battery-status 2>/dev/null || warn "Termux:API unavailable." ;;
          *storage*) df -h "$HOME" ;;
          *rain*) cyber_rain ;;
          *exit*|*quit*) break ;;
          *) warn "Command not in safe voice-command list." ;;
        esac
    done
    event "Voice console used"
}

encrypted_vault() {
    title; section "11 // ENCRYPTED PERSONAL VAULT"
    ensure_pkg gpg gnupg || { pause; return; }
    local vault="$HOME/.termux-tools/vault"
    mkdir -p "$vault"
    chmod 700 "$vault"
    printf "1) Encrypt file\n2) Decrypt file\n3) List vault\n0) Back\nSelect: "
    read -r c
    case "$c" in
      1)
        printf "File to encrypt: "; read -r f
        [[ -f "$f" ]] || { err "File not found."; pause; return; }
        gpg --symmetric --cipher-algo AES256 --output "$vault/$(basename "$f").gpg" "$f" &&
          ok "Encrypted copy saved in vault."
        ;;
      2)
        printf "Encrypted file: "; read -r f
        [[ -f "$f" ]] || { err "File not found."; pause; return; }
        printf "Output file: "; read -r out
        gpg --output "$out" --decrypt "$f" && ok "Decrypted successfully."
        ;;
      3) ls -lah "$vault" ;;
    esac
    event "Vault operation: $c"
    pause
}

# ---------- AI ----------
ai_config() {
    title; section "AI // BYOK CONFIGURATION"

    printf "%b\n" "${CYAN}${BOLD}🔐 BRING YOUR OWN KEY (BYOK)${RESET}"
    printf "%b\n" "${DIM}Your Gemini API key is stored locally on this phone only.${RESET}"
    printf "%b\n\n" "${YELLOW}Never commit ~/.termux-tools/config to GitHub.${RESET}"

    if [[ -n "${GEMINI_API_KEY:-}" ]]; then
        printf "%b\n" "${GREEN}✓ Gemini API key: configured${RESET}"
        printf "Replace existing key? [y/N]: "
        read -r replace
        if [[ ! "$replace" =~ ^[Yy]$ ]]; then
            :
        else
            printf "Gemini API key (hidden): "
            read -rs key; echo
            [[ -n "$key" ]] && GEMINI_API_KEY="$key"
        fi
    else
        printf "Gemini API key (hidden): "
        read -rs key; echo
        [[ -n "$key" ]] || { warn "No API key entered."; pause; return 1; }
        GEMINI_API_KEY="$key"
    fi

    export GEMINI_API_KEY

    printf "\n%b\n" "${CYAN}${BOLD}🤖 SELECT GEMINI MODEL${RESET}"
    printf "%b\n" \
      "  ${CYAN}1${RESET} gemini-2.5-flash  ${DIM}(fast / recommended)${RESET}" \
      "  ${CYAN}2${RESET} gemini-2.5-pro    ${DIM}(stronger reasoning)${RESET}" \
      "  ${CYAN}3${RESET} Custom model name"
    printf "Model [1]: "
    read -r mc

    case "$mc" in
      2) GEMINI_MODEL="gemini-2.5-pro" ;;
      3)
        printf "Model name: "
        read -r custom
        [[ -n "$custom" ]] && GEMINI_MODEL="$custom" || GEMINI_MODEL="gemini-2.5-flash"
        ;;
      *) GEMINI_MODEL="gemini-2.5-flash" ;;
    esac

    # Save only the API configuration locally, never to the repository.
    umask 077
    {
        printf 'export GEMINI_API_KEY=%q\n' "$GEMINI_API_KEY"
        printf 'export GEMINI_MODEL=%q\n' "$GEMINI_MODEL"
    } > "$CONFIG"
    chmod 600 "$CONFIG"

    ok "BYOK configured."
    printf "Model: %b%s%b\n" "${GREEN}" "$GEMINI_MODEL" "${RESET}"
    pause
}

ensure_ai_ready() {
    # Every AI feature goes through this gate.
    if [[ -z "${GEMINI_API_KEY:-}" ]]; then
        title
        section "AI // BYOK REQUIRED"
        warn "AI is not configured yet."
        printf "\nGemini API key and model are required before using AI features.\n"
        printf "Open BYOK setup now? [Y/n]: "
        read -r a
        if [[ -z "$a" || "$a" =~ ^[Yy]$ ]]; then
            ai_config
        fi
    fi

    [[ -n "${GEMINI_API_KEY:-}" ]] || {
        err "AI cancelled: Gemini API key is not configured."
        return 1
    }

    if [[ -z "${GEMINI_MODEL:-}" ]]; then
        ai_config
    fi

    [[ -n "${GEMINI_MODEL:-}" ]] || {
        err "AI cancelled: no Gemini model selected."
        return 1
    }
    return 0
}

ai_call() {
    # Reads prompt from stdin and returns model text.
    local prompt
    prompt="$(cat)"
    ensure_ai_ready || return 1
    ensure_pkg curl curl >/dev/null || return 1
    python - "$GEMINI_API_KEY" "$GEMINI_MODEL" "$prompt" <<'PY'
import json,sys,urllib.request,urllib.error
key=sys.argv[1]; model=sys.argv[2]; prompt=sys.argv[3]
url="https://generativelanguage.googleapis.com/v1beta/models/"+model+":generateContent?key="+key
body=json.dumps({"contents":[{"parts":[{"text":prompt}]}]}).encode()
req=urllib.request.Request(url,data=body,headers={"Content-Type":"application/json"})
try:
    with urllib.request.urlopen(req,timeout=60) as r:
        data=json.load(r)
    print(data["candidates"][0]["content"]["parts"][0]["text"])
except urllib.error.HTTPError as e:
    detail=e.read().decode(errors="replace")
    print("AI request failed (HTTP %s): %s" % (e.code, detail))
except Exception as e:
    print("AI request failed:",e)
PY
}

ai_command_pilot() {
    title; section "AI // COMMAND PILOT"
    printf "%b\n" "${WHITE}Tell the AI what you want your OWN Termux phone to do.${RESET}"
    printf "%b\n" "${DIM}Example: Create a folder called demo and a Python hello-world file.${RESET}"
    printf "\nRequest: "
    read -r request
    [[ -z "$request" ]] && { pause; return; }

    local prompt
    prompt="You are a careful Termux assistant. Convert the user's request into a short sequence of POSIX/Bash commands for their own Android Termux environment. Output ONLY a numbered list of commands in fenced bash code plus one short explanation. Never include commands for credential theft, persistence, evasion, malware, unauthorized access, destructive wiping, or attacking other systems. Prefer safe commands and absolute/local paths. User request: $request"
    result="$(printf '%s' "$prompt" | ai_call)" || { pause; return; }

    printf "\n%b\n%s\n" "${CYAN}${BOLD}GENERATED PLAN${RESET}" "$result"
    line
    warn "Commands generated by AI must be reviewed before execution."
    printf "Paste the EXACT command(s) you want to run, one line at a time. Empty line = finish.\n"
    local commands=()
    while true; do
        printf "%b" "${BLUE}$ ${RESET}"
        read -r cmd
        [[ -z "$cmd" ]] && break
        commands+=("$cmd")
    done
    ((${#commands[@]})) || { pause; return; }

    printf "\n%b\n" "${YELLOW}COMMAND REVIEW${RESET}"
    printf '%s\n' "${commands[@]}"
    printf "Run these commands? [y/N]: "
    read -r ans
    [[ "$ans" =~ ^[Yy]$ ]] || { warn "Cancelled."; pause; return; }

    local cmd
    for cmd in "${commands[@]}"; do
        # Basic guardrail against obviously destructive/credential-targeting commands.
        if printf '%s' "$cmd" | grep -Eiq '(^|[;&|])(rm[[:space:]]+-rf[[:space:]]+/|mkfs|dd[[:space:]]+if=|:(){:|passwd[[:space:]]|curl[^|]*\|[[:space:]]*(sh|bash)|wget[^|]*\|[[:space:]]*(sh|bash))'; then
            err "Blocked dangerous command pattern: $cmd"
            continue
        fi
        printf "\n%b\n" "${GREEN}▶ Running:${RESET} $cmd"
        event "AI Pilot ran: $cmd"
        bash -c "$cmd"
        rc=$?
        if ((rc != 0)); then
            err "Command exited with status $rc"
            printf "Continue? [y/N]: "; read -r cont
            [[ "$cont" =~ ^[Yy]$ ]] || break
        fi
    done
    ok "AI Pilot session complete."
    pause
}

ai_notification_brain() {
    title; section "AI // NOTIFICATION BRAIN"
    if ! need_cmd termux-notification-list; then
        err "termux-notification-list unavailable. Install Termux:API."
        pause; return
    fi
    local notes
    notes="$(termux-notification-list 2>/dev/null || true)"
    [[ -n "$notes" ]] || { warn "No notification data returned."; pause; return; }
    printf "%s\n" "$notes" > "$LOG_DIR/notifications.json"
    printf '%s\n' "Summarize and prioritize these Android notifications. Do not invent facts. Mark urgent/actionable items separately. Keep private content concise:" |
      { cat; printf '\n%s' "$notes"; } | ai_call
    event "AI Notification Brain used"
    pause
}

ai_screen_analyzer() {
    title; section "AI // SCREEN ANALYZER"
    init_storage || { pause; return; }
    ensure_pkg termux-screenshot || true
    if ! need_cmd termux-screenshot; then
        err "termux-screenshot unavailable. Install Termux:API."
        pause; return
    fi
    local shot="$LOG_DIR/screen-$(date +%s).png"
    termux-screenshot -f "$shot" >/dev/null 2>&1 || { err "Screenshot failed."; pause; return; }
    printf "Screenshot saved at: %s\n" "$shot"
    warn "This single-file build does not upload image bytes automatically. Open the screenshot with a vision-capable AI workflow if desired."
    pause
}

ai_scam_detector() {
    title; section "AI // SCAM DETECTOR"
    printf "Paste message/text to analyze. Empty line ends input:\n"
    local text_in="" line_in
    while IFS= read -r line_in; do
        [[ -z "$line_in" ]] && break
        text_in+="$line_in"$'\n'
    done
    [[ -n "$text_in" ]] || { pause; return; }
    printf '%s' "Analyze this message for phishing/scam indicators. Give indicators, uncertainty, and safe verification steps. Do not claim certainty unless evidence supports it:\n$text_in" | ai_call
    event "AI scam detector used"
    pause
}

ai_battery() {
    title; section "AI // BATTERY DETECTIVE"
    if need_cmd termux-battery-status; then
        data="$(termux-battery-status 2>/dev/null || true)"
    else
        data="$(dumpsys battery 2>/dev/null | head -40)"
    fi
    printf "Analyze this battery data and explain what it means. Avoid inventing app-level causes:\n%s" "$data" | ai_call
    pause
}

ai_file_search() {
    title; section "AI // FILE SEARCH"
    init_storage || { pause; return; }
    printf "Describe the file you are looking for: "
    read -r q
    [[ -n "$q" ]] || { pause; return; }
    printf "Search result candidates:\n"
    find "$HOME/storage/shared" -type f 2>/dev/null | grep -Ei "$(printf '%s' "$q" | tr ' ' '|')" | head -50
    printf "\n%b\n" "${DIM}This basic version uses local filename matching; AI semantic indexing can be added later without changing the menu architecture.${RESET}"
    pause
}

ai_cleanup() {
    title; section "AI // CLEANUP ADVISOR"
    init_storage || { pause; return; }
    printf "%b\n" "${DIM}Advisor only: nothing is deleted automatically.${RESET}"
    du -h -d 1 "$HOME/storage/shared" 2>/dev/null | sort -h | tail -20
    printf "\nFind large files (>100 MB)? [y/N]: "
    read -r a
    if [[ "$a" =~ ^[Yy]$ ]]; then
        find "$HOME/storage/shared" -type f -size +100M -printf '%s %p\n' 2>/dev/null | sort -n | tail -30
    fi
    pause
}

ai_explain_phone() {
    title; section "AI // EXPLAIN MY PHONE"
    printf "Paste an Android/Termux error:\n"
    read -r e
    [[ -n "$e" ]] || { pause; return; }
    printf '%s' "Explain this Android/Termux error in simple terms, identify likely cause, and give safe troubleshooting steps. Error: $e" | ai_call
    pause
}

ai_privacy() {
    title; section "AI // PRIVACY SCANNER"
    printf "%b\n" "${DIM}This checks information exposed to this Termux session; it does not claim to inspect every Android permission.${RESET}"
    printf "\nTermux identity:\n"; id
    printf "\nStorage mounts:\n"; df -h
    printf "\nEnvironment variables (names only):\n"; env | cut -d= -f1 | sort
    printf "\nNotification API available: "; need_cmd termux-notification-list && echo yes || echo no
    printf "Camera/screenshot API available: "; need_cmd termux-screenshot && echo yes || echo no
    printf "Speech API available: "; need_cmd termux-speech-to-text && echo yes || echo no
    pause
}

ai_audio() {
    title; section "AI // AUDIO INTELLIGENCE"
    ensure_pkg python python || { pause; return; }
    printf "%b\n" "${DIM}This module expects you to provide an audio transcription workflow; Termux alone may not include a speech-to-text model.${RESET}"
    printf "Audio file path: "
    read -r f
    [[ -f "$f" ]] || { err "File not found."; pause; return; }
    printf "File: %s\n" "$f"
    warn "For privacy, audio is not uploaded by this script."
    pause
}

ai_clipboard() {
    title; section "AI // CLIPBOARD INTELLIGENCE"
    if need_cmd termux-clipboard-get; then
        clip="$(termux-clipboard-get 2>/dev/null || true)"
        printf "%b\n%s\n" "${CYAN}Current clipboard:${RESET}" "$clip"
    else
        err "termux-clipboard-get unavailable. Install Termux:API."
    fi
    pause
}

ai_phone_oracle() {
    title; section "AI // PHONE ORACLE"
    printf "%b\n" "${DIM}Collecting only locally accessible diagnostics; private content is not automatically uploaded except notification text when you explicitly use Notification Brain.${RESET}"
    local report="$LOG_DIR/oracle.txt"
    {
      echo "TIME: $(date)"
      echo
      echo "SYSTEM:"; uname -a
      echo
      echo "UPTIME:"; uptime 2>/dev/null || true
      echo
      echo "STORAGE:"; df -h "$HOME" 2>/dev/null
      echo
      echo "MEMORY:"; free -h 2>/dev/null || true
      echo
      echo "BATTERY:"
      termux-battery-status 2>/dev/null || dumpsys battery 2>/dev/null | head -25
    } > "$report"
    cat "$report"
    printf "\n%b\n" "${YELLOW}Send this report to AI for interpretation? [y/N]:${RESET} "
    read -r a
    if [[ "$a" =~ ^[Yy]$ ]]; then
        printf '%s' "Give a concise phone health/diagnostic briefing from this report. Separate facts from suggestions:\n$(cat "$report")" | ai_call
    fi
    event "AI Phone Oracle used"
    pause
}

ai_auto_reply() {
    title; section "AI // NOTIFICATION AUTO-REPLY"
    warn "This build generates a reply suggestion only. It does NOT send messages automatically."
    printf "Paste the incoming message:\n"
    read -r msg
    [[ -n "$msg" ]] || { pause; return; }
    printf '%s' "Generate 3 short, natural reply options to this message. Do not impersonate the user or make commitments. Message: $msg" | ai_call
    pause
}

ai_priority() {
    title; section "AI // NOTIFICATION PRIORITY"
    if ! need_cmd termux-notification-list; then
        err "termux-notification-list unavailable."
        pause; return
    fi
    notes="$(termux-notification-list 2>/dev/null || true)"
    printf '%s' "Classify these notifications as HIGH, MEDIUM, or LOW priority and explain briefly. Preserve uncertainty:\n$notes" | ai_call
    pause
}

ai_digest() {
    title; section "AI // NOTIFICATION DIGEST"
    ai_notification_brain
}

ai_remember() {
    title; section "AI // REMEMBER THIS"
    printf "Text to save: "
    read -r txt
    [[ -n "$txt" ]] || { pause; return; }
    printf '%s | %s\n' "$(date '+%F %T')" "$txt" >> "$LOG_DIR/memory.txt"
    chmod 600 "$LOG_DIR/memory.txt"
    ok "Saved locally."
    pause
}

ai_memory() {
    title; section "AI // PHONE MEMORY"
    local f="$LOG_DIR/memory.txt"
    [[ -f "$f" ]] || { warn "No saved memories yet."; pause; return; }
    cat "$f"
    printf "\nSearch memory: "
    read -r q
    [[ -n "$q" ]] && grep -in -- "$q" "$f" || true
    pause
}

ai_duplicate() {
    title; section "AI // DUPLICATE HUNTER"
    init_storage || { pause; return; }
    printf "%b\n" "${DIM}Exact duplicates only in this lightweight build. Nothing is deleted automatically.${RESET}"
    find "$HOME/storage/shared" -type f -print0 2>/dev/null |
      xargs -0 sha256sum 2>/dev/null |
      sort -k1,1 |
      awk '{
        if ($1==prev) { print "DUPLICATE:", $2; print "          ", prevfile }
        else { prev=$1; prevfile=$2 }
      }'
    pause
}

# ---------- AI menu ----------
ai_menu() {
    # First entry into AI always checks BYOK configuration.
    if ! ensure_ai_ready; then
        pause
        return
    fi
    while true; do
        title
        section "AI // PHONE INTELLIGENCE"
        printf "%b
" "${GREEN}● BYOK: Gemini${RESET}  ${DIM}Model: ${GEMINI_MODEL}${RESET}"
        printf "%b\n" \
"  ${CYAN}01${RESET} 🧠 Notification Brain" \
"  ${CYAN}02${RESET} 🤖 Notification Auto-Reply (suggestions)" \
"  ${CYAN}03${RESET} 🔕 Notification Priority" \
"  ${CYAN}04${RESET} 📬 Notification Digest" \
"  ${CYAN}05${RESET} 📸 Phone Briefing / diagnostics" \
"  ${CYAN}06${RESET} 🧠 Remember This" \
"  ${CYAN}07${RESET} 📋 Clipboard Intelligence" \
"  ${CYAN}08${RESET} 🗂️ AI File Search" \
"  ${CYAN}09${RESET} 🔍 Duplicate Hunter" \
"  ${CYAN}10${RESET} 🧠 Phone Memory" \
"  ${CYAN}11${RESET} 🕵️ Scam Detector" \
"  ${CYAN}12${RESET} 👀 Screen Analyzer" \
"  ${CYAN}13${RESET} 🔋 Battery Detective" \
"  ${CYAN}14${RESET} 🧹 Cleanup Advisor" \
"  ${CYAN}15${RESET} 🎧 Audio Intelligence" \
"  ${CYAN}16${RESET} 🛡️ Privacy Scanner" \
"  ${CYAN}17${RESET} 🤯 Explain My Phone" \
"  ${CYAN}18${RESET} 🧠⚡ Phone Oracle" \
"  ${CYAN}19${RESET} 🔐 BYOK / API + Model" \
"  ${CYAN}20${RESET} 🤖⚡ AI Command Pilot" \
"  ${CYAN}00${RESET} ← Back"
        printf "\nSelect: "; read -r c
        case "$c" in
          1) ai_notification_brain ;;
          2) ai_auto_reply ;;
          3) ai_priority ;;
          4) ai_digest ;;
          5) ai_phone_oracle ;;
          6) ai_remember ;;
          7) ai_clipboard ;;
          8) ai_file_search ;;
          9) ai_duplicate ;;
          10) ai_memory ;;
          11) ai_scam_detector ;;
          12) ai_screen_analyzer ;;
          13) ai_battery ;;
          14) ai_cleanup ;;
          15) ai_audio ;;
          16) ai_privacy ;;
          17) ai_explain_phone ;;
          18) ai_phone_oracle ;;
          19) ai_config ;;
          20) ai_command_pilot ;;
          0|00) return ;;
          *) warn "Invalid option."; sleep 1 ;;
        esac
    done
}

# ---------- Main ----------
if [[ -f "$CONFIG" ]]; then
    # shellcheck disable=SC1090
    source "$CONFIG" 2>/dev/null || true
fi
# Default model shown during first BYOK setup.
GEMINI_MODEL="${GEMINI_MODEL:-}"

trap 'printf "%b\n" "${RESET}"; exit 0' INT TERM

while true; do
    title
    printf "%b\n" "${DIM}LOCAL PHONE CONTROL • CYBER UI • AI OPTIONAL${RESET}"
    printf "\n"
    printf "%b\n" \
      "${GREEN}┌─ CORE TOOLS ─────────────────────────────────────────────┐${RESET}" \
      "  ${CYAN}01${RESET} 🔦 Bulk Image Organizer" \
      "  ${CYAN}02${RESET} 📡 Local File Drop" \
      "  ${CYAN}03${RESET} ▶️ Media Downloader" \
      "  ${CYAN}04${RESET} 📱 Android App Launcher" \
      "  ${CYAN}05${RESET} ✍️ Nano Editor" \
      "  ${CYAN}06${RESET} 🔋 Battery Watchdog" \
      "${GREEN}└──────────────────────────────────────────────────────────┘${RESET}" \
      "${MAGENTA}┌─ CYBER DECK ─────────────────────────────────────────────┐${RESET}" \
      "  ${CYAN}07${RESET} 🟢 Real Event Code Rain" \
      "  ${CYAN}08${RESET} 🔦 Flashlight Morse Mode" \
      "  ${CYAN}09${RESET} 📱↔️📱 Secret Channel" \
      "  ${CYAN}10${RESET} 🎙️ Voice Cyber Console" \
      "  ${CYAN}11${RESET} 🔐 Encrypted Personal Vault" \
      "${MAGENTA}└──────────────────────────────────────────────────────────┘${RESET}" \
      "${BLUE}┌─ AI PHONE ────────────────────────────────────────────────┐${RESET}" \
      "  ${CYAN}12${RESET} 🤖 Open AI Phone Intelligence" \
      "${BLUE}└──────────────────────────────────────────────────────────┘${RESET}" \
      "  ${RED}00${RESET} ⏻ Exit"
    printf "\n%b" "${WHITE}${BOLD}COMMAND > ${RESET}"
    read -r choice
    case "$choice" in
      1) image_organizer ;;
      2) file_drop ;;
      3) media_downloader ;;
      4) app_launcher ;;
      5) nano_editor ;;
      6) battery_watchdog ;;
      7) cyber_rain ;;
      8) morse_flashlight ;;
      9) secret_channel ;;
      10) voice_console ;;
      11) encrypted_vault ;;
      12) ai_menu ;;
      0|00)
        clear
        printf "%b\n" "${CYAN}${BOLD}◈ TERMUX TOOLS OFFLINE ◈${RESET}"
        event "Exited Termux Tools"
        exit 0
        ;;
      *) warn "Unknown command."; sleep 1 ;;
    esac
done
