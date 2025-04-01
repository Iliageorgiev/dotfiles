#!/bin/bash

# Replace with your controller's MAC address
CONTROLLER_MAC="E9:CB:88:31:7A:3E"

# Check current connection status
if bluetoothctl info $CONTROLLER_MAC | grep -q "Connected: yes"; then
    echo "Controller is connected. Disconnecting..."
    bluetoothctl disconnect $CONTROLLER_MAC
else
    echo "Controller is disconnected. Connecting..."
    bluetoothctl connect $CONTROLLER_MAC
fi

