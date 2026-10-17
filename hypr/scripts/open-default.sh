#!/bin/sh
# open-default.sh <browser|terminal|files>
# Launches whatever app is currently the system default for that kind, so a keybind
# follows Settings > Apps > Default apps instead of naming one app.
# Needs: xdg-utils (xdg-mime) and gtk3 (gtk-launch).

kind="$1"

case "$kind" in
    browser)  mime="x-scheme-handler/https";    fallback="zen-browser" ;;
    terminal) mime="x-scheme-handler/terminal"; fallback="kitty" ;;
    files)    mime="inode/directory";           fallback="thunar" ;;
    *) echo "usage: open-default.sh <browser|terminal|files>" >&2; exit 2 ;;
esac

id="$(xdg-mime query default "$mime" 2>/dev/null)"
id="${id%.desktop}"

# Default set and launchable -> use it. Otherwise fall back to the app the bind used before.
if [ -n "$id" ] && gtk-launch "$id" >/dev/null 2>&1; then
    exit 0
fi

exec $fallback
