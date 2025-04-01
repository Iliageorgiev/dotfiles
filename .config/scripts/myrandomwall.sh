#!/bin/bash
swww kill
swww init
# Set the path to your wallpaper folder
WALLPAPER_DIR="$HOME/wallpaper/wallpaper"
interval=30000
while true; do
    # Get a random image file from the wallpaper folder
    RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

    # Set the wallpaper using swww
    swww img "$RANDOM_WALLPAPER" --resize fit
    #Wait for the interval
    sleep $interval
done

