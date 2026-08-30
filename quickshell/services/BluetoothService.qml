pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property bool enabled: false
    property string statusText: "Off"
    property var connectedDevices: []
    property var availableDevices: []

    property var _deviceNames: ({})   // mac -> name, from `bluetoothctl devices`
    property var _connectedMacs: ({}) // mac -> true, from `bluetoothctl devices Connected`

    Process {
        id: powerProc
        command: ["bluetoothctl", "show"]
        running: true
        stdout: SplitParser { onRead: data => root._parsePowerLine(data) }
    }

    Process {
        id: devicesProc
        command: ["bluetoothctl", "devices"]
        running: true
        property var _lines: []
        stdout: SplitParser { onRead: data => devicesProc._lines.push(data) }
        onExited: {
            root._deviceNames = root._parseDeviceLines(devicesProc._lines)
            devicesProc._lines = []
            root._rebuildLists()
        }
    }

    // Requires BlueZ/bluetoothctl 5.65+ for the "devices Connected" filter.
    // If your version doesn't support it, this returns nothing and
    // connectedDevices stays empty — tell me and I'll switch to a
    // per-device `bluetoothctl info <mac>` fallback instead.
    Process {
        id: connectedProc
        command: ["bluetoothctl", "devices", "Connected"]
        running: true
        property var _lines: []
        stdout: SplitParser { onRead: data => connectedProc._lines.push(data) }
        onExited: {
            root._connectedMacs = root._parseConnectedLines(connectedProc._lines)
            connectedProc._lines = []
            root._rebuildLists()
        }
    }

    Process {
        id: toggleProc
    }

    Process {
        id: actionProc
    }

    Timer {
        id: pollTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Timer {
        id: verifyTimer
        interval: 800
        repeat: false
        onTriggered: root.refresh()
    }

    function refresh() {
        powerProc.running = true
        if (root.enabled) {
            if (!devicesProc.running) devicesProc.running = true
            if (!connectedProc.running) connectedProc.running = true
        }
    }

    function _parsePowerLine(line) {
        if (line.match(/Powered:\s+yes/i)) {
            root.enabled = true
            root.statusText = "On"
        } else if (line.match(/Powered:\s+no/i)) {
            root.enabled = false
            root.statusText = "Off"
            root.availableDevices = []
            root.connectedDevices = []
        }
    }

    function _parseDeviceLines(lines) {
        const names = {}
        for (const line of lines) {
            const match = line.match(/^Device\s+([0-9A-Fa-f_:]+)\s+(.+)$/)
            if (match) {
                names[match[1]] = match[2]
            }
        }
        return names
    }

    function _parseConnectedLines(lines) {
        const macs = {}
        for (const line of lines) {
            const match = line.match(/^Device\s+([0-9A-Fa-f_:]+)\s+(.+)$/)
            if (match) {
                macs[match[1]] = true
            }
        }
        return macs
    }

    function _rebuildLists() {
        const connected = []
        const available = []
        for (const mac in root._deviceNames) {
            const entry = { mac: mac, name: root._deviceNames[mac], connected: !!root._connectedMacs[mac] }
            if (entry.connected) {
                connected.push(entry)
            } else {
                available.push(entry)
            }
        }
        root.connectedDevices = connected
        root.availableDevices = available
    }

    function toggle() {
        const newState = root.enabled ? "off" : "on"
        toggleProc.command = ["bluetoothctl", "power", newState]
        toggleProc.running = true

        root.enabled = !root.enabled
        root.statusText = root.enabled ? "On" : "Off"
        if (!root.enabled) {
            root.availableDevices = []
            root.connectedDevices = []
        }
        verifyTimer.restart()
    }

    function connectDevice(mac) {
        actionProc.command = ["bluetoothctl", "connect", mac]
        actionProc.running = true
        verifyTimer.restart()
    }

    function disconnectDevice(mac) {
        actionProc.command = ["bluetoothctl", "disconnect", mac]
        actionProc.running = true
        verifyTimer.restart()
    }
}