#!/bin/bash
# Capture the list of all processes after the application has started
ps -eo pid,comm > final_processes.txt
# Compare the initial and final process lists and output the differences to a text file
comm -13 initial_processes.txt final_processes.txt > process_differences.txt
