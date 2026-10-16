// pages/appearance/templates/TemplatesSettings.qml — Appearance > Templates.
// Per-app switches for re-theming other apps whenever the theme changes.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "../../core/shell"
import "../../core/styles"

PageScroll {
    id: root

    SectionLabel { text: "Templates" }

    GroupCard {
        ToggleRow {
            label: "Sync theme to other apps"
            description: "Write your theme colors into the apps below whenever the theme changes"
            checked: ShellState.templatesEnabled
            onToggled: (v) => ShellState.templatesEnabled = v
            showDivider: false
        }
    }

    // Everything below dims and stops taking clicks while the master switch is off.
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Dimens.spacingMedium
        enabled: ShellState.templatesEnabled
        opacity: ShellState.templatesEnabled ? 1.0 : 0.45

        Behavior on opacity {
            NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
        }

        SectionLabel { text: "System" }

        GroupCard {
            ToggleRow {
                label: "GTK 3"
                description: "Writes ~/.config/gtk-3.0/gtk.css (also themes Thunar)"
                checked: ShellState.templateGtk3
                onToggled: (v) => ShellState.templateGtk3 = v
            }
            ToggleRow {
                label: "GTK 4 / libadwaita"
                description: "Writes ~/.config/gtk-4.0/gtk.css"
                checked: ShellState.templateGtk4
                onToggled: (v) => ShellState.templateGtk4 = v
            }
            ToggleRow {
                label: "Qt 5 (qt5ct)"
                description: "Writes a qt5ct color scheme"
                checked: ShellState.templateQt5ct
                onToggled: (v) => ShellState.templateQt5ct = v
            }
            ToggleRow {
                label: "Qt 6 (qt6ct)"
                description: "Writes a qt6ct color scheme"
                checked: ShellState.templateQt6ct
                onToggled: (v) => ShellState.templateQt6ct = v
                showDivider: false
            }
        }

        SectionLabel { text: "Terminal" }

        GroupCard {
            ToggleRow {
                label: "Kitty"
                description: "Recolors open Kitty windows live"
                checked: ShellState.templateKitty
                onToggled: (v) => ShellState.templateKitty = v
            }
            ToggleRow {
                label: "Alacritty"
                description: "Writes hermit-colors.toml"
                checked: ShellState.templateAlacritty
                onToggled: (v) => ShellState.templateAlacritty = v
            }
            ToggleRow {
                label: "Starship"
                description: "Prompt colors, built from starship.base.toml"
                checked: ShellState.templateStarship
                onToggled: (v) => ShellState.templateStarship = v
                showDivider: false
            }
        }

        SectionLabel { text: "Editor" }

        GroupCard {
            ToggleRow {
                label: "VS Code"
                description: "Syncs editor colors with the theme"
                checked: ShellState.templateVSCode
                onToggled: (v) => ShellState.templateVSCode = v
            }
            ToggleRow {
                label: "Helix"
                description: "Writes the hermit theme"
                checked: ShellState.templateHelix
                onToggled: (v) => ShellState.templateHelix = v
            }
            ToggleRow {
                label: "Obsidian"
                description: "Writes a CSS snippet into your vault"
                checked: ShellState.templateObsidian
                onToggled: (v) => ShellState.templateObsidian = v
                showDivider: false
            }
        }

        SectionLabel { text: "Compositor" }

        GroupCard {
            ToggleRow {
                label: "Hyprland"
                description: "Active and inactive window border colors"
                checked: ShellState.templateHyprland
                onToggled: (v) => ShellState.templateHyprland = v
                showDivider: false
            }
        }

        SectionLabel { text: "System monitor" }

        GroupCard {
            ToggleRow {
                label: "btop"
                description: "Writes the hermit theme"
                checked: ShellState.templateBtop
                onToggled: (v) => ShellState.templateBtop = v
                showDivider: false
            }
        }

        SectionLabel { text: "Browser" }

        GroupCard {
            ToggleRow {
                label: "Firefox"
                description: "Writes a colors file for userChrome.css"
                checked: ShellState.templateFirefox
                onToggled: (v) => ShellState.templateFirefox = v
                showDivider: false
            }
        }
    }

    Text {
        Layout.fillWidth: true
        Layout.leftMargin: Dimens.paddingMedium
        Layout.rightMargin: Dimens.paddingMedium
        text: "Turning an app on applies the current theme right away. Turning it off stops future updates but leaves the colors it already has."
        color: Colors.subtext
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeXs
        wrapMode: Text.WordWrap
    }
}