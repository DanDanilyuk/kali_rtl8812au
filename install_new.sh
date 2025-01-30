#!/bin/bash
set -euo pipefail

# Configuration
REPO_URL="https://github.com/aircrack-ng/rtl8812au.git"
REPO_DIR="rtl8812au"
REQUIRED_PACKAGES=("dkms" "git" "build-essential" "libelf-dev" "linux-headers-$(uname -r)")

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

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
    echo -e "${YELLOW}Checking for system updates...${NC}"
    sudo apt update -qq
    if apt list --upgradable 2>/dev/null | grep -q upgradable; then
        return 0
    fi
    return 1
}

install_packages() {
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

echo -e "${GREEN}\nRTL8812AU Driver Installation Script${NC}"
echo -e "${YELLOW}Please ensure the Wi-Fi device is NOT connected before proceeding.\n${NC}"

if ! get_user_confirmation "Proceed with driver installation?"; then
    echo -e "${RED}Installation aborted by user${NC}"
    exit 0
fi

if check_updates_required; then
    if get_user_confirmation "System updates available. Install required updates?"; then
        echo -e "${YELLOW}Updating system packages...${NC}"
        sudo apt update -y
        sudo apt upgrade -y
        echo -e "${GREEN}System updated successfully${NC}"
        
        if get_user_confirmation "Reboot required for updates. Reboot now?"; then
            echo -e "${YELLOW}Rebooting system...${NC}"
            sudo reboot
        else
            echo -e "${RED}You must reboot before continuing installation. Exiting.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}System updates are required for installation. Exiting.${NC}"
        exit 1
    fi
fi

install_packages

echo -e "${YELLOW}Cloning driver repository...${NC}"
git clone "$REPO_URL" || { echo -e "${RED}Failed to clone repository${NC}"; exit 1; }

cd "$REPO_DIR" || { echo -e "${RED}Failed to enter repository directory${NC}"; exit 1; }

echo -e "${YELLOW}Building and installing drivers...${NC}"
sudo make dkms_install || { echo -e "${RED}Driver installation failed${NC}"; tput sgr0; exit 1; }

if get_user_confirmation "Installation complete. Reboot to apply changes?"; then
    echo -e "${YELLOW}Rebooting system...${NC}"
    sudo reboot
else
    echo -e "${YELLOW}Manual reboot required before using the device${NC}"
fi
