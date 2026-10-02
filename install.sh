#!/usr/bin/env bash
# ==============================================================================
# Omnicast Installer — Alt+Space Productivity Umbrella for Omarchy
# Website: https://omnicast.best
# Repository: https://github.com/KOUSTAV2409/omnicast
# ==============================================================================

set -euo pipefail

# ANSI Colors
BOLD="\033[1m"
GREEN="\033[38;2;158;206;106m"
BLUE="\033[38;2;122;162;247m"
CYAN="\033[38;2;125;207;255m"
YELLOW="\033[38;2;224;175;104m"
RED="\033[38;2;247;118;142m"
RESET="\033[0m"

log_info() { echo -e " ${BLUE}..${RESET} $1"; }
log_done() { echo -e " ${GREEN}✓${RESET} $1"; }
log_warn() { echo -e " ${YELLOW}▲${RESET} $1"; }
log_fail() { echo -e " ${RED}✗${RESET} $1"; }

print_banner() {
  echo -e "${CYAN}"
  cat << "BANNER"
   ____  __  __ _   _ ___ ____    _    ____ _____ 
  / __ \|  \/  | \ | |_ _/ ___|  / \  / ___|_   _|
 | |  | | |\/| |  \| || | |     / _ \ \___ \ | |  
 | |__| | |  | | |\  || | |___ / ___ \ ___) || |  
  \____/|_|  |_|_| \_|___\____/_/   \_\____/ |_|  
BANNER
  echo -e "${RESET}${BOLD} Alt+Space Productivity Umbrella for Omarchy${RESET}\n"
}

# --- 1. Preflight Checks ---
check_prerequisites() {
  log_info "Checking system prerequisites..."

  if [[ "$(uname -s)" != "Linux" ]]; then
    log_fail "Omnicast currently requires Linux (Omarchy / Hyprland). macOS/Windows are not supported."
    exit 1
  fi

  if ! command -v git >/dev/null 2>&1; then
    log_fail "git is required but not installed. Please install git and re-run."
    exit 1
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    log_fail "python3 is required but not installed. Please install python3 and re-run."
    exit 1
  fi

  if ! command -v qs >/dev/null 2>&1 && ! command -v quickshell >/dev/null 2>&1; then
    log_warn "Quickshell ('qs') not detected on PATH."
    echo -e "   Omnicast runs on Quickshell. If you are on Arch Linux / Omarchy, install it via:"
    echo -e "   ${BOLD}yay -S quickshell-git${RESET} or ${BOLD}paru -S quickshell-git${RESET}\n"
  else
    log_done "Found Quickshell runtime ($(command -v qs 2>/dev/null || command -v quickshell))"
  fi
}

# --- 2. Installation Path ---
install_repository() {
  INSTALL_DIR="${OMNICAST_DIR:-$HOME/.local/share/omnicast}"
  BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"

  mkdir -p "$BIN_DIR"

  if [[ -d "$INSTALL_DIR/.git" ]]; then
    log_info "Existing installation found at $INSTALL_DIR. Updating..."
    git -C "$INSTALL_DIR" fetch --depth=1 origin main
    git -C "$INSTALL_DIR" reset --hard origin/main
    log_done "Updated Omnicast to latest version"
  else
    log_info "Installing Omnicast to $INSTALL_DIR..."
    rm -rf "$INSTALL_DIR"
    git clone --depth=1 https://github.com/KOUSTAV2409/omnicast.git "$INSTALL_DIR"
    log_done "Downloaded Omnicast repository"
  fi

  # Symlink launcher to PATH
  chmod +x "$INSTALL_DIR/bin/omnicast"
  ln -sf "$INSTALL_DIR/bin/omnicast" "$BIN_DIR/omnicast"
  log_done "Symlinked ${BOLD}$BIN_DIR/omnicast${RESET}"

  # Verify PATH
  if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    log_warn "$BIN_DIR is not currently in your PATH."
    echo -e "   Add ${BOLD}export PATH=\"\$HOME/.local/bin:\$PATH\"${RESET} to your ~/.bashrc or ~/.zshrc."
  fi
}

