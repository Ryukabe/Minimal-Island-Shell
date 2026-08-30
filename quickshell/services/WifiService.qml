pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    readonly property string device: "wlan0"
    property bool enabled: false
    property string ssid: ""
    property bool hasInternet: false
    property var networks: []
    property bool scanning: false

    Process {
        id: deviceProc
        command: ["iwctl", "device", root.device, "show"]
        stdout: SplitParser { onRead: data => root._parseDeviceLine(data) }
    }

    Process {
        id: stationProc
        command: ["iwctl", "station", root.device, "show"]
        stdout: SplitParser { onRead: data => root._parseStationLine(data) }
    }

    Process {
        id: pingProc
        command: ["ping", "-c", "1", "-W", "1", "1.1.1.1"]
        onExited: (code, status) => {
            root.hasInternet = (code === 0)
        }
    }

    Process {
        id: toggleProc
    }

    Process {
        id: connectProc
    }

    Process {
        id: scanProc
        command: ["iwctl", "station", root.device, "get-networks"]
        property var _lines: []
        stdout: SplitParser {
            onRead: data => scanProc._lines.push(data)
        }
        onExited: (code, status) => {
            root._parseNetworksOutput(scanProc._lines)
            scanProc._lines = []
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
        if (!deviceProc.running) deviceProc.running = true
        if (!stationProc.running) stationProc.running = true
        if (root.enabled && !pingProc.running) pingProc.running = true
    }

    function scanNetworks() {
        if (!root.enabled || scanProc.running) return
        root.scanning = true
        scanProc._lines = []
        scanProc.running = true
    }

    function _parseDeviceLine(line) {
        const m = line.match(/Powered\s+(on|off)/i)
        if (m) {
            root.enabled = m[1].toLowerCase() === "on"
        }
    }

    function _parseStationLine(line) {
        const netMatch = line.match(/^\s*Connected network\s+(.+)/i)
        if (netMatch) {
            root.ssid = netMatch[1].trim()
            if (!pingProc.running) pingProc.running = true
            return
        }
        const stateMatch = line.match(/^\s*State\s+(\S+)/i)
        if (stateMatch && stateMatch[1].toLowerCase() !== "connected") {
            root.ssid = ""
            root.hasInternet = false
        }
    }

    // Converts iwctl's strength token into a 0-4 bar count. iwctl's
    // traditional format is asterisks ("*" through "****"). If your
    // iwd version prints something else (percentage, dBm), this falls
    // back to a medium default rather than crash — tell me the raw
    // output if that happens and this gets adjusted to match it.
    function _signalBarsFromToken(token) {
        if (/^\*+$/.test(token)) {
            return Math.min(4, token.length)
        }
        const num = parseInt(token, 10)
        if (!isNaN(num)) {
            if (num >= 75) return 4
            if (num >= 50) return 3
            if (num >= 25) return 2
            return 1
        }
        return 2 // unknown format — medium default, not a guess dressed as certainty
    }

    // NOTE: iwctl's "get-networks" table format can vary between iwd
    // versions. This expects lines shaped like:
    //   NetworkName        psk        ****
    //   OpenNetwork         open       ***
    // and skips header/separator lines. If nothing shows up, paste the raw
    // output of `iwctl station wlan0 get-networks` and this regex gets tuned
    // to match — don't assume this is right without testing it live.
    function _parseNetworksOutput(lines) {
        const parsed = []
        for (const raw of lines) {
            const line = raw.replace(/\x1b\[[0-9;]*m/g, "") // strip ANSI color codes
            if (!line.trim()) continue
            if (/^-+$/.test(line.trim())) continue
            if (/^\s*Network name/i.test(line)) continue
            if (/Available networks/i.test(line)) continue

            const m = line.match(/^\s*>?\s*(.+?)\s{2,}(open|psk|8021x|wep)\s+(\S+)\s*$/i)
            if (!m) continue

            parsed.push({
                ssid: m[1].trim(),
                secured: m[2].toLowerCase() !== "open",
                signalBars: root._signalBarsFromToken(m[3])
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
        toggleProc.command = ["iwctl", "device", root.device, "set-property", "Powered", newState]
        toggleProc.running = true

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
        if (password && password.length > 0) {
            connectProc.command = ["iwctl", "--passphrase", password, "station", root.device, "connect", ssid]
        } else {
            connectProc.command = ["iwctl", "station", root.device, "connect", ssid]
        }
        connectProc.running = true
        verifyTimer.restart()
    }
}