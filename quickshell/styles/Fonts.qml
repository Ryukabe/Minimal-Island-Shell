// styles/Fonts.qml
pragma Singleton
import QtQuick
import "../services"

// Read-only view of the typography state. The source of truth is
// ShellState (persisted by SettingsStore) — write there, never here.
QtObject {
    readonly property string display: ShellState.fontDisplay
    readonly property string text: ShellState.fontBody
    readonly property string mono: "SF Pro Mono"
    readonly property string nerdFont: "JetBrains Mono Nerd Font Propo"

    // Valid iconStyle values: "Rounded", "Outlined", "Sharp".
    readonly property string iconStyle: ShellState.iconStyle
    readonly property string icon: "Material Symbols " + iconStyle

    readonly property int iconWeight: ShellState.iconWeight
    readonly property int iconFill: ShellState.iconFilled ? 1 : 0

    // Material Symbols axis tags: FILL, wght, GRAD, opsz (FILL/GRAD uppercase).
    readonly property var iconAxes: ({
        "FILL": iconFill,
        "wght": iconWeight,
        "GRAD": 0,
        "opsz": 24
    })

    readonly property var iconAxesFilled: ({
        "FILL": 1,
        "wght": iconWeight,
        "GRAD": 0,
        "opsz": 24
    })
}