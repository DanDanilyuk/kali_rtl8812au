#!/bin/bash
set -euo pipefail

# Configuration
REPO_URL="https://github.com/aircrack-ng/rtl8812au.git"
REPO_DIR="rtl8812au"
REQUIRED_PACKAGES=("dkms" "git" "build-essential" "libelf-dev" "linux-headers-$(uname -r)")
STATUS_FILE="/var/lib/driver_install/status.flag"  # Persistent status file location

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- Status Management ---
update_status() {
    local message="$1"
    sudo mkdir -p "$(dirname "$STATUS_FILE")"
    echo "$(date +"%Y-%m-%d %T") - $message" | sudo tee "$STATUS_FILE" > /dev/null
}

# --- Helper Functions ---
get_user_confirmation() {
    local prompt_msg="$1"
    while true; do
        read -p "${prompt_msg} (y/n): " -r
        case "${REPLY,,}" in
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) echo -e "${RED}Invalid input. Please answer y/n${NC}" ;;
        esac
    done
}

check_updates_required() {
    update_status "Checking for system updates"
    echo -e "${YELLOW}Checking for system updates...${NC}"
    sudo apt update -qq
    if apt list --upgradable 2>/dev/null | grep -q upgradable; then
        return 0
    fi
    return 1
}

install_packages() {
    update_status "Installing required packages"
    echo -e "${YELLOW}Installing required packages...${NC}"
    sudo apt install -y "${REQUIRED_PACKAGES[@]}"
}

cleanup() {
    if [[ -d "$REPO_DIR" ]]; then
        echo -e "${YELLOW}Cleaning up repository...${NC}"
        sudo rm -rf "$REPO_DIR"
    fi
}

# --- Main Execution ---
trap cleanup EXIT
update_status "Installation started"

echo -e "${GREEN}\nRTL8812AU Driver Installation Script${NC}"
echo -e "${YELLOW}Please ensure the Wi-Fi device is NOT connected before proceeding.\n${NC}"

if ! get_user_confirmation "Proceed with driver installation?"; then
    update_status "Installation aborted by user"
    echo -e "${RED}Installation aborted by user${NC}"
    exit 0
fi

if check_updates_required; then
    if get_user_confirmation "System updates available. Install required updates?"; then
        update_status "Installing system updates"
        echo -e "${YELLOW}Updating system packages...${NC}"
        sudo apt update -y
        sudo apt upgrade -y
        update_status "System updated successfully"
        echo -e "${GREEN}System updated successfully${NC}"
        
        if get_user_confirmation "Reboot required for updates. Reboot now?"; then
            update_status "Rebooting for system updates"
            echo -e "${YELLOW}Rebooting system...${NC}"
            sudo reboot
        else
            update_status "Reboot required but user declined"
            echo -e "${RED}You must reboot before continuing installation. Exiting.${NC}"
            exit 1
        fi
    else
        update_status "System updates required but user declined"
        echo -e "${RED}System updates are required for installation. Exiting.${NC}"
        exit 1
    fi
fi

install_packages

update_status "Cloning driver repository"
echo -e "${YELLOW}Cloning driver repository...${NC}"
git clone "$REPO_URL" || { update_status "Repository clone failed"; echo -e "${RED}Failed to clone repository${NC}"; exit 1; }

cd "$REPO_DIR" || { update_status "Failed to enter repository directory"; echo -e "${RED}Failed to enter repository directory${NC}"; exit 1; }

update_status "Building and installing drivers"
echo -e "${YELLOW}Building and installing drivers...${NC}"
sudo make dkms_install || { update_status "Driver installation failed"; echo -e "${RED}Driver installation failed${NC}"; tput sgr0; exit 1; }

if get_user_confirmation "Installation complete. Reboot to apply changes?"; then
    update_status "Rebooting after successful installation"
    echo -e "${YELLOW}Rebooting system...${NC}"
    sudo reboot
else
    update_status "Installation complete - manual reboot pending"
    echo -e "${YELLOW}Manual reboot required before using the device${NC}"
fi
