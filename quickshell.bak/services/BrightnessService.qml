// services/BrightnessService.qml

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../services"

Singleton {
    id: root
    readonly property int step: 5
    property int percent: 50

    Process {
        id: queryProc
        command: ["brightnessctl", "-m", "g"]
        running: true
        stdout: SplitParser { onRead: data => root._parse(data) }
    }

    Process {
        id: setProc
        stdout: SplitParser { onRead: data => root._parse(data) }
    }

    function _parse(line) {
        const parts = line.trim().split(",")
        if (parts.length >= 4) {
            const pct = parseInt(parts[3].replace("%", ""))
            if (!isNaN(pct)) root.percent = pct
        }
    }

    function _set(arg) {
        setProc.command = ["brightnessctl", "-m", "set", arg]
        setProc.running = true
    }

    function increase() { _set(root.step + "%+"); ShellState.flashPage("brightness") }
    function decrease() { _set(root.step + "%-"); ShellState.flashPage("brightness") }
    function setPercent(pct) { _set(pct + "%") }

    IpcHandler {
        target: "brightness"
        function increase() { root.increase() }
        function decrease() { root.decrease() }
    }
}