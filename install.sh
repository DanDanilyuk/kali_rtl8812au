#!/bin/bash

# Function to prompt the user and downcase the choice
get_user_choice() {
    local prompt_message="$1"
    read -p "$prompt_message" choice
    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]') # Convert to lowercase
    echo "${choice:0:1}"
}

# Ask the user if they want to install RTL8812AU Wi-Fi chip drivers
install_drivers_choice=$(get_user_choice "Do you want to continue installing RTL8812AU Wi-Fi chip drivers? (y/n): ")

if [[ "$install_drivers_choice" != "y" ]]; then
    echo "Skipping RTL8812AU Wi-Fi chip driver installation."
    exit 0
fi

# Check if there are updates and upgrades available
check_updates() {
    # Check for updates using dry-run upgrade which also implies an update check
    sudo apt upgrade --dry-run | grep -qP '^\d+ upgraded,' && return 1
    return 0
}

# Ask the user if they want to proceed with system updates and upgrades only if updates are available
if check_updates; then
    echo "No updates or upgrades available. Skipping updates and upgrades."
else
    user_choice=$(get_user_choice "Updates or upgrades are available. Do you want to proceed with system updates and upgrades? (y/n): ")
    if [[ "$user_choice" == "y" ]]; then
        echo "Updating and upgrading the system..."
        sudo apt update -y
        sudo apt upgrade -y
        echo "System updates and upgrades completed."
        
        # Ask the user if they want to reboot
        reboot_choice=$(get_user_choice "Do you want to reboot now? (y/n): (Required to continue installing) ")
        if [[ "$reboot_choice" == "y" ]]; then
            echo "Rebooting the system..."
            sudo reboot
        else
            echo "You must reboot the system dependecies to be properly loaded. Exiting Installation!"
            exit 0
        fi
    else
        echo "Skipping updates and upgrades."
    fi
fi

# Install necessary packages
echo "Installing necessary packages..."
sudo apt -y install dkms git build-essential libelf-dev linux-headers-$(uname -r)

# Clone the repository and make dkms_install
echo "Cloning the rtl8812au repository and installing..."
git clone https://github.com/aircrack-ng/rtl8812au.git
cd rtl8812au
sudo make dkms_install

# Ask the user for reboot option
user_choice_reboot=$(get_user_choice "Do you want to reboot now? (y/n): ")

if [[ "$user_choice_reboot" == "y" ]]; then
    sudo reboot
else
    echo "You chose not to reboot. Please reboot before plugging in device. Exiting script."
    exit 0
fi
