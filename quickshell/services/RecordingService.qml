// services/RecordingService.qml
pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root
    property bool enabled: false
    property string outputDir: "~/Videos"
    property string lastFilePath: ""

    property Process recordProc: Process {
        id: recordProc
        onRunningChanged: root.enabled = running
        onExited: root.enabled = false
    }

    property Process stopProc: Process {
        id: stopProc
        command: ["pkill", "-INT", "-x", "wf-recorder"]
    }

    function _timestamp() {
        const d = new Date()
        function pad(n) { return n < 10 ? "0" + n : "" + n }
        return d.getFullYear() + pad(d.getMonth() + 1) + pad(d.getDate()) + "-" + pad(d.getHours()) + pad(d.getMinutes()) + pad(d.getSeconds())
    }

    function start() {
        root.lastFilePath = root.outputDir + "/Recording-" + _timestamp() + ".mp4"
        recordProc.command = ["bash", "-c", "wf-recorder -f \"" + root.lastFilePath.replace("~", "$HOME") + "\""]
        recordProc.running = true
    }

    function stop() {
        stopProc.running = true
    }

    function toggle() {
        if (root.enabled) {
            stop()
        } else {
            start()
        }
    }
}