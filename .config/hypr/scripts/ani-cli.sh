
#!/bin/bash

# Check if Kitty is installed
if ! command -v kitty &> /dev/null; then
    echo "Kitty terminal is not installed. Please install Kitty."
    exit 1
fi

if ! command -v ani-cli &> /dev/null; then
    echo "ani-cli is not installed. Please install ani-cli."
    exit 1
fi

# Launch Kitty with Glava
kitty --title "ani-cli" --hold -- bash -c "ani-cli -c;"
