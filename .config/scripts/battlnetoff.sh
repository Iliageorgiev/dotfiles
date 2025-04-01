#!/bin/bash
# Define the file name
file_name="final_processes.txt" 
# Check if the file exists
if [ -f "$file_name" ]; then
    # Read the file line by line
    while IFS= read -r pid; do
        # Kill the process by its PID
        kill "$pid" 2>/dev/null
    done < "$file_name"
    # Delete the file
    rm process_differences.txt
    rm initial_processes.txt
    rm final_processes.txt
    echo "File output text files has been deleted."
else
    echo "File $file_name does not exist."
fi
