// settings/StatePersistence.qml
import QtQuick
import Quickshell.Io
import "../services"

Item {
    id: root

    property bool loading: true

    function triggerSave() {
        if (loading) return
        saveTimer.restart()
    }

    Timer {
        id: saveTimer
        interval: 300
        repeat: false
        onTriggered: {
            let data = {
                "islandTopMargin": ShellState.islandTopMargin,
                "islandCornerRadius": ShellState.islandCornerRadius,
                "islandBorderWidth": ShellState.islandBorderWidth,
                "islandClickOutsideDismiss": ShellState.islandClickOutsideDismiss,
                "islandNotchMode": ShellState.islandNotchMode,
                "islandNotchFlare": ShellState.islandNotchFlare,
                "islandCompactHeight": ShellState.islandCompactHeight,
                "islandCompactWidth": ShellState.islandCompactWidth,
                "islandExpandedHeight": ShellState.islandExpandedHeight,
                "islandMinExpandedWidth": ShellState.islandMinExpandedWidth,
                "launcherWidth": ShellState.launcherWidth,
                "launcherMaxRows": ShellState.launcherMaxRows,
                "clipboardWidth": ShellState.clipboardWidth,
                "clipboardMaxRows": ShellState.clipboardMaxRows,
                "controlCenterWidth": ShellState.controlCenterWidth,
                "controlCenterHeight": ShellState.controlCenterHeight,
                "notificationCenterWidth": ShellState.notificationCenterWidth,
                "notificationCenterMaxHeight": ShellState.notificationCenterMaxHeight,
                "powerMenuWidth": ShellState.powerMenuWidth,
                "powerMenuHeight": ShellState.powerMenuHeight,
                "statusPanelWidth": ShellState.statusPanelWidth,
                "statusPanelHeight": ShellState.statusPanelHeight,
                "timerWidth": ShellState.timerWidth,
                "timerHeight": ShellState.timerHeight,
                "motionReduced": ShellState.motionReduced,
                "motionMovementMs": ShellState.motionMovementMs,
                "motionFadeMs": ShellState.motionFadeMs,
                "motionHoverMs": ShellState.motionHoverMs,
                "motionBouncePercent": ShellState.motionBouncePercent
            }
            saveProcess.command = ["sh", "-c", "cat << 'EOF' > state.json\n" + JSON.stringify(data, null, 2) + "\nEOF"]
            saveProcess.running = true
        }
    }

    Process { id: saveProcess }

    FileView {
        id: stateFile
        path: Qt.resolvedUrl("../state.json")

        onLoaded: {
            try {
                let data = JSON.parse(stateFile.text)
                for (let key in data) {
                    if (ShellState[key] !== undefined) {
                        ShellState[key] = data[key]
                    }
                }
            } catch (e) {
                console.log("Error loading state.json:", e)
            }
            root.loading = false
        }
    }
}