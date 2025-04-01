#!/bin/bash

devices=$(bluetoothctl paired-devices | awk '{print $2}')

for device in $devices; do
    battery_info=$(gatttool -b $device --char-read -a 0x000f)
    battery_percentage=$(echo $battery_info | cut -c 34-35)
    device_name=$(bluetoothctl info $device | grep "Name" | cut -d ' ' -f 2-)

    echo "{\"label\":\"$device_name\",\"percentage\":\"$battery_percentage%\"}"
done
