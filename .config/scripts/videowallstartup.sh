#!/bin/bash

killall workspace-listener.sh
killall mpvpaper-holder
killall glava

# Set the directory path where videos are stored
VIDEO_DIR="/mnt/sdb2/backup/Videos/Hidamari/"
#pushd "$VIDEO_DIR"
# Get all video files in the directory
video_files=$(find "$VIDEO_DIR" -type f -name "*.mp4")
# Select a random video file
random_video=$(shuf -n 1 <<< "$video_files")

# Play the selected video
if [ -f "$random_video" ]; then
    # Use mpv to play the video
    
    ffmpeg  -i "$random_video"  -y -vf  select='eq(pict_type\,PICT_TYPE_I)' -frames 1 -b:v 8000000 -vf scale=1920:1080 -preset slow -r 30  /home/baiken80/.config/scripts/output_frame.jpeg 
    wal -q -i /home/baiken80/.config/scripts/output_frame.jpeg 
    echo "$random_video"
   
    
    
    source "$HOME/.cache/wal/colors.sh"
    cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/
    cp ~/.cache/wal/colors-waybar.css ~/.config/ags/
    cp ~/.cache/wal/bars.glsl ~/.config/glava/
    cp ~/.cache/wal/colors-waybar.css ~/.config/wofi/
    cp ~/.cache/wal/colors-waybar.css ~/.config/wlogout/
    ln -sf ~/.cache/wal/config  ~/.config/mako/config
    ln -sf ~/.cache/wal/starship.toml ~/.config/starship.toml
    cp ~/.cache/wal/fuzzel.ini ~/.config/fuzzel/fuzzel.ini
    
    ~/.config/mako/update-theme.sh
    
    
    sleep 1
    #dunst -conf /home/baiken80/.config/dunst/dunstrc &
    killall mpvpaper
    mpvpaper -f -auto-pause -s -o "--loop --no-ytdl --vo=libmpv --fs  --no-video-sync --no-keepaspect" DP-3 "$random_video"
    ~/.config/scripts/workspace-listener.sh >/dev/null 2>&1 &
    #~/.config/scripts/reload.sh >/dev/null 2>&1 &
    sleep 1
    #~/.config/scripts/monitordetector.sh
    #sleep 1.5 
    # Function to start Glava
    start_glava() {
        killall glava
        sleep 0.5
        glava  >/dev/null 2>&1 &
    }

    # Try to start Glava up to 3 times
    for i in {1..3}; do
        start_glava
        python3 /home/baiken80/.config/scripts/archlogogenerator.py
        sleep 2
        if pgrep -x "glava" > /dev/null; then
            echo "Glava started successfully"
            break
        fi
        echo "Attempt $i to start Glava failed, retrying..."
    done

    # If Glava is still not running, notify the user
    if ! pgrep -x "glava" > /dev/null; then
        echo "Failed to start Glava after 3 attempts"
        notify-send "Glava Error" "Failed to start Glava after 3 attempts"
    fi
   
    else
    echo "No videos found in the directory."
fi


