// features/network/BluetoothService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../../core/shell"

Singleton {
    id: root
    property bool enabled: false
    // "Visible to nearby devices". Read from BlueZ (bluetoothctl show), never stored: BlueZ switches it
    // off again by itself after its own timeout.
    property bool discoverable: false
    property string statusText: "Off"
    property var connectedDevices: []
    property var availableDevices: []
    // mac -> charge in percent, for connected devices that report one. Only filled while
    // Settings > Bluetooth > "Show battery level" is on. Always reassigned, never mutated.
    property var batteryLevels: ({})

    property var _deviceNames: ({})   // mac -> name, from `bluetoothctl devices`
    property var _connectedMacs: ({}) // mac -> true, from `bluetoothctl devices Connected`
    property string _connectedKey: "" // connected macs joined, to notice when the set changes
    property var _batteryQueue: []
    property bool _startupReady: false

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

    // One `bluetoothctl info <mac>` at a time, walking _batteryQueue. Devices that do not report
    // a charge simply never get an entry in batteryLevels.
    Process {
        id: batteryProc
        property string mac: ""
        stdout: SplitParser { onRead: data => root._parseBatteryLine(batteryProc.mac, data) }
        onExited: Qt.callLater(root._nextBattery)
    }

    Process {
        id: toggleProc
    }

    Process {
        id: discoverProc
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

    // Charge levels change slowly, so they are re-read once a minute (and whenever the set of
    // connected devices changes), and only while someone has the setting on.
    Timer {
        id: batteryTimer
        interval: 60000
        repeat: true
        running: ShellState.bluetoothShowBattery && root.enabled && root.connectedDevices.length > 0
        onTriggered: root._pollBattery()
    }

    // Waits a few seconds after the shell starts so the saved settings are loaded and BlueZ has
    // answered, then reconnects the last device (if asked to) and starts remembering it.
    Timer {
        id: startupTimer
        interval: 4000
        running: true
        repeat: false
        onTriggered: {
            root._startupReady = true
            root._startupReconnect()
            root._trackLastDevice()
        }
    }

    Connections {
        target: ShellState
        function onBluetoothShowBatteryChanged() {
            if (ShellState.bluetoothShowBattery) root._pollBattery()
            else root.batteryLevels = ({})
        }
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
            root.discoverable = false
            root.availableDevices = []
            root.connectedDevices = []
            root.batteryLevels = ({})
        }

        // Matches "Discoverable: yes|no" only, not the "DiscoverableTimeout:" line
        const disc = line.match(/^\s*Discoverable:\s+(yes|no)/i)
        if (disc) root.discoverable = disc[1].toLowerCase() === "yes"
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

        // Forget charge levels of devices that are no longer connected
        const kept = {}
        for (const d of connected) {
            if (root.batteryLevels[d.mac] !== undefined) kept[d.mac] = root.batteryLevels[d.mac]
        }
        if (JSON.stringify(kept) !== JSON.stringify(root.batteryLevels)) root.batteryLevels = kept

        // A different set of connected devices: read their charge now instead of waiting a minute
        const key = connected.map(d => d.mac).sort().join(",")
        if (key !== root._connectedKey) {
            root._connectedKey = key
            root._pollBattery()
        }

        root._trackLastDevice()
    }

    // ---- Battery ----
    function _pollBattery() {
        if (!ShellState.bluetoothShowBattery || !root.enabled) return
        if (batteryProc.running || root._batteryQueue.length > 0) return   // a pass is already underway
        root._batteryQueue = root.connectedDevices.map(d => d.mac)
        root._nextBattery()
    }

    function _nextBattery() {
        if (root._batteryQueue.length === 0 || batteryProc.running) return
        const queue = root._batteryQueue.slice()
        const mac = queue.shift()
        root._batteryQueue = queue
        batteryProc.mac = mac
        batteryProc.command = ["bluetoothctl", "info", mac]
        batteryProc.running = true
    }

    function _parseBatteryLine(mac, line) {
        // e.g. "Battery Percentage: 0x64 (100)"
        const match = line.match(/Battery Percentage:\s+0x[0-9a-fA-F]+\s+\((\d+)\)/)
        if (!match) return
        const next = Object.assign({}, root.batteryLevels)
        next[mac] = parseInt(match[1], 10)
        root.batteryLevels = next
    }

    // ---- Last device / reconnect at startup ----
    // The "last device" is kept as long as it is among the connected ones; if it is not and another
    // device is connected, that one becomes the last device. Disconnecting never clears it.
    function _trackLastDevice() {
        if (!root._startupReady || root.connectedDevices.length === 0) return
        const last = ShellState.bluetoothLastDevice
        if (root.connectedDevices.some(d => d.mac === last)) return
        ShellState.bluetoothLastDevice = root.connectedDevices[0].mac
    }

    function _startupReconnect() {
        if (!ShellState.bluetoothReconnectAtStartup) return
        const mac = ShellState.bluetoothLastDevice
        if (mac === "" || !root.enabled) return
        if (root._connectedMacs[mac]) return
        root.connectDevice(mac)
    }

    // ---- Actions ----
    function setPower(on) {
        toggleProc.command = ["bluetoothctl", "power", on ? "on" : "off"]
        toggleProc.running = true

        root.enabled = on
        root.statusText = on ? "On" : "Off"
        if (!on) {
            root.discoverable = false
            root.availableDevices = []
            root.connectedDevices = []
            root.batteryLevels = ({})
        }
        verifyTimer.restart()
    }

    function toggle() {
        root.setPower(!root.enabled)
    }

    function setDiscoverable(on) {
        if (!root.enabled) return
        discoverProc.command = ["bluetoothctl", "discoverable", on ? "on" : "off"]
        discoverProc.running = true
        root.discoverable = on
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
