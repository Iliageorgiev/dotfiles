#!/bin/bash
VIDEO_DIR="/mnt/4d106a33-00b7-4b0f-9386-d7bb389d3bcc/backup/Videos/Hidamari/"

video_files=$(find "$VIDEO_DIR" -type f -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mov")
random_video=$(shuf -n 1 <<< "$video_files")


ffmpeg  -i "$random_video"  -y -vf select='eq(pict_type\,PICT_TYPE_I)' -frames 1  /home/baiken80/.config/scripts/output_frame.jpeg

wal -q  -i ~/.config/scripts/output_frame.jpeg

