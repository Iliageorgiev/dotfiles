#!/bin/bash

# Set the path to your wallpaper folder
WALLPAPER_DIR="$HOME/wallpaper/wallpaper"


# Get a random image file from the wallpaper folder
RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Set the wallpaper using swww
swww img "$RANDOM_WALLPAPER"



