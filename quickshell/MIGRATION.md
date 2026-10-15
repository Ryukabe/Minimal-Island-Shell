# Migration

## Phase 1: core

- `styles/Colors.qml` -> `core/styles/Colors.qml`
- `styles/Dimens.qml` -> `core/styles/Dimens.qml`
- `styles/Fonts.qml` -> `core/styles/Fonts.qml`
- `styles/Motion.qml` -> `core/styles/Motion.qml`
- `styles/qmldir` -> `core/styles/qmldir`
- `styles/adapters/Alacritty.qml` -> `core/styles/adapters/Alacritty.qml`
- `styles/adapters/Btop.qml` -> `core/styles/adapters/Btop.qml`
- `styles/adapters/Firefox.qml` -> `core/styles/adapters/Firefox.qml`
- `styles/adapters/Gtk3.qml` -> `core/styles/adapters/Gtk3.qml`
- `styles/adapters/Gtk4.qml` -> `core/styles/adapters/Gtk4.qml`
- `styles/adapters/Helix.qml` -> `core/styles/adapters/Helix.qml`
- `styles/adapters/Hyprland.qml` -> `core/styles/adapters/Hyprland.qml`
- `styles/adapters/Kitty.qml` -> `core/styles/adapters/Kitty.qml`
- `styles/adapters/Obsidian.qml` -> `core/styles/adapters/Obsidian.qml`
- `styles/adapters/Qt5ct.qml` -> `core/styles/adapters/Qt5ct.qml`
- `styles/adapters/Qt6ct.qml` -> `core/styles/adapters/Qt6ct.qml`
- `styles/adapters/Starship.qml` -> `core/styles/adapters/Starship.qml`
- `styles/adapters/VSCode.qml` -> `core/styles/adapters/VSCode.qml`
- `styles/adapters/qmldir` -> `core/styles/adapters/qmldir`
- `styles/themes/.current-theme` -> `core/styles/themes/.current-theme`
- `styles/themes/ayu/quickshell.json` -> `core/styles/themes/ayu/quickshell.json`
- `styles/themes/catppuccin/quickshell.json` -> `core/styles/themes/catppuccin/quickshell.json`
- `styles/themes/everforest/quickshell.json` -> `core/styles/themes/everforest/quickshell.json`
- `styles/themes/gruvbox/quickshell.json` -> `core/styles/themes/gruvbox/quickshell.json`
- `styles/themes/hermit/quickshell.json` -> `core/styles/themes/hermit/quickshell.json`
- `styles/themes/kanagawa/quickshell.json` -> `core/styles/themes/kanagawa/quickshell.json`
- `styles/themes/monochrome/quickshell.json` -> `core/styles/themes/monochrome/quickshell.json`
- `styles/themes/nightfox/quickshell.json` -> `core/styles/themes/nightfox/quickshell.json`
- `styles/themes/rosepine/quickshell.json` -> `core/styles/themes/rosepine/quickshell.json`
- `styles/themes/THEME's.bak/flexoki/quickshell.json` -> `core/styles/themes/THEME's.bak/flexoki/quickshell.json`
- `styles/themes/THEME's.bak/github/quickshell.json` -> `core/styles/themes/THEME's.bak/github/quickshell.json`
- `styles/themes/tokyonight/quickshell.json` -> `core/styles/themes/tokyonight/quickshell.json`
- `components/common/LevelIndicator.qml` -> `core/common/LevelIndicator.qml`
- `components/common/MorphSpring.qml` -> `core/common/MorphSpring.qml`
- `components/common/ToggleSwitch.qml` -> `core/common/ToggleSwitch.qml`
- `components/common/qmldir` -> `core/common/qmldir`
- `services/ShellState.qml` -> `core/state/ShellState.qml`

## Placement notes

- `services/LayoutSettingsService.qml` is used by the Display settings page and Settings startup refresh; it is grouped with display settings.
- No unresolved placements.
