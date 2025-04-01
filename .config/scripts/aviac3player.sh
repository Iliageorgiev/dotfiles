#!/bin/bash

# Function to display an error message
show_error() {
    zenity --error --text="$1" --title="Error"
    exit 1
}

# Prompt user to select the AVI file
avi_file=$(zenity --file-selection --title="Select AVI Video File" --file-filter="AVI files (*.avi)|*.avi")

# Check if the user canceled or selected an invalid file
if [[ -z "$avi_file" || ! -f "$avi_file" ]]; then
    show_error "No valid AVI file was selected."
fi

# Prompt user to select the AC3 audio file
ac3_file=$(zenity --file-selection --title="Select AC3 Audio File" --file-filter="AC3 files (*.ac3)|*.ac3")

# Check if the user canceled or selected an invalid file
if [[ -z "$ac3_file" || ! -f "$ac3_file" ]]; then
    show_error "No valid AC3 file was selected."
fi

# Play the files using mpv
mpv "$avi_file" --audio-file="$ac3_file"

# Check if mpv exited successfully
if [[ $? -ne 0 ]]; then
    zenity --error --text="There was a problem playing the files." --title="Playback Error"
    exit 1
fi

zenity --info --text="Playback finished." --title="Success"
