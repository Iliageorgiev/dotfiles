#!/bin/bash

# Kill kdeconnectd
pkill kdeconnectd

# Wait for a moment to ensure the process is terminated
sleep 2

# Start kdeconnectd
/usr/lib/kdeconnectd
