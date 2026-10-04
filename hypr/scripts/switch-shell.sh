#!/bin/bash
# Switch the active desktop shell (qs or ags), or stop it if it is already running.
#   switch-shell.sh qs
#   switch-shell.sh ags

target="$1"
state="$HOME/.config/hypr/.active-shell"
ags_script="$HOME/.config/ags/ags-launch-kill.sh"

# Print an error, show a notification if possible, and bail out without
# touching .active-shell (so a missing shell can't leave you with no shell).
fail() {
    echo "switch-shell: $1" >&2
    command -v notify-send >/dev/null && notify-send "Shell switch failed" "$1"
    exit 1
}

# Wait up to ~3s for a process (exact name) to exit.
wait_gone() {
    for _ in $(seq 30); do
        pgrep -x "$1" >/dev/null || return 0
        sleep 0.1
    done
    return 1
}

case "$target" in
    ags)
        command -v ags >/dev/null || fail "AGS is not installed"
        [ -x "$ags_script" ] || fail "$ags_script is missing or not executable"

        if pgrep -x ags >/dev/null; then
            "$ags_script"            # AGS running: toggle it off
            exit 0
        fi
        if pgrep -x quickshell >/dev/null; then
            pkill -x quickshell
            wait_gone quickshell
        fi
        echo ags > "$state"
        hyprctl reload
        "$ags_script"                # AGS not running: starts it
        ;;
    qs)
        command -v quickshell >/dev/null || fail "Quickshell is not installed"

        if pgrep -x quickshell >/dev/null; then
            pkill -x quickshell      # Quickshell running: toggle it off
            exit 0
        fi
        if pgrep -x ags >/dev/null && [ -x "$ags_script" ]; then
            "$ags_script"            # stop AGS first
            wait_gone ags
        fi
        echo qs > "$state"
        hyprctl reload
        setsid quickshell >/dev/null 2>&1 &
        ;;
    *)
        echo "Usage: $(basename "$0") qs|ags" >&2
        exit 1
        ;;
esac
