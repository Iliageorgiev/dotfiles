#!/bin/sh

# Symlink dunst config
ln -sf ~/.cache/wal/dunstrc ~/.config/dunst/dunstrc

# Restart dunst with the new color scheme

# Function to kill Dunst
kill_dunst() {
    pkill -f dunst
    echo "Dunst killed."
}
# Function to start Dunst
start_dunst() {
    dunst &
    echo "Dunst started."
}
# Main script
echo "Attempting to kill Dunst..."
kill_dunst
echo "Attempting to start Dunst..."
start_dunst
echo "Dunst has been restarted."
sleep 3
