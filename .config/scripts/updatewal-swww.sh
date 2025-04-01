#!/bin/bash
# Check if swww is not active and start it with swww-daemon
if ! pgrep -x "swww-daemon" > /dev/null
then
    swww-daemon &
fi
# ----------------------------------------------------- 
# Select random wallpaper and create color scheme
# ----------------------------------------------------- 
wal -q  -i ~/wallpaper/wallpaper
killall hyprshade
# ----------------------------------------------------- 
# Load current pywal color scheme
# ----------------------------------------------------- 
source "$HOME/.cache/wal/colors.sh"
#source "$HOME/.config/scripts/reswal.sh"

# ----------------------------------------------------- 
# Copy color file to waybar folder

# ----------------------------------------------------- 
#cp ~/.cache/wal/dunstrc ~/.config/dunst/
cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/
#cp ~/.cache/wal/bars.glsl ~/.config/glava/
cp ~/.cache/wal/graph.glsl ~/.config/glava/
cp ~/.cache/wal/colors-waybar.css ~/.config/wofi/
cp ~/.cache/wal/colors-waybar.css ~/.config/wlogout/
ln -sf ~/.cache/wal/config ~/.config/mako/config
ln -sf ~/.cache/wal/starship.toml ~/.config/starship.toml
#ln -sf ~/.cache/wal/configz ~/.config/xava/config
# ----------------------------------------------------- 
# get wallpaper image name
# ----------------------------------------------------- 
newwall=$(echo $wallpaper | sed "s|$HOME/wallpaper/||g")



# ----------------------------------------------------- 
# Set the new wallpaper
# ----------------------------------------------------- 
swww img $wallpaper --transition-step 2 --transition-fps=60 --transition-type any
~/.config/scripts/reload.sh
#killall xava
#xava r
#sleep 2
#killall glava
#sleep 1
#hyprctl dispatch exec "[workspace 1 silent]" "glava -m graph"
#sleep 0.5
#hyprctl dispatch exec "[workspace 2 silent]" "glava -m graph"
#sleep 0.5
#hyprctl dispatch exec "[workspace 3 silent]" "glava -m graph"
#sleep 0.5
#hyprctl dispatch exec "[workspace 4 silent]" "glava -m graph"
#sleep 0.5
#hyprctl dispatch exec "[workspace 5 silent]" "glava -m graph"
#sleep 0.5
# ----------------------------------------------------- 
# Send notification
# ----------------------------------------------------- 
walogram

pywalfox update

hyprshade on vibrance
~/.config/mako/update-theme.sh

makoctl reload

#hyprctl --batch GLava -m graph
notify-send "Theme and Wallpaper updated" "With image $newwall"
echo "DONE!"

