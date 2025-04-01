#!/bin/bash
# Initial start pause for hyprland to load
sleep 7
# Check the remaining space in the boot partition
remaining_space=$(df /boot | awk 'NR==2 {print $4}')
# Calculate the percentage of used space
used_space=$(df /boot | awk 'NR==2 {print $5}' | sed 's/%//')
# Calculate the remaining space percentage
remaining_space_percentage=$((10 - used_space))
# Output the result to the terminal instead of sending a notification
echo "Boot Partition Space: $remaining_space_percentage% remaining"
