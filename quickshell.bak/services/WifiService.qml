// services/WifiService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    readonly property string device: "wlan0"
    property bool enabled: false
    property bool adapterMissing: false
    property string ssid: ""
    property bool hasInternet: false
    property var networks: []
    property bool scanning: false
    property bool connecting: false
    property string lastError: ""
    property string _pendingConnectSsid: ""

    // Radio power state (nmcli's equivalent of iwctl's "Powered on/off")
    Process {
        id: radioProc
        command: ["nmcli", "radio", "wifi"]
        stdout: SplitParser { onRead: data => root._parseRadioLine(data) }
    }

    // Connection state for this specific device: state word + active profile name.
    // A non-zero exit here (rather than a parseable "not found" message, since
    // nmcli's wording for this varies by version) is treated as "no adapter" -
    // it also fires for other rare failures (NM not running at all), but those
    // are out of scope for now.
    Process {
        id: statusProc
        command: ["nmcli", "-t", "-f", "GENERAL.STATE,GENERAL.CONNECTION", "device", "show", root.device]
        property var _lines: []
        stdout: SplitParser { onRead: data => statusProc._lines.push(data) }
        onExited: (code, status) => {
            if (code !== 0) {
                root.adapterMissing = true
                root.ssid = ""
                root.hasInternet = false
            } else {
                root.adapterMissing = false
                root._parseStatusLines(statusProc._lines)
            }
            statusProc._lines = []
        }
    }

    Process {
        id: pingProc
        command: ["ping", "-c", "1", "-W", "1", "1.1.1.1"]
        onExited: (code, status) => {
            root.hasInternet = (code === 0)
        }
    }

    Process { id: radioToggleProc }
    Process { id: cleanupProc }
    Process { id: forgetProc }
    Process { id: disconnectProc }

    Process {
        id: connectProc
        property var _stderrLines: []
        stderr: SplitParser { onRead: data => connectProc._stderrLines.push(data) }
        onExited: (code, status) => {
            root.connecting = false
            if (code === 0) {
                root.lastError = ""
            } else {
                const message = connectProc._stderrLines.join(" ").trim()
                root.lastError = message.length > 0 ? message : ("Couldn't connect to " + root._pendingConnectSsid)
                // nmcli reuses an existing saved profile's secrets rather than
                // applying a newly-typed password to it if a profile with this
                // name already exists - delete it so the next attempt starts clean.
                cleanupProc.command = ["nmcli", "connection", "delete", root._pendingConnectSsid]
                cleanupProc.running = true
            }
            connectProc._stderrLines = []
            root.refresh()
        }
    }

    // Asks NetworkManager to kick off a fresh AP scan
    Process {
        id: triggerScanProc
        command: ["nmcli", "device", "wifi", "rescan", "ifname", root.device]
        onExited: (code, status) => {
            scanDelayTimer.restart()
        }
    }

    // Gives NM a short window to populate scan results before we ask for the list
    Timer {
        id: scanDelayTimer
        interval: 1200
        repeat: false
        onTriggered: {
            scanListProc._lines = []
            scanListProc.running = true
        }
    }

    Process {
        id: scanListProc
        command: ["nmcli", "-t", "-f", "SSID,SECURITY,SIGNAL", "device", "wifi", "list", "ifname", root.device]
        property var _lines: []
        stdout: SplitParser {
            onRead: data => scanListProc._lines.push(data)
        }
        onExited: (code, status) => {
            root._parseNetworksOutput(scanListProc._lines)
            scanListProc._lines = []
            root.scanning = false
        }
    }

    Timer {
        id: pollTimer
        interval: 3000
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

    Component.onCompleted: {
        root.refresh()
    }

    function refresh() {
        if (!radioProc.running) radioProc.running = true
        if (!statusProc.running) statusProc.running = true
    }

    function scanNetworks() {
        if (!root.enabled || triggerScanProc.running || scanListProc.running) return
        root.scanning = true
        triggerScanProc.running = true
    }

    function _parseRadioLine(line) {
        if (!line) return
        root.enabled = line.trim().toLowerCase() === "enabled"
    }

    function _parseStatusLines(lines) {
        let stateWord = ""
        let connectionName = ""
        for (const raw of lines) {
            if (!raw) continue
            const stateMatch = raw.match(/^GENERAL\.STATE:\s*\d+\s*\(([^)]+)\)/)
            if (stateMatch) {
                stateWord = stateMatch[1].toLowerCase()
                continue
            }
            const connMatch = raw.match(/^GENERAL\.CONNECTION:(.*)$/)
            if (connMatch) {
                connectionName = connMatch[1].trim()
            }
        }
        if (stateWord === "connected" && connectionName !== "" && connectionName !== "--") {
            root.ssid = connectionName
            if (!pingProc.running) pingProc.running = true
        } else {
            root.ssid = ""
            root.hasInternet = false
        }
    }

    // nmcli's terse mode (-t) escapes ':' and '\' inside field values with a
    // leading backslash, so a plain split(":") would corrupt any SSID that
    // happens to contain a colon. This walks the string respecting escapes.
    function _splitTerse(line) {
        const fields = []
        let current = ""
        for (let i = 0; i < line.length; i++) {
            const ch = line[i]
            if (ch === "\\" && i + 1 < line.length) {
                current += line[i + 1]
                i++
            } else if (ch === ":") {
                fields.push(current)
                current = ""
            } else {
                current += ch
            }
        }
        fields.push(current)
        return fields
    }

    function _signalBarsFromPercent(percent) {
        const num = parseInt(percent, 10)
        if (isNaN(num)) return 2
        if (num >= 75) return 4
        if (num >= 50) return 3
        if (num >= 25) return 2
        return 1
    }

    function _parseNetworksOutput(lines) {
        const parsed = []
        for (const raw of lines) {
            if (!raw || !raw.trim()) continue
            const fields = root._splitTerse(raw)
            if (fields.length < 3) continue
            const ssid = fields[0].trim()
            if (!ssid) continue
            const security = fields[1].trim()
            const signal = fields[2].trim()
            parsed.push({
                ssid: ssid,
                secured: security !== "" && security !== "--",
                signalBars: root._signalBarsFromPercent(signal)
            })
        }
        const seen = {}
        root.networks = parsed.filter(n => {
            if (seen[n.ssid]) return false
            seen[n.ssid] = true
            return true
        })
    }

    function toggle() {
        const newState = root.enabled ? "off" : "on"
        radioToggleProc.command = ["nmcli", "radio", "wifi", newState]
        radioToggleProc.running = true

        root.enabled = !root.enabled
        if (!root.enabled) {
            root.ssid = ""
            root.hasInternet = false
            root.networks = []
        } else {
            scanNetworks()
        }
        verifyTimer.restart()
    }

    function connectToNetwork(ssid, password) {
        root.lastError = ""
        root.connecting = true
        root._pendingConnectSsid = ssid
        connectProc._stderrLines = []
        if (password && password.length > 0) {
            connectProc.command = ["nmcli", "device", "wifi", "connect", ssid, "password", password, "ifname", root.device]
        } else {
            connectProc.command = ["nmcli", "device", "wifi", "connect", ssid, "ifname", root.device]
        }
        connectProc.running = true
        verifyTimer.restart()
    }

    function clearError() {
        root.lastError = ""
    }

    function disconnect() {
        disconnectProc.command = ["nmcli", "device", "disconnect", root.device]
        disconnectProc.running = true
        root.ssid = ""
        root.hasInternet = false
        verifyTimer.restart()
    }

    function forgetNetwork(ssid) {
        if (!ssid) return
        forgetProc.command = ["nmcli", "connection", "delete", ssid]
        forgetProc.running = true
        if (ssid === root.ssid) {
            root.ssid = ""
            root.hasInternet = false
        }
        verifyTimer.restart()
    }
}