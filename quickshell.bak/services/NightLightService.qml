pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Color temperature in Kelvin when night light is on.
    // 4000K is a fairly standard warm value — tell me if you want this
    // different, or a temperature slider added instead of a fixed value.
    property int temperature: 4000

    property bool enabled: false

    Process {
        id: sunsetProc
        command: ["hyprsunset", "-t", String(root.temperature)]

        onRunningChanged: {
            root.enabled = running
        }

        onExited: (exitCode, exitStatus) => {
            // Process ended (crashed, killed externally, or we stopped it) —
            // reflect that honestly rather than assuming it's still "on".
            root.enabled = false
        }
    }

    // Safety-net poll — catches cases where hyprsunset dies outside our
    // control (e.g. `pkill hyprsunset` run manually) and Process.running
    // doesn't update on its own for an already-dead child.
    Process {
        id: pgrepProc
        command: ["pgrep", "-x", "hyprsunset"]
        stdout: SplitParser {
            onRead: data => {
                // any output means it's alive
                if (!sunsetProc.running && data.trim() !== "") {
                    root.enabled = true
                }
            }
        }
        onExited: (exitCode) => {
            if (exitCode !== 0 && !sunsetProc.running) {
                root.enabled = false
            }
        }
    }

    Timer {
        id: pollTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: pgrepProc.running = true
    }

    function toggle() {
        if (root.enabled) {
            sunsetProc.running = false
        } else {
            sunsetProc.running = true
        }
    }
}