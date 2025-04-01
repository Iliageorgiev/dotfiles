#!/bin/bash

# Use zenity to get the search phrase from the user
SEARCH_PHRASE=$(zenity --entry --text="Enter your search phrase:")

if [ $? = 0 ]; then
    # If the user clicked OK, proceed with the search
    SEARCH_PHRASE="$SEARCH_PHRASE"
else
    # If the user canceled, exit the script
    echo "Search cancelled."
    exit 1
fi

# List of search engines to query
SEARCH_ENGINES=(
    "https://www.google.com/search?q=$SEARCH_PHRASE"
    "https://www.bing.com/search?q=$SEARCH_PHRASE"
    
    "https://www.yandex.com/search?text=$SEARCH_PHRASE&lr=21389"
    "https://duckduckgo.com/?q=$SEARCH_PHRASE&ia=web"
    "https://www.qwant.com/?q=$SEARCH_PHRASE&t=web"
    )

# Function to perform a search
perform_search() {
    local url="$1"
    echo "Searching $url"
    curl -s "$url" | grep -oP '(?<title>.*?)'
}

# Loop through each search engine URL and perform the search
for engine_url in "${SEARCH_ENGINES[@]}"; do
    perform_search "$engine_url"
    
done

# Open each result in a new tab using xdg-open
for engine_url in "${SEARCH_ENGINES[@]}"; do
    title=$(curl -s "$engine_url" | grep -oP '(?<title>.*?)')
    floorp --new-tab "$engine_url" &
    
done
