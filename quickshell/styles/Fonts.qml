// styles/Fonts.qml
pragma Singleton
import QtQuick

QtObject {
    // Existing Font Definitions
    readonly property string display: "SF Pro Display"
    readonly property string text: "SF Pro Text"
    readonly property string mono: "SF Pro Mono"
    readonly property string nerdFont: "JetBrains Mono Nerd Font Propo"

    // Material Symbols Font Family
    // Set this to "Material Symbols Rounded", "Material Symbols Outlined", or "Material Symbols Sharp"
    readonly property string icon: "Material Symbols Rounded"

    // Material Symbols Variable Font Axes Configuration
    // Axes:
    // - "fill": 0 = Outlined, 1 = Filled (Solid)
    // - "wght": Font Weight / Stroke Thickness (100 = Thin, 400 = Regular, 700 = Bold)
    // - "GRAD": Emphasis Tweak (-25 to 200)
    // - "opsz": Optical Size tuning (typically matches font.pixelSize, e.g. 20 or 24)
    readonly property var iconAxes: ({
        "fill": 0,
        "wght": 400,
        "GRAD": 0,
        "opsz": 24
    })
    
    // Quick helper for solid/filled variants if needed
    readonly property var iconAxesFilled: ({
        "fill": 1,
        "wght": 400,
        "GRAD": 0,
        "opsz": 24
    })
}