# --- 3. Desktop Application Entry ---
install_desktop_entry() {
  APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  mkdir -p "$APP_DIR"

  cat << DESKTOP > "$APP_DIR/omnicast.desktop"
[Desktop Entry]
Name=Omnicast
Comment=Alt+Space Productivity Umbrella for Omarchy
Exec=omnicast
Icon=preferences-system-search
Terminal=false
Type=Application
Categories=Utility;System;
StartupNotify=false
DESKTOP

  log_done "Registered desktop application launcher"
}

# --- 4. User Config & Commands Directory ---
setup_config() {
  CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/omnicast"
  mkdir -p "$CONFIG_DIR/commands" "$CONFIG_DIR/snippets"

  # Copy sample commands if none exist
  if [[ -z "$(ls -A "$CONFIG_DIR/commands" 2>/dev/null)" ]]; then
    if [[ -d "$INSTALL_DIR/src/commands" ]]; then
      cp -r "$INSTALL_DIR/src/commands/"* "$CONFIG_DIR/commands/" 2>/dev/null || true
      chmod +x "$CONFIG_DIR/commands/"* 2>/dev/null || true
      log_done "Populated sample script commands in $CONFIG_DIR/commands"
    fi
  fi
}

# --- 5. Automatic Hyprland Keybinding ---
configure_keybinding() {
  HYPR_BINDINGS="$HOME/.config/hypr/bindings.lua"
  HYPR_CONF="$HOME/.config/hypr/hyprland.conf"

  if [[ -f "$HYPR_BINDINGS" ]]; then
    if grep -q "omnicast" "$HYPR_BINDINGS"; then
      log_done "Keybinding already configured in $HYPR_BINDINGS"
    else
      log_info "Configuring Alt+Space in Omarchy bindings.lua..."
      cat << 'LUA' >> "$HYPR_BINDINGS"

-- Omnicast Launcher (Alt+Space)
o.bind("ALT + SPACE", "Omnicast", "omnicast")
LUA
      log_done "Bound ${BOLD}ALT + SPACE${RESET} to Omnicast in $HYPR_BINDINGS"
      if command -v hyprctl >/dev/null 2>&1; then
        hyprctl reload >/dev/null 2>&1 || true
      fi
    fi
  elif [[ -f "$HYPR_CONF" ]]; then
    if grep -q "omnicast" "$HYPR_CONF"; then
      log_done "Keybinding already configured in $HYPR_CONF"
    else
      log_info "Configuring Alt+Space in hyprland.conf..."
      echo -e "\n# Omnicast Launcher\nbind = ALT, SPACE, exec, omnicast" >> "$HYPR_CONF"
      log_done "Bound ${BOLD}ALT + SPACE${RESET} to Omnicast in $HYPR_CONF"
      if command -v hyprctl >/dev/null 2>&1; then
        hyprctl reload >/dev/null 2>&1 || true
      fi
    fi
  else
    log_warn "Hyprland config not found at standard path. Bind manually:"
    echo -e "   ${BOLD}bind = ALT, SPACE, exec, omnicast${RESET}"
  fi
}

# --- Main Run ---
main() {
  print_banner
  check_prerequisites
  install_repository
  install_desktop_entry
  setup_config
  configure_keybinding

  echo ""
  echo -e "${GREEN}${BOLD}✓ Omnicast successfully installed!${RESET}"
  echo -e "  • Summon with:  ${BOLD}ALT + SPACE${RESET}"
  echo -e "  • CLI command:  ${BOLD}omnicast${RESET}"
  echo -e "  • Config dir:   ${BOLD}~/.config/omnicast/${RESET}"
  echo -e "  • Custom scripts: ${BOLD}~/.config/omnicast/commands/${RESET}\n"

  # Warm up daemon if in active Wayland session
  if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    log_info "Starting Omnicast daemon..."
    omnicast >/dev/null 2>&1 &
  fi
}

main "$@"
