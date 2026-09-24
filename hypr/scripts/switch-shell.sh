#!/bin/bash

target="$1"
state="$HOME/.config/hypr/.active-shell"
ags_script="$HOME/.config/ags/ags-launch-kill.sh"

case "$target" in
    ags)
        if pgrep -x ags >/dev/null; then
            "$ags_script"            # AGS running: toggle it off
            exit 0
        fi
        pkill -x quickshell
        echo ags > "$state"
        hyprctl reload
        "$ags_script"                # AGS not running: starts it
        ;;
    qs)
        if pgrep -x quickshell >/dev/null; then
            pkill -x quickshell      # Quickshell running: toggle it off
            exit 0
        fi
        pgrep -x ags >/dev/null && "$ags_script"   # stop AGS first
        echo qs > "$state"
        hyprctl reload
        setsid quickshell >/dev/null 2>&1 &
        ;;
esac
