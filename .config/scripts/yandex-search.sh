#!/bin/bash
date_str=$(date +%d-%m-%Y_%H:%M:%S)
# Capture the screenshot and save it to a file
FILE_PATH="/home/baiken80/Pictures/screenshot$date_str.png"
grim -g "$(slurp)" -l 0  - 2>/dev/null > "$FILE_PATH"

# Open the saved image file in a new tab with floorp
floorp --new-tab "$FILE_PATH"
