#!/bin/bash

# You can find browser class via following command: xprop | grep "CLASS"

file="/home/andrew/42.png"

browser="firefox"
# browser="chromium"

if [ "$browser" = "firefox" ]; then
    win_name="File Upload"
fi

if [ "$browser" = "chromium" ]; then
    win_name="Open File"
fi

echo "Looking for the window of the '$browser' browser with name '$win_name'"

# Find window PID
WIN=$(for pid in $(xdotool search --class "$browser"); do if [[ $(xdotool getwindowname $pid) == "$win_name" ]]; then echo $pid; fi; done)

# Switch to the window
xdotool windowactivate $WIN

# Send file path
xdotool type --window $WIN "$file"

# Press "Open" button
xdotool key --window $WIN alt+o
