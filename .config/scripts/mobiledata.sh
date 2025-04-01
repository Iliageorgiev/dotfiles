#!/bin/bash

# Initialize a flag to indicate whether the SMS was sent successfully
sms_sent=false
kdeconnect-cli --refresh
# Loop until the SMS is sent successfully
while [ "$sms_sent" = false ]; do
    # Generate a random number between 1 and 1000
    random_number="$((RANDOM % 1000 + 1))"
    
    # Prepare the message
    message="Вивасмукцедес!!! $random_number"
    
    # Send the SMS using kdeconnect-cli
    kdeconnect-cli -d c89e839889dedc0e  --send-sms "$message" --destination 1237
    
    # Check if the previous command was successful
    if [ $? -eq 0 ]; then
        # If the command was successful, set the flag to true and break the loop
        sms_sent=true
    else
        # If the command failed, execute killall kdeconnectd an /usr/lib/kdeconnectd
        killall kdeconnectd
        kdeconnectd
        
        
        
        # Sleep for 2 seconds before trying again
        sleep 1
    fi
done

