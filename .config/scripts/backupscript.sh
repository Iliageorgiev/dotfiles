#!/bin/bash
# Use zenity to select the source directory
source_dir=$(zenity --file-selection --directory --title="Select Source Directory")
if [ $? != 0 ]; then
    echo "No source directory selected."
    exit 1
fi

# Use zenity to select the backup directory
backup_dir=$(zenity --file-selection --directory --title="Select Backup Directory")
if [ $? != 0 ]; then
    echo "No backup directory selected."
    exit 1
fi

# Extract the base name of the source directory
source_base_name=$(basename "$source_dir")

# Generate a timestamp for the backup file name
timestamp=$(date +%d:%m:%Y)

# Create a unique backup file name including the source directory name and timestamp
backup_file="backup_${source_base_name}_${timestamp}.tar.gz"

# Compress the source directory into a .tar.gz archive within the backup directory
tar -czvf "$backup_dir/$backup_file" "$source_dir"
zenity --info --text="Backup completed successfully!" --title="Backup Notification"
echo "Backup completed successfully!"
