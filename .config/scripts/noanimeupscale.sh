#!/bin/bash
# Define source and destination directories
SOURCE_DIR="/home/baiken80/Documents/wallpaper/"
DEST_DIR="/home/baiken80/Documents/wallpaper/diffusion/"
# Ensure destination directory exists
mkdir -p "$DEST_DIR"
# Loop through all files in the source directory
for file in "$SOURCE_DIR"/*; do
    # Check if the file is an image
    if [[ $file == *.jpg ]] || [[ $file == *.png ]] || [[ $file == *.jpeg ]]; then
        # Extract the base name of the file (without path)
        base_name=$(basename "$file")
        # Convert the image to JPEG and save it in the destination directory
        convert "$file" -filter Lanczos -resize 200% -quality 10 "$DEST_DIR/${base_name%.*}.png"
    fi
done
echo "Conversion completed."
