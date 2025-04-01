#!/bin/bash

# Stop the currently running Waybar instance
pkill -x waybar

# Wait for the process to completely terminate
sleep 1

# Start Waybar again
waybar -c /home/baiken80/.config/waybar/config.jason

echo "Waybar has been reset."
