#!/usr/bin/env bash
# Cycle Hyprland layouts: dwindle -> master -> scrolling -> dwindle

notif="$HOME/.config/swaync/images/bell.png"

get_layout() {
    hyprctl -j getoption general:layout | jq -r '.str'
}

case "$(get_layout)" in
    dwindle) next=master ;;
    master)  next=scrolling ;;
    *)       next=dwindle ;;
esac

# `hyprctl keyword` is rejected by the Lua config; `eval` runs Lua instead.
hyprctl eval "hl.config({ general = { layout = \"$next\" } })"

# Report the layout Hyprland is really on, not the one we asked for.
now=$(get_layout)
if [ "$now" = "$next" ]; then
    # layout.lua reads this on reload so the layout survives reloads and shell switches.
    echo "$now" > "$HOME/.config/hypr/.layout"
    notify-send -e -u low -i "$notif" "Layout: ${now^}"
else
    notify-send -e -u critical "Layout change failed" "Still on: $now"
fi