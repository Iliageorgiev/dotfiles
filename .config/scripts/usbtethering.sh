#!/bin/bash
# Wait for the device to be fully recognized
sleep 10
# Enable USB tethering
nmcli con up id 'enp0s29u1u6'
