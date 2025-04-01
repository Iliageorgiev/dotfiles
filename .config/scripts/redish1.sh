#!/bin/bash

# ----------------------------------------------------- 
# Select random wallpaper and create color scheme
# ----------------------------------------------------- 
wal -q -i ~/wallpaper/wallpaper

# ----------------------------------------------------- 
# Load current pywal color scheme
# ----------------------------------------------------- 
source "$HOME/.cache/wal/colors.sh"

# ----------------------------------------------------- 
# Copy color file to waybar folder
# ----------------------------------------------------- 
cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/
#cp ~/.cache/wal/bars.glsl ~/.config/glava/
cp ~/.cache/wal/graph.glsl ~/.config/glava/
cp ~/.cache/wal/colors-waybar.css ~/.config/wofi/
# ----------------------------------------------------- 
# get wallpaper iamge name
# ----------------------------------------------------- 
newwall=$(echo $wallpaper | sed "s|$HOME/wallpaper/||g")

# ----------------------------------------------------- 
# Set the new wallpaper
# ----------------------------------------------------- 
swww img /home/baiken80/wallpaper/wallpaper/0033.jpeg --transition-step 20 --transition-fps=60 --transition-type simple
~/dotfiles/waybar/reload.sh
killall glava
glava -d -m graph
# ----------------------------------------------------- 
# Send notification
# ----------------------------------------------------- 
notify-send "Theme and Wallpaper updated" "With image $newwall"
pywalfox update
echo "DONE!"
