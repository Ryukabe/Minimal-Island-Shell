# Quickshell — Hermit Island

This directory contains the Quickshell (QML) implementation of the Hermit desktop shell. It is designed for a Wayland session running Hyprland and centers on a compact, animated top-edge pill called the **island**. The island changes shape and content to show the clock, status dashboard, app launcher, quick settings, notifications, power actions, and other tools.

This is the Quickshell half of [hermit-dots](https://github.com/Ryukabe/hermit-dots). The wider dotfiles setup also contains an AGS shell. Run only one shell implementation at a time; the `switch-shell.sh` helper belongs to the wider dotfiles installation.

> **Project status:** Active development. The Settings application is in use; this README describes the files and features currently present in this directory.

## Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Starting and restarting](#starting-and-restarting)
- [Using the shell](#using-the-shell)
- [IPC reference](#ipc-reference)
- [Settings and persistence](#settings-and-persistence)
- [Themes and wallpapers](#themes-and-wallpapers)
- [Directory guide](#directory-guide)
- [Development notes](#development-notes)
- [Migration inventory](MIGRATION.md)
- [Troubleshooting](#troubleshooting)
- [License and credits](#license-and-credits)

## Features

| Area | What it provides |
| --- | --- |
| Island and bar | Compact clock, workspace indicators, media activity, recording and timer indicators, hover/reveal behavior, and a morphing panel for expanded pages. |
| Status dashboard | Overview tabs for status, media, performance, and weather, with configurable widgets. |
| App launcher | Searches installed desktop applications, supports recents, favourites, aliases, and configurable matching. |
| Clipboard | Clipboard history browser backed by `cliphist`, with copy and clear actions. |
| Control Center | Editable quick-settings grid with device and system controls, sliders, and detail subviews. |
| Notifications | Notification previews/toasts, event toasts, grouping, history, and a notification center. |
| Media and audio | Media controls, volume and output selection, per-app stream volume, and audio-related controls. |
| Power and focus | Power menu, focus/quiet modes, night light, caffeine/idle inhibition, and power-profile controls. |
| Lock screen | Shell lock-screen UI, media and weather blocks, lock-screen settings, and power/reboot actions. |
| Timer | Timer page and compact timer indicator/toast. |
| Appearance | Theme and palette selection, wallpapers, motion, typography, opacity, and optional theme adapters for other applications. |
| Settings | Searchable settings application covering shell behavior, devices, appearance, apps, notifications, keybinds, display, and system information. |
| Hyprland integration | Reads or adjusts selected Hyprland settings, keybinds, monitor options, animations, decorations, and workspace state. |

The available controls depend on the corresponding desktop services and command-line tools being installed and working in the current user session.

## Requirements

### Core

- A running **Wayland** session with **Hyprland**. Several settings and integrations use `hyprctl`.
- **Quickshell**, including its QML modules used by the configuration (Qt Quick, Wayland layer-shell, I/O, PipeWire, and desktop-entry/service integrations). The executable is `qs`.
- A D-Bus session and the normal desktop services for any D-Bus-backed integrations you use.
- Fonts used by the current configuration:
  - SF Pro Display and SF Pro Text for display/body typography.
  - A Nerd Font for glyphs where required.
  - Material Symbols for interface icons.

The font family and icon choices can be changed in Settings. If a font is missing, Qt may substitute a fallback, so the appearance can differ without preventing the shell from starting.

### Optional integrations

Install only the tools for features you want to use. The core shell can still open when an optional tool is missing, but the related action or setting may not work.

| Tool or service | Used for |
| --- | --- |
| NetworkManager (`nmcli`) | Wi-Fi state, scanning, connection, and disconnection. |
| BlueZ (`bluetoothctl`) | Bluetooth radio and device actions. |
| PipeWire | Audio output and playback-stream controls; accessed through Quickshell's PipeWire integration. |
| `brightnessctl` | Reading and changing display brightness. Device permissions must allow the user to control brightness. |
| `hyprsunset` | Night-light color-temperature control. |
| `wf-recorder` | Screen recording. |
| `systemd-inhibit` | Caffeine mode / idle and sleep inhibition. |
| `auto-cpufreq` and `pkexec` | Changing power profiles (the service invokes `auto-cpufreq` through `pkexec`). |
| `cliphist` and `wl-copy` | Clipboard history and copying selected content to the Wayland clipboard. |
| `awww` | Applying static image wallpapers. |
| `mpvpaper` | Applying video wallpapers. |
| `curl` | Weather data retrieval and some online checks. |
| `hyprctl` and `jq` | Hyprland settings, monitor information, layout queries, and related settings pages. |
| `kitty` | Kitty theme adapter (requires Kitty remote-control support and the configured socket). |
| GTK settings utilities | GTK theme adapter. |
| VS Code command-line launcher | VS Code theme adapter. |
| `pacman` and a supported AUR helper (`paru` or `yay`) | Package-update checks/actions in the About page. |

Some actions additionally rely on standard system tools such as `bash`, `sh`, `grep`, `systemctl`, and `xdg-mime`. Exact feature requirements can evolve; when an integration fails, check that the named executable is available in the environment from which Quickshell was started.

## Installation

### With hermit-dots

The hermit-dots installer links this directory into `~/.config/quickshell`. Install or update the dotfiles using the instructions in the [hermit-dots repository](https://github.com/Ryukabe/hermit-dots). Once linked, update the checkout using that repository's normal update workflow.

### Manual / development checkout

Place or link this directory at:

```text
~/.config/quickshell
```

The shell expects the entry point (`shell.qml`), `Island.qml`, and the sibling `core/`, `features/`, `assets/`, `state/`, and `snippets/` paths to remain together. A symlink to a checkout is suitable; avoid copying only the entry QML file.

## Starting and restarting

Start the shell from the logged-in Wayland session:

```sh
qs
```

The root entry point is `shell.qml`. It creates the island, Settings application, and lock screen scope. If the setup is managed by a session startup script or service, start it there rather than launching a second copy manually.

Restart Quickshell after adding a QML file or changing a `qmldir` registration. A restart is also the most reliable way to apply broad QML changes. Use the process/service manager that started the shell, and make sure you do not leave both Quickshell and AGS running at once.

## Using the shell

- The compact island sits at the top edge of the screen. Clicking it opens the status dashboard; when a timer is active, clicking the timer indicator opens the timer page.
- Hover behavior, island visibility, dimensions, notch shape, click-outside dismissal, and scroll gestures are configurable in **Settings → Shell → Bar & Island**.
- When enabled in Settings, scrolling over the upper half of the compact island changes volume; scrolling over the lower half changes brightness. Each direction changes the value by a configured step.
- The launcher, clipboard, power menu, Control Center, notification center, timer, wallpaper picker, and theme switcher are available from the shell and can also be opened over IPC.
- Press **Escape** to return from an island page to its default compact page (the clock, or the timer toast while a timer is active).
- Settings opens in a separate floating window. **Escape** steps back from a nested settings view and then closes Settings; **Ctrl+F** focuses the settings search field.
- The lock screen is provided by this shell, but configure Hyprland/session keybindings and lock behavior deliberately before relying on it as the only system locking mechanism.

## IPC reference

Quickshell exposes shell actions through IPC. List the running shell's registered targets and functions with:

```sh
qs ipc show
```

General form:

```sh
qs ipc call <target> <function> [arguments...]
```

The functions below are registered in the current QML sources:

| Target | Functions |
| --- | --- |
| `launcher` | `open`, `close`, `toggle` |
| `clipboard` | `open`, `close`, `toggle` |
| `power` | `open`, `close`, `toggle` |
| `controlcenter` | `open`, `close`, `toggle` |
| `notificationcenter` | `open`, `close`, `toggle` |
| `themeswitcher` | `open`, `close`, `toggle` |
| `wallpaper` | `toggle` |
| `timer` | `open`, `close`, `toggle` |
| `settings` | `open`, `close`, `toggle`, `section <name>` |
| `lock` | `lock`, `unlock`, `toggle` |
| `volume` | `increase`, `decrease`, `toggle` |
| `brightness` | `increase`, `decrease` |

Examples:

```sh
qs ipc call launcher toggle
qs ipc call controlcenter open
qs ipc call settings open
qs ipc call settings section appearance/motion
qs ipc call volume increase
qs ipc call brightness decrease
qs ipc call lock lock
```

The `settings section` function accepts a menu or view name understood by the settings navigation registry; `appearance/motion` is one example. IPC registration is runtime state, so `qs ipc show` is authoritative for the currently running version.

## Settings and persistence

The Settings UI is implemented in `features/settings/`. Its single registry, `features/settings/core/SettingsRegistry.qml`, defines the menus and page paths. Current areas include:

- **Shell:** Bar & Island, workspace indicators, clock, dashboard, launcher, clipboard/search tools, Control Center, lock screen, and lock-screen knowledge.
- **Devices:** Wi-Fi, Bluetooth, sound and media, displays, trackpad/mouse, and Hyprland/Quickshell/media keybinds.
- **Looks:** wallpaper, theme and palette, typography, motion, opacity, and application theme templates.
- **System:** default/startup/all apps, focus and notifications, language and region, About/system information, and update checks.

Most shell preferences are saved in `state/shell-settings.json`. Other features use additional state files in `state/`, including appearance, launcher, lock-screen, weather, Control Center layout, and knowledge data. Theme selection is stored under `core/styles/themes/`; wallpaper selection and related options use hidden state files in `state/`.

These files are part of the running configuration, not disposable cache. Back them up before manually editing or replacing them. Prefer the Settings UI for changing preferences, because it applies validation, migration/loading logic, and live updates where implemented. Do not commit personal settings or sensitive local data when maintaining a public fork.

## Themes and wallpapers

### Themes

Theme palettes are JSON files under `core/styles/themes/<theme>/quickshell.json`. Current theme directories include:

`ayu`, `catppuccin`, `everforest`, `gruvbox`, `hermit`, `kanagawa`, `monochrome`, `nightfox`, `rosepine`, and `tokyonight`.

The theme files provide dark and light palettes. Use **Settings → Looks → Appearance → Theme** (or the theme switcher) to select and customize a palette. The `core/styles/adapters/` directory contains optional synchronization adapters for Hyprland, GTK, Kitty, and VS Code; an adapter may require additional tools and configuration.

### Wallpapers

Bundled wallpapers are grouped by theme in `assets/wallpapers/`. The wallpaper picker can use the current theme's folder or a custom folder. Static images are applied through `awww`; video wallpapers use `mpvpaper`. Animated wallpaper support depends on the configured mode and installed tools. Wallpaper preferences are persisted in `state/`.

## Directory guide

```text
shell.qml                    Quickshell root; creates Island, Settings, LockScreen, and lock IPC
Island.qml                   Top-edge PanelWindow, page router, compact bar, and island IPC
core/                        Shared shell state, common controls, styles, and theme data
core/common/                 Reusable controls shared by shell features
core/shell/                  Shared shell state singleton
core/styles/                 Colors, dimensions, fonts, motion, adapters, and theme data
features/                    Feature-oriented QML modules, services, and settings pages
features/bar/                Bar and island UI, settings, and related services
features/control-center/     Control Center UI, components, layout service, and settings
features/settings/           Floating Settings app, navigation, components, and About pages
assets/icons/                Small shell status and media icons
assets/wallpapers/           Bundled wallpapers organized by theme
state/                       Persisted preferences and feature-specific runtime state
snippets/                    User-facing notes and snippet resources
```

Each feature keeps its QML types together under `features/<name>/`; component subfolders remain nested where needed. QML type directories have a `qmldir` file, and module declarations and paths must stay consistent with their imports.

## Development notes

- **Keep values centralized.** Use `core/styles/Dimens.qml` for sizing and spacing, `core/styles/Colors.qml` for palette values, and `core/styles/Motion.qml` for animation tiers rather than introducing unrelated literals.
- **Respect the layer-shell geometry.** `Island.qml` keeps the `PanelWindow` surface at a stable screen-covering size; the inner island rectangle changes size and position. Preserve this arrangement when changing morphing or input behavior.
- **Register QML modules.** When adding a QML file to an imported module, update the appropriate `qmldir`. Restart Quickshell after adding a file or editing a registration.
- **Use feature services.** System state and actions belong in the relevant feature singleton; shared shell state belongs in `core/shell/`. Pages and reusable components should consume those services instead of creating competing sources of truth.
- **Persist settings consistently.** Follow the existing `FileView`/settings-store patterns, including load guards and debounced writes where appropriate. Keep one source of truth per setting.
- **Keep Settings discoverable.** For a new settings page, add its entry and page path to `features/settings/core/SettingsRegistry.qml`, and follow the existing page/component conventions.
- **Avoid assuming optional commands exist.** Check for tool availability and report actionable failures when adding new external integrations.
- **Review both display modes.** Theme palettes provide dark and light variants; check reduced-motion behavior when changing animations.

## Troubleshooting

### The shell does not start

1. Run `qs` from a terminal inside the active Wayland session and read the QML/import errors it prints.
2. Confirm `~/.config/quickshell` contains the full checkout and that `shell.qml` is present.
3. Check for a typo or missing registration in the relevant `qmldir`.
4. Restart Quickshell after adding files or changing module declarations.
5. Check whether a second shell instance or AGS is already running and competing for the same desktop role.

### A control appears but does not work

Confirm that its optional executable/service is installed, active, and usable by the logged-in user. For example, Wi-Fi depends on NetworkManager, Bluetooth on BlueZ, brightness on `brightnessctl` permissions, and volume on PipeWire. Start Quickshell from the same user session that owns those services so it inherits the correct D-Bus and Wayland environment.

### Fonts or icons look wrong

Install the configured font families and refresh the font cache or restart the session if needed. Alternatively, select installed families in Settings. Missing fonts normally result in substitutions rather than a QML loading error.

### IPC calls fail

Confirm Quickshell is running, then inspect live target names with `qs ipc show`. Target names are case-sensitive; use the spelling shown in the IPC reference. New handlers only appear after their QML component has loaded and registered.

### Wallpapers do not change

Check that the selected image exists and that `awww` is available for static images. Video wallpapers require `mpvpaper`. If using a custom folder, check that the directory is readable by the user running Quickshell.

## License and credits

The Quickshell configuration is distributed under the **MIT License**; see the repository root for the license text. The About page attributes the project to Ryukabe.

The island concept is credited to **SaneAspect**.
