pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Slider range in Kelvin. 6500K is the neutral screen colour; lower is warmer.
    // maxTemperature is untested above 6500 — raise it only after checking.
    readonly property int minTemperature: 2500
    readonly property int maxTemperature: 6500
    readonly property int temperatureStep: 100

    // Warm value used when night light is on. Saved to state/nightlight.json.
    property int temperature: 4000

    // What is actually happening right now.
    property bool enabled: false

    // What the user last asked for. Saved, and restored at startup, until they turn it off.
    property bool wanted: false

    readonly property string _home: Quickshell.env("HOME")
    property bool _applyingConfig: false

    function _start() {
        sunsetProc.command = ["hyprsunset", "-t", String(root.temperature)]
        sunsetProc.running = true
    }

    function toggle() {
        if (root.enabled) {
            root.wanted = false
            saveTimer.restart()
            sunsetProc.running = false
            // Also covers a hyprsunset this shell did not start (survived a restart, or autostarted).
            killProc.running = true
        } else {
            root.wanted = true
            saveTimer.restart()
            root._start()
        }
    }

    function setTemperature(kelvin) {
        const snapped = Math.round(kelvin / root.temperatureStep) * root.temperatureStep
        const clamped = Math.max(root.minTemperature, Math.min(root.maxTemperature, snapped))
        if (clamped === root.temperature) return
        root.temperature = clamped
        // Live change only while hyprsunset is running; otherwise it is used on the next start.
        if (root.enabled) liveTimer.restart()
        saveTimer.restart()
    }

    Process {
        id: sunsetProc
        command: ["hyprsunset"]

        onRunningChanged: {
            root.enabled = running
        }

        onExited: (exitCode, exitStatus) => {
            // Process ended (crashed, killed externally, or we stopped it) —
            // reflect that honestly rather than assuming it's still "on".
            root.enabled = false
        }
    }

    Process {
        id: killProc
        command: ["pkill", "-x", "hyprsunset"]
    }

    // Changes the temperature of the running hyprsunset without restarting it.
    Process {
        id: liveProc
    }

    // Debounce so dragging the slider doesn't spawn a process per pixel.
    Timer {
        id: liveTimer
        interval: 80
        repeat: false
        onTriggered: {
            if (liveProc.running) {
                liveTimer.restart()
                return
            }
            liveProc.command = ["hyprctl", "hyprsunset", "temperature", String(root.temperature)]
            liveProc.running = true
        }
    }

    // Runs once after the saved settings load. If night light was left on, bring it back:
    // start hyprsunset, or, if one is already running, just sync it to the saved temperature.
    Process {
        id: startupProc
        command: ["pgrep", "-x", "hyprsunset"]
        onExited: (exitCode) => {
            if (!root.wanted) return
            if (exitCode === 0) {
                root.enabled = true
                liveTimer.restart()
            } else if (!sunsetProc.running) {
                root._start()
            }
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

    // ---- Persistence ----
    FileView {
        id: configFile
        path: root._home + "/.config/quickshell/state/nightlight.json"
        printErrors: false
        onLoaded: {
            root._applyingConfig = true
            try {
                const data = JSON.parse(text())
                if (typeof data.temperature === "number") {
                    root.temperature = Math.max(root.minTemperature, Math.min(root.maxTemperature, Math.round(data.temperature)))
                }
                if (typeof data.enabled === "boolean") root.wanted = data.enabled
            } catch (e) {
                console.warn("NightLightService: bad nightlight.json, ignoring", e)
            }
            root._applyingConfig = false
            if (root.wanted) startupProc.running = true
        }
    }

    Timer {
        id: saveTimer
        interval: 400
        repeat: false
        onTriggered: {
            if (root._applyingConfig) return
            configFile.setText(JSON.stringify({ temperature: root.temperature, enabled: root.wanted }, null, 2))
        }
    }
}