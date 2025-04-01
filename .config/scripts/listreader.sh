#!/bin/bash

# Input file
inputFile="/home/baiken80/Downloads/listp.txt"

# Check if the input file exists
if [ ! -f "$inputFile" ]; then
  echo "File $inputFile not found!"
  exit 1
fi

# Read the first line of the file
firstLine=$(head -n 1 "$inputFile")

# Copy the first line to the clipboard (simulating Ctrl+C)
echo "$firstLine" | wl-copy

# Verify if the clipboard contains the copied text
clipboardContent=$(wl-paste)

if [[ "$clipboardContent" != "$firstLine" ]]; then
  echo "Error: Clipboard did not update correctly."
  exit 1
fi

# Remove the first line from the file and save the rest to a temporary file
tail -n +2 "$inputFile" > "$inputFile.tmp"

# Append the first line to the end of the temporary file
echo "$firstLine" >> "$inputFile.tmp"

# Replace the original file with the temporary file
mv "$inputFile.tmp" "$inputFile"

echo "First line copied to clipboard and moved to the end of $inputFile."
