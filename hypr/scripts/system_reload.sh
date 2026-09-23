#!/bin/bash 

hyprctl reload 

pkill quickshell &>/dev/null

sleep 0.5

quickshell & disown

