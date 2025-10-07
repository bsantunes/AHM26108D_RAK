#!/bin/bash
set -e

# Create a working directory
WORKDIR="MM"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# Download .deb packages
echo "Downloading Morse Micro packages..."
curl -L https://community.morsemicro.com/uploads/short-url/AiKaaJ4I7N5cIPCu5IshCClDCzz.deb -o mm-overlays_1.12.4-2.deb
curl -L https://community.morsemicro.com/uploads/short-url/csfRIEM0q8eP17rr2lKHLL0vqnJ.deb -o mm-driver_1.12.4-rpt-rpi-2712.deb
curl -L https://community.morsemicro.com/uploads/short-url/waCcpbowR0JPcynxGKJ6IBDSQe2.deb -o mm-mac80211_6.6.31-rpt-rpi-2712-1.12.4.deb
curl -L https://community.morsemicro.com/uploads/short-url/wQm6W2eJSlzOtiAnCGOpCNfoyrB.deb -o mm-wpa-supp_1.12.4-1.deb
curl -L https://community.morsemicro.com/uploads/short-url/wsZ0etVaTbtfXC9Lz3TGASrhfVb.deb -o mm-morsecli_1.12.4-1.deb
curl -L https://community.morsemicro.com/uploads/short-url/icdk0vBSEfHNKtL2ewUq3jPPbIv.deb -o mm-hostapd_1.12.4-1.deb
curl -L https://community.morsemicro.com/uploads/short-url/2pndoejRngT2z1oVaPUI3stwyja.deb -o mm-firmware_1.12.4-1.deb

# Install all .deb packages
echo "Installing packages..."
sudo apt install libnl-3-dev libnl-genl-3-dev libnl-route-3-dev -y 
sudo dpkg -i mm-hostapd_1.12.4-1.deb
sudo dpkg -i mm-wpa-supp_1.12.4-1.deb
sudo dpkg -i mm-morsecli_1.12.4-1.deb
sudo dpkg -i mm-firmware_1.12.4-1.deb
#sudo dpkg -i mm-mac80211_6.6.31-rpt-rpi-2712-1.12.4.deb
#sudo dpkg -i mm-driver_1.12.4-rpt-rpi-2712.deb
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