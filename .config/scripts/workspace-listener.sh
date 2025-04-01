#!/bin/bash

# Mako config file location
CONFIG_FILE="/home/baiken80/.config/mako/config"
TMP_CONFIG_FILE="/tmp/mako_config_backup_$(date +%s).bak"
# Workspace handler function
#Try to update the configuration
mako_config_tester() {
    if ! sed -i 's/anchor=center/anchor=top-left/' "$CONFIG_FILE"; then
        echo "Error updating configuration. Falling back to backup."
        mv "$TMP_CONFIG_FILE" "$CONFIG_FILE"
    fi    
}

handle_workspace_change() {
	local prev_workspace="$1"
	local curr_workspace="$2"

	#Check if the workspace has changed
	if [ "$prev_workspace" != "$curr_workspace" ] && [ -n "$curr_workspace" ]; then
	    echo "Workspace changed: $curr_workspace"

	   

	    if command -v glava &>/dev/null; then
	        echo "finnally"

	    else

	        echo "GLava is not installed or not in the PATH"
	    fi
	    # Use of temporary file for backup of mako config
	    
	    cp "$CONFIG_FILE" "$TMP_CONFIG_FILE"

	    
	    
        sed -i 's/anchor=top-left/anchor=top-center/' /home/baiken80/.config/mako/config
        
        makoctl reload 
        # Display with dunstify
	    notify-send "           Workspace $curr_workspace"  -t 1500  -i ~/.config/scripts/output_frame.jpeg 
        sleep 1.5
        sed -i 's/anchor=top-center/anchor=top-left/' /home/baiken80/.config/mako/config
        mako_config_tester
        
        makoctl reload


     fi
}

# Initialize the previous workspace variable
previous_workspace=""

#Main loop to check workspace changes

workspace_checker() {
    while true; do
        # Get the active workspace from hyprctl output
        current_workspace=$(hyprctl monitors | grep "active workspace:" | awk '{print $3}' | cut -d'(' -f1)
    
        # Call the function to handle the workspace change
        handle_workspace_change "$previous_workspace" "$current_workspace"
    
        # Update the previous workspace variable
        previous_workspace="$current_workspace"
    
        # Wait for 2 seconds before checking again
        sleep 0.1
    done
	
} 
workspace_checker


