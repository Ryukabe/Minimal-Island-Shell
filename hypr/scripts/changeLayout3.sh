#!/usr/bin/env bash
# Script to cycle through 3 Hyprland layouts on the fly

notif="$HOME/.config/swaync/images/bell.png"

# Get current layout
LAYOUT=$(hyprctl -j getoption general:layout | jq '.str' | sed 's/"//g')

case $LAYOUT in
"dwindle")
	hyprctl keyword general:layout master
	# Clean up dwindle keybinds and set master keybinds if needed
	hyprctl keyword unbind SUPER,J
	hyprctl keyword unbind SUPER,K
	hyprctl keyword unbind SUPER,O
	hyprctl keyword bind SUPER,J,layoutmsg,cyclenext
	hyprctl keyword bind SUPER,K,layoutmsg,cycleprev
	notify-send -e -u low -i "$notif" "Layout: Master"
	;;
"master")
	hyprctl keyword general:layout scrolling
	# Set keybinds specific to your 3rd layout if needed
	hyprctl keyword unbind SUPER,J
	hyprctl keyword unbind SUPER,K
	notify-send -e -u low -i "$notif" "Layout: Scrolling"
	;;
"scrolling" | *)
	hyprctl keyword general:layout dwindle
	# Clean up and restore dwindle keybinds
	hyprctl keyword unbind SUPER,J
	hyprctl keyword unbind SUPER,K
	hyprctl keyword bind SUPER,J,cyclenext
	hyprctl keyword bind SUPER,K,cyclenext,prev
	hyprctl keyword bind SUPER,O,togglesplit
	notify-send -e -u low -i "$notif" "Layout: Dwindle"
	;;
esac