# kali_rtl8812au Driver Installer

This repository provides a script that facilitates the installation of the RTL8812AU driver for Kali Linux. The RTL8812AU is a USB 3.0 network adapter that supports 802.11ac, necessary for certain WiFi dongles.

## Features:

- Automated installation of the RTL8812AU driver for Kali Linux.
- Handles dependency resolution and ensures smooth installation.
- Directly fetches the latest version from the repository.

## Installation:

1. **Backup:** Always recommended to backup any essential data before installing drivers or software that modifies system configurations.

2. **Install the Driver:** Execute the following command in your terminal:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/DanDanilyuk/kali_rtl8812au/main/install.sh)"
   ```

## Troubleshooting:

If you face any issues during or after the installation:

1. Check the install logs for any specific error messages.
2. Ensure your Kali Linux is up-to-date.
3. Visit the GitHub repository issues section and search for similar problems or report a new one.

## Contribute:

Contributions to improve the script or expand support are welcome! If you'd like to make this script better or more versatile, please:

1. Fork the repository.
2. Make your changes.
3. Submit a pull request for review.

## License:

This script is released under the MIT License. For more details, please refer to the `LICENSE` file in the repository.

## Credits:

Special thanks to the original authors and maintainers of the RTL8812AU driver. Gratitude also goes to the community and everyone who contributed to refining this installation process for Kali Linux users.
