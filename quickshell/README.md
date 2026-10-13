# Quickshell config — hermit-dots

A custom Wayland desktop shell for Hyprland, built with Quickshell (QML).
Everything runs from a single morphing floating pill, the **island**, which
becomes the app launcher, media controls, OSD, power menu, control center,
notification center, lock screen and more.

This folder is the Quickshell half of [hermit-dots](https://github.com/Ryukabe/hermit-dots).
The repo also ships an AGS shell; only one shell runs at a time.

Island concept credit: SaneAspect.

## Requirements

- Hyprland (Lua config) on Wayland
- Quickshell (`qs` command)
- Fonts: SF Pro Display / Text / Mono, a Nerd Font, Material Symbols
- Backing tools used by the services:
  - NetworkManager (`nmcli`): Wi-Fi
  - PipeWire: volume (native property writes)
  - `brightnessctl`: brightness
  - `hyprsunset`: night light
  - `wf-recorder`: screen recording
  - `systemd-inhibit`: caffeine
  - `auto-cpufreq`: power profiles
  - `cliphist`: clipboard
  - `awww`: wallpaper
  - `wl-copy`: calculator copy
  - `pacman` + an AUR helper (paru/yay): in-app updates

## Install

The hermit-dots installer symlinks this folder to `~/.config/quickshell`.
Updating is then a `git pull`.

## Run

- Start: `qs`
- Full restart (required after adding `.qml` files or editing any `qmldir`):
  `pkill -9 -f quickshell && qs`
- Switch between Quickshell and AGS: `switch-shell.sh`

## Folder layout

```
shell.qml          entry point, contains only Island {}
Island.qml         the PanelWindow + morphing island
modules/           full pages opened from the island
                   (AppLauncher, ControlCenter, PowerMenu, LockScreen,
                   NotificationCenter, ...)
components/        reusable pieces grouped by owning module
                   (bar/, control-center/, power-menu/, ...)
services/          singletons: Volume, Brightness, Wifi, Notification,
                   Timer, Wallpaper, PowerProfile, ShellState, ...
styles/            Colors, Dimens, Fonts, Motion
  themes/<name>/quickshell.json    dark/light palettes
  adapters/                        Hyprland, Kitty, VSCode
settings/          current Settings app (stays live until V2 replaces it)
settings-new/      Settings V2 (core/, components/, pages/)
assets/icons/      PNG icons
state/             runtime JSON (shell-settings.json, lockscreen.json)
```

Runtime data files live here too: `control-center-layout.json` and
`launcher-data.json`.

## Conventions

- No hardcoded values: sizes come from `Dimens.*`, colors from `Colors.*`,
  and all animation from the `styles/Motion.qml` tiers.
- The `PanelWindow` surface stays a fixed size. Only the inner island
  rectangle animates.
- Every new `.qml` file or singleton must be registered in `qmldir`.
- Settings persist as JSON through `FileView` with load guards and a
  debounce timer.
- One source of truth per setting.

## Themes

Available: ayu, catppuccin, everforest, flexoki, gruvbox, monochrome.
Each lives in `styles/themes/<name>/quickshell.json`, with `dark` and
`light` sub-objects.

## IPC

Control the shell from Hyprland binds or a terminal with `qs ipc call
<target> <function>`. List the live targets with `qs ipc show`.
Examples: `qs ipc call lock lock`, `qs ipc call brightness increase`.

## Settings

Open Settings through the `settings` IPC target. Settings V2 is being
built in `settings-new/`, with every menu defined in
`core/SettingsRegistry.qml`.

## Status

Active development. See the project task list for what is done and
what is planned.

## License

MIT, see the repo root.