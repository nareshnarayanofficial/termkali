#!/bin/bash
# TermKali v2.0 — Kali Linux installer for Termux (no root required)
# Author : Naresh Narayan
# GitHub : github.com/nareshnarayanofficial
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail
IFS=$'\n\t'

# ─── Resolve script directory ─────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Load config ──────────────────────────────────────────────────────────────
source "$SCRIPT_DIR/config/settings.conf"

# ─── Load libraries ───────────────────────────────────────────────────────────
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/checks.sh"
source "$SCRIPT_DIR/lib/install.sh"

# ─── Trap for clean exit on error ─────────────────────────────────────────────
trap 'echo -e "\n  ${RED}[✗] Unexpected error on line $LINENO. Check $LOG_FILE${RESET}"; exit 1' ERR

# ─── Entry point ──────────────────────────────────────────────────────────────
main() {
    print_banner

    animated_load "Initializing TermKali"

    setup_logging
    run_all_checks
    install_packages
    install_kali
    save_start_command
    post_install_summary
}

main "$@"
