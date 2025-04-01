#!/bin/bash

# Check if a file was selected
if [ "$1" = "" ]; then
    echo "Please select a file."
    exit 1
fi

# Use floorp to open the image in a new tab
floorp --new-tab "$1"
