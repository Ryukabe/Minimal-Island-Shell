// features/hyprland/LayoutSettingsService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property var layouts: ["dwindle", "master", "scrolling"]
    property string current: ""

    function refresh() { readProc.running = true }

    function setLayout(name) {
        if (layouts.indexOf(name) < 0 || applyProc.running) return
        applyProc.command = ["bash", "-c", applyScript, "_", name]
        applyProc.running = true
    }

    readonly property string applyScript: `
        hyprctl eval "hl.config({ general = { layout = '$1' } })" >/dev/null
        now=$(hyprctl -j getoption general:layout | jq -r .str)
        [ "$now" = "$1" ] && echo "$now" > "$HOME/.config/hypr/.layout"
        echo "$now"
    `

    Process {
        id: readProc
        command: ["sh", "-c", "hyprctl -j getoption general:layout | jq -r .str"]
        stdout: StdioCollector { onStreamFinished: root.current = text.trim() }
    }

    Process {
        id: applyProc
        // Always ends with the layout Hyprland is really on, so a failed switch snaps the UI back
        stdout: StdioCollector { onStreamFinished: root.current = text.trim() }
    }

    Component.onCompleted: refresh()
}