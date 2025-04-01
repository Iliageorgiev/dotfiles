#!/bin/bash

# Enable debugging (optional)
# set -x

# Replace 'YourPhoneName' with the actual name of your device as known to KDE Connect
DEVICE_NAME="Moto G62 5G"
OBJECT_PATH="/modules/kdeconnect/devices/c89e839889dedc0e/battery"

# Get the battery level
BATTERY_RESULT=$(gdbus call --session --dest org.kde.kdeconnect --object-path "$OBJECT_PATH" --method org.freedesktop.DBus.Properties.Get org.kde.kdeconnect.device.battery charge)

# Extract the numeric value from the result
# Assuming the result is in the format: "(type 'int', value)"
# This regex matches the pattern and captures the numeric value
BATTERY_LEVEL=$(echo "$BATTERY_RESULT" | tr -dc '0-9' | grep -E '[0-9]')

# Echo the battery level
echo "$BATTERY_LEVEL"
