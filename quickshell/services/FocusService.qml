// services/FocusService.qml
pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool enabled: false

    function toggle() {
        enabled = !enabled
        if (enabled) {
            dndProcess.command = ["makoctl", "mode", "-a", "do-not-disturb"]
        } else {
            dndProcess.command = ["makoctl", "mode", "-r", "do-not-disturb"]
        }
        dndProcess.running = true
    }

    property Process dndProcess: Process {
        id: dndProcess
    }
}