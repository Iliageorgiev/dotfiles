#!/bin/bash

# Configuration
INTERFACE="enp0s26u1u2"  # Replace with your network interface
SPEED_THRESHOLD_LOW=3000     # Below 3000 KB/s (blue)
SPEED_THRESHOLD_MEDIUM=8000  # Between 3000 and 8000 KB/s (yellow)

# Get current RX/TX bytes
RX=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

# Store previous values in a temporary file
TEMP_FILE="/tmp/waybar-network-speed"
if [[ -f "$TEMP_FILE" ]]; then
    read OLD_RX OLD_TX < "$TEMP_FILE"
else
    OLD_RX=$RX
    OLD_TX=$TX
fi

# Calculate speed in KB/s
SLEEP_INTERVAL=1
sleep $SLEEP_INTERVAL
NEW_RX=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
NEW_TX=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

DOWN_SPEED=$(( (NEW_RX - OLD_RX) / SLEEP_INTERVAL / 1000 ))  # Convert to KB/s
UP_SPEED=$(( (NEW_TX - OLD_TX) / SLEEP_INTERVAL / 1000 ))   # Convert to KB/s

# Save new values for the next run
echo "$NEW_RX $NEW_TX" > "$TEMP_FILE"

# Function to determine color based on speed
get_color() {
    local speed=$1
    if (( speed == 0 )); then
        echo "#FFFFFF"  # White for zero speed
    elif (( speed < SPEED_THRESHOLD_LOW )); then
        echo "#FFFFFF"  # White for low speed
    elif (( speed < SPEED_THRESHOLD_MEDIUM )); then
        echo "#FFFF00"  # Yellow for medium speed
    else
        echo "#FF0000"  # Red for high speed
    fi
}

# Determine colors for download and upload speeds
COLOR_DOWN=$(get_color $DOWN_SPEED)
COLOR_UP=$(get_color $UP_SPEED)

# Output formatted string with Pango markup
echo "<span color='$COLOR_DOWN'> ${DOWN_SPEED} k/s</span> <span color='$COLOR_UP'> ${UP_SPEED} k/s</span>"
