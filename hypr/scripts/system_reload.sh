#!/bin/bash
# Reload Hyprland, then restart whichever shell is active (qs or ags).

state="$HOME/.config/hypr/.active-shell"
ags_script="$HOME/.config/ags/ags-launch-kill.sh"
active=$(cat "$state" 2>/dev/null)

# Wait up to ~3s for a process (exact name) to exit.
wait_gone() {
    for _ in $(seq 30); do
        pgrep -x "$1" >/dev/null || return 0
        sleep 0.1
    done
    return 1
}

hyprctl reload

if [ "$active" = "ags" ]; then
    # ags-launch-kill.sh is a toggle, so only call it to stop if AGS is running,
    # then call it again to start.
    if pgrep -x ags >/dev/null; then
        "$ags_script"
        wait_gone ags
    fi
    "$ags_script"
else
    pkill -x quickshell
    wait_gone quickshell
    setsid quickshell >/dev/null 2>&1 &
fi
