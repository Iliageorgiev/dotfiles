#!/bin/bash
# Source and destination directories
SOURCE_DIR="/home/baiken80/Pictures/waybaricons/"
DEST_DIR="/home/baiken80/Documents/wallpaper/Awesome/"
# Ensure the destination directory exists
mkdir -p "$DEST_DIR"
# Loop through all files in the source directory
for file in "$SOURCE_DIR"*; do
    # Check if the file is an image
    if [[ $file == *.jpg ]] || [[ $file == *.png ]] || [[ $file == *.jpeg ]]; then
        # Upscale the image using waifu2x-ncnn-vulkan
        upscaled_file="${file%.*}-upscaled.png"
        waifu2x-ncnn-vulkan -i "$file" -o "$upscaled_file" -s 2 -n 1 -f png
        # Resize the upscaled image to 1920x1080
        resized_file="${file%.*}-resized.png"
        convert "$upscaled_file" -quality 100 -resize 32x32^ -gravity center -extent 32x32 "$resized_file"
        # Move the resized image to the destination directory
        mv "$resized_file" "$DEST_DIR"
        # Clean up the upscaled file
        rm "$upscaled_file"
    fi
done

