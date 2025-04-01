#!/bin/bash

date_str=$(date +%d-%m-%Y_%H:%M:%S)
# Capture the screenshot and save it to a file
FILE_PATH="/home/baiken80/Pictures/screenshot$date_str.png"
grim -g "$(slurp)" -l 0  - 2>/dev/null > "$FILE_PATH"



sauce_finder -d "$FILE_PATH" -o

echo "Search results opened in Floorp."
