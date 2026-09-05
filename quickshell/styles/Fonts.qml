// styles/Fonts.qml
pragma Singleton
import QtQuick

QtObject {
    property string display: "SF Pro Display"
    property string text: "SF Pro Text"
    readonly property string mono: "SF Pro Mono"
    readonly property string nerdFont: "JetBrains Mono Nerd Font Propo"

    // Icon style — now a real picker in Appearance settings. Valid values:
    // "Rounded", "Outlined", "Sharp".
    property string iconStyle: "Rounded"
    readonly property string icon: "Material Symbols " + iconStyle

    // Icon weight/fill — now live sliders in Appearance settings.
    property int iconWeight: 400
    property int iconFill: 0

    readonly property var iconAxes: ({
        "fill": iconFill,
        "wght": iconWeight,
        "GRAD": 0,
        "opsz": 24
    })

    readonly property var iconAxesFilled: ({
        "fill": 1,
        "wght": iconWeight,
        "GRAD": 0,
        "opsz": 24
    })
}