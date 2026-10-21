// welcome/WelcomeTheme.qml — look of the welcome app. Self-contained on purpose: the welcome app
// is its own process and must not import the main shell's Colors/ShellState (they start services).
// Colors are the Hermit default dark palette, the same values as Colors._safetyPalette.
pragma Singleton
import QtQuick

QtObject {
    readonly property color bg: "#101010"
    readonly property color surface: "#1C1C1C"
    readonly property color elevated: Qt.lighter(surface, 1.25)
    readonly property color fg: "#F6F1EA"
    readonly property color muted: "#8C8C8C"
    readonly property color border: "#1F1F1F"
    readonly property color outline: Qt.lighter(border, 1.8)
    readonly property color accent: "#77B0A8"

    readonly property string fontDisplay: "SF Pro Display"
    readonly property string fontText: "SF Pro Text"
    readonly property string fontMono: "SF Pro Mono"

    readonly property real fontXs: 11
    readonly property real fontSm: 12
    readonly property real fontMd: 14
    readonly property real fontLg: 17
    readonly property real fontXl: 22
    readonly property real fontXxl: 28

    readonly property real spacingSm: 6
    readonly property real spacingMd: 12
    readonly property real spacingLg: 18
    readonly property real padSm: 6
    readonly property real padMd: 12
    readonly property real padLg: 18

    readonly property real radiusSm: 6
    readonly property real radiusMd: 10
    readonly property real radiusLg: 14
    readonly property real radiusFull: 999

    readonly property real sidebarWidth: 260
    readonly property real labelWidth: 90
    readonly property int animMs: 180
}