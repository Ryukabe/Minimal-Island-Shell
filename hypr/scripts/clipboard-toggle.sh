#!/usr/bin/env bash

if pgrep -f 'rofi.*clipboard' >/dev/null; then
  pkill -f 'rofi.*clipboard'
  exit 0
fi

cliphist list | rofi -dmenu -display-columns 2 -p "Clipboard" \
  -window-title "clipboard" -theme "$HOME/.config/rofi/applauncher.rasi" \
  | cliphist decode | wl-copy
  