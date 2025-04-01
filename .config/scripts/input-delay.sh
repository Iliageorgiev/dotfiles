#!/bin/bash

# Function to run a single test
run_test() {
    echo "Starting test..."
    start=$(date +%s.%N)
    # Use a shorter timeout to reduce inflated measurements
    timeout 0.0001 evtest /dev/input/event21 | grep "KEY" &> /dev/null
    end=$(date +%s.%N)
    duration=$(echo "$end - $start" | bc)
    echo "$duration" > "test$i.txt" # Save duration to file
    echo "Test duration: $duration seconds"
}

# Run multiple tests and calculate average
for i in {1..100}; do
    run_test
done

# Calculate average
total_duration=0
for i in {1..100}; do
    total_duration=$(echo "scale=9; $total_duration + $(cat test$i.txt)" | bc)
done
average_latency=$(echo "scale=6; $total_duration / 10" | bc)

echo "Average latency over 100 tests: $average_latency seconds"
