// services/AutostartService.qml — manages the "-- Applications" section
// inside ~/.config/hypr/modules/autostart.lua. Only ever reads/writes
// exec_cmd lines that fall under that specific comment header — System
// tools / Clipboard Management sections (and the hl.on(...) wrapper
// itself) are never touched, so this can't accidentally remove something
// the shell depends on to start at all (quickshell, awww-daemon, etc).
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string autostartPath: "~/.config/hypr/modules/autostart.lua"

    property string rawText: ""
    property var apps: []   // [{ command }] — Applications-section entries only
    property bool loaded: false

    function refresh() { readProc.running = true }

    Process {
        id: readProc
        command: ["sh", "-c", "cat " + root.autostartPath]
        stdout: StdioCollector {
            onStreamFinished: {
                root.rawText = text
                root._parse()
                root.loaded = true
            }
        }
    }

    Process { id: reloadProc }
    Process { id: writeProc }
    Process { id: launchProc }

    function _bodyBounds(t) {
        let key = 'hl.on("hyprland.start", function()'
        let start = t.indexOf(key)
        if (start === -1) return null
        let bodyStart = start + key.length
        let end = t.indexOf("\nend)", bodyStart)
        if (end === -1) return null
        return { bodyStart, end }
    }

    function _parse() {
        let t = root.rawText
        let b = root._bodyBounds(t)
        if (!b) { root.apps = []; return }
        let lines = t.substring(b.bodyStart, b.end).split("\n")
        let currentSection = ""
        let result = []
        for (let line of lines) {
            let trimmed = line.trim()
            if (trimmed.startsWith("--")) {
                currentSection = trimmed.replace(/^--\s*/, "")
                continue
            }
            let m = trimmed.match(/hl\.exec_cmd\("([^"]*)"\)/)
            if (m && currentSection === "Applications") {
                result.push({ command: m[1] })
            }
        }
        root.apps = result
    }

    // Adds a new line under the "-- Applications" header, and launches it
    // immediately too (so the app opens right away rather than only on
    // the next boot).
    function addApp(command) {
        let t = root.rawText
        let b = root._bodyBounds(t)
        if (!b) return
        let lines = t.substring(b.bodyStart, b.end).split("\n")
        let insertAfter = -1
        let inApplications = false
        for (let i = 0; i < lines.length; i++) {
            let trimmed = lines[i].trim()
            if (trimmed.startsWith("--")) {
                inApplications = trimmed.replace(/^--\s*/, "") === "Applications"
                if (inApplications) insertAfter = i
                continue
            }
            if (inApplications && trimmed.length > 0) insertAfter = i
        }
        if (insertAfter === -1) return
        lines.splice(insertAfter + 1, 0, "    hl.exec_cmd(\"" + command.replace(/"/g, '\\"') + "\")")
        root._write(t.substring(0, b.bodyStart) + lines.join("\n") + t.substring(b.end))

        launchProc.command = ["sh", "-c", command]
        launchProc.running = true
    }

    function removeApp(command) {
        let t = root.rawText
        let b = root._bodyBounds(t)
        if (!b) return
        let lines = t.substring(b.bodyStart, b.end).split("\n")
        let currentSection = ""
        let removeIndex = -1
        for (let i = 0; i < lines.length; i++) {
            let trimmed = lines[i].trim()
            if (trimmed.startsWith("--")) {
                currentSection = trimmed.replace(/^--\s*/, "")
                continue
            }
            let m = trimmed.match(/hl\.exec_cmd\("([^"]*)"\)/)
            if (m && currentSection === "Applications" && m[1] === command) {
                removeIndex = i
                break
            }
        }
        if (removeIndex === -1) return
        lines.splice(removeIndex, 1)
        root._write(t.substring(0, b.bodyStart) + lines.join("\n") + t.substring(b.end))
    }

    function _write(newText) {
        let marker = "QS_AUTOSTART_EOF_" + Date.now()
        writeProc.command = ["sh", "-c",
            "cat > " + root.autostartPath + " << '" + marker + "'\n" + newText + "\n" + marker]
        writeProc.running = true
        reloadProc.command = ["hyprctl", "reload"]
        reloadProc.running = true
        root.rawText = newText
        root._parse()
    }

    Component.onCompleted: refresh()
}