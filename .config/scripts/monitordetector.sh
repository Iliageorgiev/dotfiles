#!/bin/bash

# Function to check if AGS is running
ags_running() {
    pgrep -x "agsv1" > /dev/null
}
# Function to check monitor status
check_monitor() {
    local monitor_id=$1
    if hyprctl monitors | grep -q "$monitor_id"; then
        if hyprctl monitors | grep -A 20 "$monitor_id" | grep -i "model: LG TV"; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}
# Function to start AGS
start_ags() {
    if ! ags_running; then
        echo "Starting AGS..."
        agsv1 >/dev/null 2>&1 &
    fi
}
# Main script
while true; do
    # Check monitor status
    if check_monitor $monitor_id; then
        echo "Monitor is active. Checking AGS status..."
        
        # Check if AGS is already running
        if ! ags_running; then
            echo "AGS is not running. Starting AGS..."
            start_ags
        else
            echo "AGS is already running. No action needed."
        fi
    else
        echo "Monitor is not active. Killing AGS and waiting..."
        
        # Kill all instances of AGS
        killall agsv1
        
        # Wait for the monitor to be turned on
        while ! check_monitor $monitor_id; do
            sleep 2
            echo "Waiting for monitor to turn on..."
        
        
        done
    fi
    
    # Continue in the background
    sleep 1.5
done
