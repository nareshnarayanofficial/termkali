#!/bin/bash
# TermKali - Pre-flight checks

check_termux() {
    if [[ -z "$PREFIX" || ! -d "$PREFIX/bin" ]]; then
        log_error "TermKali must run inside Termux."
        exit 1
    fi
    log_ok "Termux environment detected."
}

check_internet() {
    log_info "Checking internet connectivity..."
    if ! ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
        log_error "No internet connection. Please connect and retry."
        exit 1
    fi
    log_ok "Internet connection OK."
}

check_storage() {
    log_info "Checking available storage..."
    local available_kb
    available_kb=$(df "$HOME" | awk 'NR==2 {print $4}')
    local available_mb=$(( available_kb / 1024 ))
    local required_mb="${REQUIRED_STORAGE_MB:-1500}"

    if (( available_mb < required_mb )); then
        log_error "Insufficient storage. Need ${required_mb}MB, have ${available_mb}MB."
        exit 1
    fi
    log_ok "Storage OK (${available_mb}MB available)."
}

check_already_installed() {
    if [[ -d "$HOME/kali-fs" ]]; then
        log_warn "Kali Linux appears to already be installed at ~/kali-fs."
        if ! confirm "Reinstall/overwrite?"; then
            log_info "Aborting installation."
            exit 0
        fi
    fi
}

run_all_checks() {
    log_section "Pre-flight Checks"
    check_termux
    check_internet
    check_storage
    check_already_installed
    log_ok "All checks passed."
}
