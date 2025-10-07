#!/bin/bash
set -e

# Create a working directory
WORKDIR="MM"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# Download .deb packages
echo "Downloading Morse Micro packages..."
curl -L https://github.com/bsantunes/MM6108_RPi5_CM5/raw/refs/heads/main/mm-hostapd_1.12.4-1.deb -o mm-hostapd_1.12.4-1.deb
curl -L https://github.com/bsantunes/MM6108_RPi5_CM5/raw/refs/heads/main/mm-wpa-supp_1.12.4-1.deb -o mm-wpa-supp_1.12.4-1.deb
curl -L https://github.com/bsantunes/MM6108_RPi5_CM5/raw/refs/heads/main/mm-morsecli_1.12.4-1.deb -o mm-morsecli_1.12.4-1.deb
curl -L https://github.com/bsantunes/MM6108_RPi5_CM5/raw/refs/heads/main/mm-firmware_1.12.4-1.deb -o mm-firmware_1.12.4-1.deb
curl -L https://github.com/bsantunes/MM6108_RPi5_CM5/raw/refs/heads/main/mm-overlays_1.12.4-2.deb -o mm-overlays_1.12.4-2.deb

# Install all .deb packages
echo "Installing dependencies"
sudo apt install libnl-3-dev libnl-genl-3-dev libnl-route-3-dev -y 

echo "Installing packages..."
sudo dpkg -i mm-hostapd_1.12.4-1.deb
sudo dpkg -i mm-wpa-supp_1.12.4-1.deb
sudo dpkg -i mm-morsecli_1.12.4-1.deb
sudo dpkg -i mm-firmware_1.12.4-1.deb
sudo dpkg -i mm-overlays_1.12.4-2.deb

# Fix dependencies if needed
sudo apt-get install -f -y

# Copy firmware binary
FIRMWARE_DIR="/lib/firmware/morse"
SRC_BIN="$FIRMWARE_DIR/bcf_mf08551.bin"
DST_BIN="$FIRMWARE_DIR/bcf_default.bin"

if [ -f "$SRC_BIN" ]; then
    echo "Copying firmware binary..."
    sudo cp "$SRC_BIN" "$DST_BIN"
else
    echo "Firmware source file not found: $SRC_BIN"
    exit 1
fi

echo "Installation complete."
echo "Reboot the device"
