#!/bin/bash

# Replace 'WINDOW_ID' with the actual window ID of the application you want to set as wallpaper

WINDOW_ID="GLava"

# Move the window to the top-left corner of the screen
xdotool search --class "GLava" windowmove 0 0

# Resize the window to cover the entire screen
xdotool search --class "GLava" windowsize $(xdpyinfo | grep resolution | awk '{print $2
}') $(xdpyinfo | grep resolution | awk '{print $4}')

# Optional: Remove window decorations (if supported)
# This step depends on the application and might not be universally applicable
