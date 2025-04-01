#!/bin/bash

SINKS=(
    "alsa_output.pci-0000_00_1b.0.analog-stereo" # HDMI output 1
    "alsa_output.pci-0000_01_00.1.hdmi-stereo" # HDMI output 2
)
CURRENT_SINK=$(pactl get-default-sink)
ACTIVE_INDEX=0

for ((i=0; i<${#SINKS[@]}; i++)); do
    if [ "${SINKS[i]}" = "$CURRENT_SINK" ]; then
        ACTIVE_INDEX=$i
        break
    fi
done

NEXT_INDEX=$((ACTIVE_INDEX + 1))
NEXT_INDEX=$((NEXT_INDEX % ${#SINKS[@]}))

# Print current and next sink
echo "Current sink: ${SINKS[ACTIVE_INDEX]}"
echo "Next sink: ${SINKS[NEXT_INDEX]}"

# Try to set the next sink
if pactl set-default-sink "${SINKS[NEXT_INDEX]}"; then
    echo "Successfully switched to: ${SINKS[NEXT_INDEX]}"
else
    echo "Failed to switch to: ${SINKS[NEXT_INDEX]}"
    echo "Error: $(pactl set-default-sink "${SINKS[NEXT_INDEX]}")"
fi
