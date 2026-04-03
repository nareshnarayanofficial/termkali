#!/bin/bash
# TermKali - Installation logic

# ─── Logging to file ──────────────────────────────────────────────────────────
setup_logging() {
    mkdir -p "$CONFIG_DIR"
    exec > >(tee -a "$LOG_FILE") 2>&1
    log_info "Log file: $LOG_FILE"
}

# ─── Package installation ─────────────────────────────────────────────────────
install_packages() {
    log_section "Installing Dependencies"

    log_info "Updating package lists..."
    apt-get update -y &>/dev/null & spinner $! "Updating package lists"

    local pkgs=($REQUIRED_PKGS python python2 openssh)
    local total=${#pkgs[@]}
    local count=0

    for pkg in "${pkgs[@]}"; do
        count=$(( count + 1 ))
        log_info "Installing $pkg ($count/$total)..."
        pkg install "$pkg" -y &>/dev/null & spinner $! "Installing $pkg"
    done

    log_ok "All dependencies installed."
}

# ─── Kali rootfs download & setup ────────────────────────────────────────────
install_kali() {
    log_section "Installing Kali Linux"

    local tmp_script="$HOME/.termkali/kali_installer.sh"
    mkdir -p "$CONFIG_DIR"

    log_info "Downloading Kali installer..."
    if ! wget -q "$KALI_INSTALLER_URL" -O "$tmp_script"; then
        log_error "Failed to download Kali installer. Check your internet connection."
        exit 1
    fi
    chmod +x "$tmp_script"
    log_ok "Installer downloaded."

    log_info "Running Kali installer..."
    bash "$tmp_script"
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "Kali installer exited with code $exit_code. Check $LOG_FILE for details."
        exit $exit_code
    fi

    log_ok "Kali Linux rootfs installed successfully."
}

# ─── Save start command ───────────────────────────────────────────────────────
save_start_command() {
    local cmd_file="$CONFIG_DIR/start-command.txt"

    # Pull the start command from kali-fs if start-kali.sh exists
    if [[ -f "$HOME/start-kali.sh" ]]; then
        echo "./start-kali.sh" > "$cmd_file"
    fi

    # Also save XFCE4 GUI setup command
    cat > "$CONFIG_DIR/gui-setup.sh" <<'EOF'
#!/bin/bash
# Run this INSIDE Kali Linux to install XFCE4 desktop
wget https://raw.githubusercontent.com/EXALAB/AnLinux-Resources/master/Scripts/DesktopEnvironment/Apt/Xfce4/de-apt-xfce4.sh \
  && bash de-apt-xfce4.sh
EOF
    chmod +x "$CONFIG_DIR/gui-setup.sh"
}

# ─── Post-install summary ─────────────────────────────────────────────────────
post_install_summary() {
    log_section "Installation Complete"

    echo -e "  ${GREEN}Kali Linux has been installed successfully in Termux!${RESET}"
    echo ""
    echo -e "  ${CYAN}Start Kali Linux:${RESET}"
    echo -e "    ${YELLOW}./start-kali.sh${RESET}"
    echo ""
    echo -e "  ${CYAN}GUI Setup (inside Kali):${RESET}"
    echo -e "    ${YELLOW}bash ~/.termkali/gui-setup.sh${RESET}"
    echo ""
    echo -e "  ${CYAN}VNC Server (inside Kali, after GUI install):${RESET}"
    echo -e "    ${YELLOW}vncserver-start${RESET}"
    echo -e "    Connect VNC Viewer to: ${YELLOW}127.0.0.1:5901${RESET}"
    echo ""
    divider
    echo -e "  ${MAGENTA}Log saved at: ${LOG_FILE}${RESET}"
    echo ""
}
