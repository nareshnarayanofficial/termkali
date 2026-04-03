#!/bin/bash
# TermKali - UI functions

source "$(dirname "$0")/lib/colors.sh"

# ─── Banner ───────────────────────────────────────────────────────────────────
print_banner() {
    clear
    echo -e "${CYAN}"
    echo "  ████████╗███████╗██████╗ ███╗   ███╗██╗  ██╗ █████╗ ██╗     ██╗"
    echo "     ██╔══╝██╔════╝██╔══██╗████╗ ████║██║ ██╔╝██╔══██╗██║     ██║"
    echo "     ██║   █████╗  ██████╔╝██╔████╔██║█████╔╝ ███████║██║     ██║"
    echo "     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██╔═██╗ ██╔══██║██║     ██║"
    echo "     ██║   ███████╗██║  ██║██║ ╚═╝ ██║██║  ██╗██║  ██║███████╗██║"
    echo "     ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝"
    echo -e "${RESET}"
    echo -e "${MAGENTA}        [ Kali Linux for Termux — No Root Required ]${RESET}"
    echo -e "${BLUE}        Version: ${TOOL_VERSION}  |  Author: ${TOOL_AUTHOR}${RESET}"
    echo -e "${YELLOW}        GitHub : github.com/${TOOL_GITHUB}${RESET}"
    echo ""
    divider
}

# ─── Divider ──────────────────────────────────────────────────────────────────
divider() {
    echo -e "${BLUE}  ══════════════════════════════════════════════════════════${RESET}"
}

# ─── Log helpers ──────────────────────────────────────────────────────────────
log_info()    { echo -e "  ${CYAN}[*]${RESET} $*"; }
log_ok()      { echo -e "  ${GREEN}[+]${RESET} $*"; }
log_warn()    { echo -e "  ${YELLOW}[!]${RESET} $*"; }
log_error()   { echo -e "  ${RED}[-]${RESET} $*" >&2; }
log_section() { echo ""; divider; echo -e "  ${MAGENTA}${BOLD}$*${RESET}"; divider; echo ""; }

# ─── Smooth progress bar ──────────────────────────────────────────────────────
# Usage: progress_bar <current> <total> [label]
progress_bar() {
    local current=$1
    local total=$2
    local label="${3:-Loading}"
    local bar_width=40
    local filled=$(( current * bar_width / total ))
    local empty=$(( bar_width - filled ))
    local pct=$(( current * 100 / total ))

    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty;  i++)); do bar+="░"; done

    printf "\r  ${CYAN}%-18s${RESET} [${GREEN}%s${RESET}] ${YELLOW}%3d%%${RESET}" "$label" "$bar" "$pct"
}

# ─── Animated spinner ─────────────────────────────────────────────────────────
# Usage: spinner <pid> [label]
spinner() {
    local pid=$1
    local label="${2:-Please wait}"
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${CYAN}%s${RESET}  ${YELLOW}%s${RESET}  " "${frames[$i]}" "$label"
        i=$(( (i+1) % ${#frames[@]} ))
        sleep 0.08
    done
    printf "\r  ${GREEN}[+]${RESET}  %-40s\n" "$label"
}

# ─── Section header with animation ───────────────────────────────────────────
animated_load() {
    local label="${1:-Initializing}"
    local steps=20
    for ((i=1; i<=steps; i++)); do
        progress_bar "$i" "$steps" "$label"
        sleep 0.05
    done
    echo ""
}

# ─── Confirm prompt ───────────────────────────────────────────────────────────
confirm() {
    local prompt="${1:-Continue?}"
    local response
    echo -ne "  ${YELLOW}[?]${RESET} ${prompt} [Y/n]: "
    read -r response
    [[ -z "$response" || "$response" =~ ^[Yy]$ ]]
}
