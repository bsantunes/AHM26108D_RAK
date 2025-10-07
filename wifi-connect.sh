#!/bin/bash

# Exit if interface or config file is not provided
if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: $0 <interface> <config_file>"
    echo "Example: ./wifi-connect wlan1 wpa_supplicant_us.conf"
    exit 1
fi

INTERFACE="$1"
CONFIG="$2"

# Cleanup function to kill wpa_supplicant and dhclient
cleanup() {
    echo "Caught Ctrl+C! Killing wpa_supplicant and dhclient ..."
    sudo pkill -f "wpa_supplicant_s1g -D nl80211 -i $INTERFACE -c $CONFIG"
    sudo dhclient -r $INTERFACE
    sudo pkill -f "dhclient -i $INTERFACE"
    exit 1
}

# Trap SIGINT (Ctrl+C)
trap cleanup SIGINT

# Extract country code from config file (e.g., country=US)
COUNTRY=$(grep -E '^country=' "$CONFIG" | cut -d= -f2 | tr -d '"')

# Set regulatory domain if country was found
if [[ -n "$COUNTRY" ]]; then
    echo "Setting regulatory domain to $COUNTRY"
    sudo iw reg set "$COUNTRY"
else
    echo "No country code found in $CONFIG. Skipping iw reg set."
fi

# Extract ctrl_interface path from config(e.g., /var/run/wpa_supplicant/wlan1)
CTRL_PATH=$(grep -E '^ctrl_interface=' "$CONFIG" | cut -d= -f2 | tr -d '"')
CTRL_PATH=$CTRL_PATH/$INTERFACE

# Remove stale control interface directory/socket if it exists
if [[ -n "$CTRL_PATH" && -e "$CTRL_PATH" ]]; then
    echo "Removing existing ctrl_interface path: $CTRL_PATH"
    sudo rm -rf "$CTRL_PATH"
fi

# Start wpa_supplicant in the background
echo "Running wpa_supplicant"
sudo wpa_supplicant_s1g -D nl80211 -i "$INTERFACE" -c "$CONFIG" -B

# Give it some time to associate
sleep 5

# Release current lease
echo "Release current lease"
sudo dhclient -r $INTERFACE

# Start DHCP client
echo "Running dhclient on $INTERFACE interface"
sudo dhclient "$INTERFACE"

# Wait indefinitely or until interrupted
wait

