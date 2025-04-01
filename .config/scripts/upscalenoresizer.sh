#!/bin/bash
# Define the source and destination directories
SOURCE_DIR="/home/baiken80/Documents/wallpaper/"
DEST_DIR="/home/baiken80/Documents/wallpaper/Awesome/"
# Ensure the destination directory exists
mkdir -p "$DEST_DIR"
# Loop through all files in the source directory
for file in "$SOURCE_DIR"*; do
    # Check if the file is an image
    if [[ $file == *.jpg ]] || [[ $file == *.png ]] || [[ $file == *.jpeg ]]; then
        # Extract the base name of the file
        base_name=$(basename "$file")
        # Define the output file path
        output_file="$DEST_DIR$base_name"
        
        # Upscale the image with waifu2x-ncnn-vulkan
        waifu2x-ncnn-vulkan -i "$file" -o "$output_file" -s 4 -n 1
        
        # Resize the image with ImageMagick to 1920x1080
        #convert "$output_file" -resize 1920x1080\! -quality 10 "$output_file"
    fi
done
echo "Processing complete."
