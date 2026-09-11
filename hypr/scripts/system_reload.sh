#!/bin/bash 

hyprctl reload 

pkill quickshell || quickshell &
