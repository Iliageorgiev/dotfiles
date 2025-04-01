#!/bin/bash

# Function to focus FreeTube window and send 'I' key
send_pip_command() {
    # Focus the FreeTube window
    
    
    # Send the 'I' key using ydotool
    hyprctl dispatch sendshortcut 'None, I, class:^(FreeTube)$'
    sleep 0.2
}

# Check if FreeTube is running
if pgrep -x "freetube" > /dev/null
then
    # FreeTube is running, send the PiP shortcut (I key)
    send_pip_command
    sleep 2
    hyprctl dispatch pin "title:^(Picture in picture)$"
    echo "PiP command sent to FreeTube"
else
    echo "FreeTube is not running"
    # Optionally, you can use notify-send if you want a desktop notification
    # notify-send "FreeTube is not running"
fi
