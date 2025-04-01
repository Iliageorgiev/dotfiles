#!/bin/bash
# Define the directory where screenshots will be saved
SCREENSHOT_DIR="$HOME/Documents/screenshots"
# Create the directory if it doesn't exis
mkdir -p "$SCREENSHOT_DIR"
# Get the current date and time, formatted for use in a filename
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
# Use grim to take a full screenshot and save it to the specified directory
grim -t png -l 0  -o DP-3 "$SCREENSHOT_DIR/screenshot_$DATE.png"
echo "Screenshot saved to $SCREENSHOT_DIR/screenshot_$DATE.png"
