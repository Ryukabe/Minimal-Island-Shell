// features/network/WifiService.qml
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
    property bool _pendingUsedPassword: false

    // Names of saved Wi-Fi profiles (nmcli names them after the SSID).
    property var savedProfiles: []
    // Set when connecting to a saved network failed because NetworkManager had no usable
    // password for it. WifiSubView watches this and opens the password sheet.
    property bool needsPassword: false
    property string needsPasswordSsid: ""

    function isSaved(ssid) {
        return root.savedProfiles.indexOf(ssid) !== -1
    }

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

    // Saved Wi-Fi profiles (so a known network reconnects without asking for a password again)
    Process {
        id: savedProc
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        property var _lines: []
        stdout: SplitParser { onRead: data => savedProc._lines.push(data) }
        onExited: (code, status) => {
            if (code === 0) root._parseSaved(savedProc._lines)
            savedProc._lines = []
        }
    }

    Process { id: radioToggleProc }
    Process { id: cleanupProc; onExited: root.refreshSaved() }
    Process { id: forgetProc; onExited: root.refreshSaved() }
    Process { id: disconnectProc }

    Process {
        id: connectProc
        property var _stderrLines: []
        stderr: SplitParser { onRead: data => connectProc._stderrLines.push(data) }
        onExited: (code, status) => {
            const message = connectProc._stderrLines.join(" ").replace(/^\s*Error:\s*/, "").trim()
            // NetworkManager words a rejected/wrong password and a missing saved password
            // the same way, so both land here.
            const secretsProblem = /secrets were required|no secrets|password.*(required|invalid)/i.test(message)
            const ssid = root._pendingConnectSsid

            if (code === 0) {
                root.lastError = ""
                root.needsPassword = false
            } else if (!root._pendingUsedPassword) {
                // Reconnect attempt without a typed password: never delete the saved
                // profile here - the failure may be temporary (out of range, etc).
                if (secretsProblem) {
                    root.lastError = ""
                    root.needsPasswordSsid = ssid
                    root.needsPassword = true
                } else {
                    root.lastError = message.length > 0 ? message : ("Couldn't connect to " + ssid)
                }
            } else {
                root.lastError = secretsProblem
                    ? "Wrong password for " + ssid + " - check it and try again."
                    : (message.length > 0 ? message : ("Couldn't connect to " + ssid))
                // Remove only the profile this attempt just created, so a bad password
                // doesn't linger and get reused on the next try.
                cleanupProc.command = ["nmcli", "connection", "delete", "id", ssid]
                cleanupProc.running = true
            }
            root.connecting = false
            connectProc._stderrLines = []
            root.refreshSaved()
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
            root.refreshSaved()
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
        root.refreshSaved()
    }

    function refresh() {
        if (!radioProc.running) radioProc.running = true
        if (!statusProc.running) statusProc.running = true
    }

    function refreshSaved() {
        if (!savedProc.running) savedProc.running = true
    }

    function _parseSaved(lines) {
        const names = []
        for (const raw of lines) {
            if (!raw || !raw.trim()) continue
            const f = root._splitTerse(raw)
            if (f.length >= 2 && f[1].trim() === "802-11-wireless") names.push(f[0])
        }
        root.savedProfiles = names
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

    // password empty  -> reconnect: saved profile if there is one, otherwise an open network
    // password typed  -> any old profile with this name is replaced, so the new password is
    //                    really used (nmcli would otherwise silently reuse the old secrets).
    // ssid/password go to sh as positional args, never spliced into the command string.
    function connectToNetwork(ssid, password) {
        root.lastError = ""
        root.needsPassword = false
        root.connecting = true
        root._pendingConnectSsid = ssid
        root._pendingUsedPassword = !!(password && password.length > 0)
        connectProc._stderrLines = []
        if (root._pendingUsedPassword) {
            connectProc.command = ["sh", "-c",
                "nmcli connection delete id \"$1\" >/dev/null 2>&1; exec nmcli device wifi connect \"$1\" password \"$2\" ifname \"$3\"",
                "sh", ssid, password, root.device]
        } else if (root.isSaved(ssid)) {
            connectProc.command = ["nmcli", "connection", "up", "id", ssid, "ifname", root.device]
        } else {
            connectProc.command = ["nmcli", "device", "wifi", "connect", ssid, "ifname", root.device]
        }
        connectProc.running = true
        verifyTimer.restart()
    }

    function clearError() {
        root.lastError = ""
        root.needsPassword = false
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
        forgetProc.command = ["nmcli", "connection", "delete", "id", ssid]
        forgetProc.running = true
        if (ssid === root.ssid) {
            root.ssid = ""
            root.hasInternet = false
        }
        verifyTimer.restart()
    }
}