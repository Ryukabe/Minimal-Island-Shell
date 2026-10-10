# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Point Zsh directly to the modular config folder
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Wayland & GPU Environment Flags
export MOZ_ENABLE_WAYLAND=1
export LIBVA_DRIVER_NAME=iHD
export LIBVA_DRIVER_NAME=i965