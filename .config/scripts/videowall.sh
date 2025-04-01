#!/bin/bash
cd /home/baiken80/.config/scripts/video_wall_app/target/release/

# Video thumbnail file chooser  app in rust 
video_files=$(./lazy_video_wall_app)


terminate_processes() {
    pids=(
        $(pgrep -f "workspace-listener.sh") \
        $(pgrep -f "mpvpaper-holder") \
        $(pgrep -f "glava") \
        $(pgrep -f "agsv1")
        $(pgrep -f "monitordetector.sh")
    )
    
    for pid in "${pids[@]}"; do
        if [ -n "$pid" ]; then
            kill -9 "$pid"
            echo "Terminated process with PID $pid"
        fi
    done
}



if [[ "$video_files" == *"Selection canceled"* ]]; then
    echo "Script stopped due to Selection canceled."
    exit 0
else 
    terminate_processes
fi
# Set the directory path where videos are stored
VIDEO_DIR="/mnt/4d106a33-00b7-4b0f-9386-d7bb389d3bcc/backup/Videos/Hidamari/"
pushd "$VIDEO_DIR"
# Get all video files in the directory

# Select a random video file
#random_video=$(shuf -n 1 <<< "$video_files")

# Play the selected video
if [ -f "$video_files" ]; then
    # Use mpv to play the video
    
    ffmpeg  -i "$video_files"  -y -vf  select='eq(pict_type\,PICT_TYPE_I)' -frames 1 -b:v 8000000 -preset slow -r 30  /home/baiken80/.config/scripts/output_frame.jpeg 
    wal -q -i /home/baiken80/.config/scripts/output_frame.jpeg 
    echo "$video_files"
   
    
    
    source "$HOME/.cache/wal/colors.sh"
    cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/
    cp ~/.cache/wal/colors-waybar.css ~/.config/ags/
    cp ~/.cache/wal/bars.glsl ~/.config/glava/
    cp ~/.cache/wal/colors-waybar.css ~/.config/wofi/
    cp ~/.cache/wal/colors-waybar.css ~/.config/wlogout/
    ln -sf ~/.cache/wal/config  ~/.config/mako/config
    ln -sf ~/.cache/wal/starship.toml ~/.config/starship.toml
    cp ~/.cache/wal/fuzzel.ini ~/.config/fuzzel/fuzzel.ini
    pywalfox update
    ~/.config/mako/update-theme.sh
    
    sleep 1
    killall mpvpaper
    mpvpaper -f -p -o "--loop --no-ytdl --vo=libmpv --fs  --no-video-sync --no-keepaspect" DP-3 "$video_files"
    ~/.config/scripts/workspace-listener.sh >/dev/null 2>&1 &
    ~/.config/scripts/monitordetector.sh >/dev/null 2>&1 &
    sleep 1.5
    
    # Function to start Glava
    start_glava() {
        killall glava
        sleep 0.5
        glava --desktop >/dev/null 2>&1 &
    }

    # Try to start Glava up to 3 times
    for i in {1..3}; do
        start_glava
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

    python3 /home/baiken80/.config/scripts/archlogogenerator.py
else
    echo "No videos found in the directory."
fi

# Get the MAC address of the DS4 controller
#DS4_MAC="E9:CB:88:31:7A:3E"  # Replace with your controller's MAC

# Function to find current DS4 LED paths
#find_ds4_leds() {
#    for led in /sys/class/leds/input*:red; do
#        if udevadm info -a "$led" 2>/dev/null | grep -q "054C.*09CC"; then
#            input_num=$(echo "$led" | grep -o 'input[0-9]*' | head -n1)
#            if [ -n "$input_num" ]; then
#                echo "/sys/class/leds/$input_num"
#                return 0
#            fi
#        fi
#    done
#    return 1
#}

# Function to set LED color
#set_led_color() {
#    local r=$1
#    local g=$2
#    local b=$3
#    
#    local led_base=$(find_ds4_leds)
#    
#    if [ -z "$led_base" ]; then
#        echo "Could not find DS4 LED controls! Is the controller connected?"
#        return 1
#    fi
#    
#    local red_led="${led_base}:red/brightness"
#    local green_led="${led_base}:green/brightness"
#    local blue_led="${led_base}:blue/brightness"
#    
#    if [ -f "$red_led" ] && [ -f "$green_led" ] && [ -f "$blue_led" ]; then
#        echo "Setting colors (R:$r G:$g B:$b)..."
#        echo "$r" > "$red_led"
#        echo "$g" > "$green_led"
#        echo "$b" > "$blue_led"
#        echo "LED color changed!"
#        return 0
#    else
#        echo "LED control files not found!"
#        return 1
#    fi
#}
#
# Function to get color from pywal
#get_pywal_color() {
#    local color_file="$HOME/.cache/wal/colors"
#    if [ ! -f "$color_file" ]; then
#        echo "Pywal colors file not found!"
#        return 1
#    fi
#    # Option 1: Get specific color (e.g., color 1, which is usually the primary accent)
#    local color=$(sed -n "2p" "$color_file")
#    
#    # Adjust factors (values between 0.0 and 2.0)
#    local brightness_factor=0.1  # Controls overall brightness
#    local saturation_factor=2  # Controls color intensity (>1 more saturated, <1 less saturated)
#    
#    # Convert hex to RGB
#    local r=$(printf "%d" "0x${color:1:2}")
#    local g=$(printf "%d" "0x${color:3:2}")
#    local b=$(printf "%d" "0x${color:5:2}")
#    
#    # Calculate average for saturation adjustment
#    local avg=$(( (r + g + b) / 3 ))
#    
#    # Adjust saturation (move values further/closer to average)
#    r=$(printf "%.0f" $(echo "$avg + ($r - $avg) * $saturation_factor" | bc))
#    g=$(printf "%.0f" $(echo "$avg + ($g - $avg) * $saturation_factor" | bc))
#    b=$(printf "%.0f" $(echo "$avg + ($b - $avg) * $saturation_factor" | bc))
#    
#    # Apply brightness
#    r=$(printf "%.0f" $(echo "$r * $brightness_factor" | bc))
#    g=$(printf "%.0f" $(echo "$g * $brightness_factor" | bc))
#    b=$(printf "%.0f" $(echo "$b * $brightness_factor" | bc))
#    
#    # Ensure values stay within 0-255 range
#    r=$(( r > 255 ? 255 : (r < 0 ? 0 : r) ))
#    g=$(( g > 255 ? 255 : (g < 0 ? 0 : g) ))
#    b=$(( b > 255 ? 255 : (b < 0 ? 0 : b) ))
    
#    echo "$r $g $b"
#}

# Check if controller is connected
#if bluetoothctl info "$DS4_MAC" | grep -q "Connected: yes"; then
#    echo "Controller connected successfully!"
#    # Wait a moment for the LED system to initialize
#    sleep 1
#    # Get color from pywal
#    read r g b <<< $(get_pywal_color)
#    echo "Setting pywal color: R:$r G:$g B:$b"
#    set_led_color $r $g $b
##else
#    echo "Connecting DS4 controller..."
#    if bluetoothctl connect "$DS4_MAC"; then
#        echo "Controller connected successfully!"
#        # Wait a moment for the LED system to initialize
#        sleep 1
#        # Get color from pywal
#        read r g b <<< $(get_pywal_color)
#        echo "Setting pywal color: R:$r G:$g B:$b"
#        set_led_color $r $g $b
#    else
#        echo "Failed to connect controller"
#    fi
#fi
#bash /home/baiken80/.config/scripts/wine-checker.sh &


