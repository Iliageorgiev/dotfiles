#!/bin/bash
# Define the output file name prefix and suffix
output_prefix="cardboard_vr_"
output_suffix=".mp4"
# Loop over all .mp4 files in the current directory
for input_file in *.mp4; do
    # Extract the base name without extension for the output file name
    base_name=$(basename "$input_file" .mp4)
    output_file="${output_prefix}${base_name}${output_suffix}"
    # Use ffmpeg to convert the video
    ffmpeg -i "$input_file" \
           -vf "scale=1280:720,format=yuv420p,stereo3d=sbsl:sbsl" \
           -c:v libx264 -preset slow -profile:v main -level 3.1 \
           -crf 2 -c:a aac -b:a 128k \
           "$output_file"
done
