#!/usr/bin/env python3
import os
import subprocess
import curses
import sys
import tty
import termios
import logging

THUMBNAIL_SIZE = (200, 150)  # Size in pixels
# Global variables
selected_video = ""
video_directory = "/mnt/4d106a33-00b7-4b0f-9386-d7bb389d3bcc/backup/Videos/Hidamari/"
thumbnail_directory = os.path.join(video_directory, "thumbnails")
video_files = []
offset = 0
selected_index = 0

# Function to generate thumbnails using ffmpeg
def generate_thumbnail(video_file, thumbnail_path):
    if not os.path.exists(thumbnail_path):
        command = [
            "ffmpeg", "-i", video_file, "-ss", "00:00:01.000",
            "-s", f"{THUMBNAIL_SIZE[0]}:{THUMBNAIL_SIZE[1]}", "-vframes", "1", thumbnail_path, "-y"
        ]
        try:
            subprocess.run(command, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except subprocess.CalledProcessError as e:
            print(f"Error generating thumbnail for {video_file}: {e}")
    # Check if the generated thumbnail exists
    if not os.path.exists(thumbnail_path):
        print(f"Warning: Thumbnail not found for {video_file}. Generating...")
        generate_thumbnail(video_file, thumbnail_path)        
# Function that creates and write the log file
def write_to_log(message):
    with open("video_selection.log", "w") as log_file:
        log_file.write(message)
        
# Function to clear the previously displayed thumbnail
def clear_thumbnail():
    # Sending escape sequence to clear previous image region in Kitty
    subprocess.run(['kitty', '+kitten', 'icat', '--clear'])

# Function to display thumbnails using kitty's icat
def display_thumbnail(thumbnail_path):
    subprocess.run(['kitty', '+kitten', 'icat', thumbnail_path])

# Main function for terminal UI using curses
def main(stdscr):
    global video_files, offset, selected_index
    print("Script started")
    if not os.path.exists(thumbnail_directory):
        os.makedirs(thumbnail_directory)
       
    video_files = [f for f in os.listdir(video_directory) if f.endswith(".mp4")]
    
    
        

    while True:
        stdscr.clear()
        height, width = stdscr.getmaxyx()  # Get terminal size
        max_display = min(20, height - 4)  # Only show 20 files at a time or fit terminal height
        
        stdscr.addstr(0, 0, "UP/DOWN and press  ENTER:\n")

        # Display only thumbnails (20 at a time with offset for scrolling)
        for idx, video_file in enumerate(video_files[offset:offset + max_display]):  
            if idx == selected_index:
                # Clear the previous thumbnail before displaying the new one
                clear_thumbnail()
                # Show only the selected thumbnail
                display_thumbnail(os.path.join(thumbnail_directory, video_file[:-4] + ".jpg"))
            # Check if thumbnail exists for each video file
            thumbnail_path = os.path.join(thumbnail_directory, video_file[:-4] + ".jpg")
            if not os.path.exists(thumbnail_path):
                print(f"Warning: Thumbnail not found for {video_file}. Generating...")
                generate_thumbnail(video_file, thumbnail_path)
        # Get user input
        key = stdscr.getch()

        # Handle navigation keys
        if key == curses.KEY_UP:
            if selected_index > 0:
                selected_index -= 1
            elif offset > 0:  # Scroll up
                offset -= 1

        elif key == curses.KEY_DOWN:
            if selected_index < max_display - 1 and selected_index + offset < len(video_files) - 1:
                selected_index += 1
            elif offset + max_display < len(video_files):  # Scroll down
                offset += 1

        elif key == 10:  # Enter key
            selected_video = video_files[offset + selected_index]
            # Print the full path of the selected video (output to terminal)
            print(f"{selected_video}")

            write_to_log(f"/mnt/4d106a33-00b7-4b0f-9386-d7bb389d3bcc/backup/Videos/Hidamari/{selected_video}")
              
            break
    
    
    
    
   
       

# Run the curses application
if __name__ == "__main__":
    curses.wrapper(main)
