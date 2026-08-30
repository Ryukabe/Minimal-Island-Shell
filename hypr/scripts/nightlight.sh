#!/bin/bash

# Check if hyprsunset is already running
if pgrep -x "hyprsunset" > /dev/null; then
    # Kill hyprsunset if it's running (switch to day mode)
    killall -9 hyprsunset
    notify-send "Night Light" "Off" -u "low"
else
    # Start hyprsunset for night mode
    hyprsunset --temperature 3500 &
    hyprsunset --gamma 0.8 &
    notify-send "Night Light" "On" -u "low"
fi