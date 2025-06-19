#!/bin/bash

# === COLORS ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
NC='\033[0m'
MAGENTA='\033[0;35m'

# === BANNER ===
banner() {
    clear
    echo -e "${GREEN}   ____ _           _       ____                   "
    echo -e "${GREEN}  / ___| |__   __ _(_)_ __ / ___|  ___ __ _ _ __   "
    echo -e "${MAGENTA} | |   | '_ \ / _  | |  _  \\___ \ / __/ _  |  _ \  "
    echo -e "${MAGENTA} | |___| | | | (_| | | | | |___) | (_| (_| | | | | "
    echo -e "${GREEN}  \____|_| |_|\__,_|_|_| |_|____/ \___\__,_|_| |_| "
    echo -e "${RED}           v1.1 ${NC}${CYAN}ChainScan${NC}${RED} ${NC}"
    echo -e "${CYAN}"
}

# === SPINNER ===
spinner() {
    local pid=$1
    local msg=$2
    local spin='|/-\'
    local i=0
    echo -ne "${YELLOW}[~] $msg...${NC} "
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\b${spin:$i:1}"
        sleep 0.1
    done
    echo -e "\b ${GREEN}[✓] Done${NC}"
}

# === HELP MENU ===
show_help() {
    echo -e "${YELLOW}Usage: $0 [options] <domain.com>${NC}"
    echo ""
    echo "Options:"
    echo "  -h, --help        Show help"
    echo "  -v                Verbose output for all modules"
    echo "  -vs               Verbose output for Subfinder"
    echo "  -va               Verbose output for Amass"
    echo "  -vp               Verbose output for Httpx"
    echo "  -vn               Verbose output for Nmap"
    echo ""
    echo "Examples:"
    echo "  $0 domain.com               Run full recon"
    echo "  $0 -v domain.com            Full recon with verbose output"
    echo "  $0 -va -vn domain.com       Verbose only for Amass & Nmap"
    exit 0
}

# === DEFAULT VERBOSE FLAGS ===
verbose_all=false
verbose_subfinder=false
verbose_amass=false
verbose_httpx=false
verbose_nmap=false

# === ARGUMENT PARSING ===
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) show_help ;;
        -v) verbose_all=true; shift ;;
        -vs) verbose_subfinder=true; shift ;;
        -va) verbose_amass=true; shift ;;
        -vp) verbose_httpx=true; shift ;;
        -vn) verbose_nmap=true; shift ;;
        -*)
            echo -e "${RED}[!] Unknown option: $1${NC}"
            show_help ;;
        *)
            POSITIONAL+=("$1")
            shift ;;
    esac
done
set -- "${POSITIONAL[@]}"
DOMAIN=$1

# === CHECK DOMAIN ===
if [ -z "$DOMAIN" ]; then
    echo -e "${RED}[!] Error: Please provide a domain name.${NC}"
    show_help
fi

# === ENABLE ALL VERBOSE IF -v ===
if $verbose_all; then
    verbose_subfinder=true
    verbose_amass=true
    verbose_httpx=true
    verbose_nmap=true
fi

# === CHECK TOOL AVAILABILITY ===
check_tools() {
    local tools=(subfinder amass httpx-toolkit nmap)
    local missing=()

    echo -e "${YELLOW}[+] Checking required tools...${NC}"
    for tool in "${tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            echo -e "${GREEN}[+] $tool check passed${NC}"
        else
            echo -e "${RED}[+] $tool check failed${NC}"
            missing+=("$tool")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}[!] Missing tools:${NC}"
        for t in "${missing[@]}"; do
            echo -e "${RED}    - $t${NC} ${YELLOW}(please install it)${NC}"
        done
        exit 1
    fi
}

# === RECON LOGIC ===
run_recon() {
    mkdir -p "$OUT_DIR"

    echo -e "${YELLOW}[+] Running Subfinder & Amass in parallel...${NC}"

    subfinder -d "$DOMAIN" -silent > "$OUT_DIR/subfinder.txt" &
    pid_subfinder=$!
    spinner $pid_subfinder "Subfinder running"

    amass enum -passive -d "$DOMAIN" > "$OUT_DIR/amass.txt" &
    pid_amass=$!
    spinner $pid_amass "Amass running"

    if $verbose_subfinder; then
        echo -e "${GREEN}[✓] Subfinder Output:${NC}"
        cat "$OUT_DIR/subfinder.txt"
    fi

    if $verbose_amass; then
        echo -e "${GREEN}[✓] Amass Output:${NC}"
        if [[ -s "$OUT_DIR/amass.txt" ]]; then
            cat "$OUT_DIR/amass.txt"
        else
            echo -e "${RED}[!] No subdomains discovered by Amass.${NC}"
        fi
    fi

    echo -e "${YELLOW}[+] Merging subdomains...${NC}"
    grep -Ev ' --> ' "$OUT_DIR/amass.txt" > "$OUT_DIR/amass_filtered.txt"
    cat "$OUT_DIR/subfinder.txt" "$OUT_DIR/amass_filtered.txt" | sort -u > "$OUT_DIR/all_subdomains.txt"

    echo -e "${YELLOW}[+] Running httpx-toolkit...${NC}"
    cat "$OUT_DIR/all_subdomains.txt" | httpx-toolkit -silent > "$OUT_DIR/alive.txt" &
    spinner $! "httpx-toolkit running"

    if $verbose_httpx; then
        if [[ -s "$OUT_DIR/alive.txt" ]]; then
            echo -e "${GREEN}[✓] Httpx Output:${NC}"
            cat "$OUT_DIR/alive.txt"
        else
            echo -e "${RED}[!] No live hosts found.${NC}"
        fi
    fi

    echo -e "${YELLOW}[+] Running Nmap on live domains...${NC}"
    if [[ ! -s "$OUT_DIR/alive.txt" ]]; then
        echo -e "${RED}[!] No alive domains to scan. Skipping Nmap.${NC}"
    else
        while read -r url; do
            domain=$(echo "$url" | sed 's~http[s]*://~~')
            echo -e "${BLUE}[+] Scanning $domain with Nmap...${NC}"
            if $verbose_nmap; then
                nmap -sV -T4 "$domain" -oN "$OUT_DIR/nmap_$domain.txt" &
                spinner $! "Nmap scanning $domain"
            else
                nmap -sV -T4 "$domain" -oN "$OUT_DIR/nmap_$domain.txt" &>/dev/null &
                spinner $! "Nmap scanning $domain"
            fi
            echo -e "${GREEN}[✓] Nmap result saved: nmap_$domain.txt${NC}"
        done < "$OUT_DIR/alive.txt"
    fi

    ABS_PATH="$(realpath "$OUT_DIR")"
    echo -e "${GREEN}[✓] Recon complete. Results saved in '$OUT_DIR'.${NC}"
    echo -e "${BLUE}[→] Full results saved in: $ABS_PATH${NC}"
}

# === EXECUTION ===
banner
check_tools
OUT_DIR="$DOMAIN"
run_recon