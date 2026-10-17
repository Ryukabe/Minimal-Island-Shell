// features/apps/AutostartService.qml — manages the "-- Applications" section
// inside ~/.config/hypr/modules/autostart.lua. Only ever reads/writes
// exec_cmd lines that fall under that specific comment header — System
// tools / Clipboard management sections (and the hl.on(...) wrapper
// itself) are never touched, so this can't accidentally remove something
// the shell depends on to start at all (quickshell, awww-daemon, etc).
//
// Parsing rules:
//   - A line starting with "--" that does NOT contain exec_cmd is a section header.
//   - A commented-out exec_cmd line ("-- hl.exec_cmd(...)") is not a header and not an entry.
//   - A plain note comment inside the Applications section still ends that section (entries
//     below it would be hidden, never mis-deleted), so keep notes above the header.
//   - Entries are Lua string literals; \" and \\ are escaped on write and unescaped on read.
//
// Writes go to a temp file that is then renamed over the real file (through any symlink, so a
// dotfiles-repo link survives). Nothing is reloaded: the hl.on("hyprland.start") block only
// runs at login.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string autostartPath: "$HOME/.config/hypr/modules/autostart.lua"
    readonly property string sectionName: "Applications"

    property string rawText: ""
    property var apps: []   // [{ command }] — Applications-section entries only
    property bool loaded: false
    property string lastError: ""   // set when add/remove/read/write fails; cleared on the next success

    function refresh() { readProc.running = true }

    Process {
        id: readProc
        command: ["sh", "-c", "cat \"" + root.autostartPath + "\""]
        stdout: StdioCollector {
            onStreamFinished: {
                root.rawText = text
                root._parse()
                root.loaded = true
            }
        }
    }

    // ---- Writing: one at a time, latest text wins, atomic replace ----
    property string _pendingText: ""
    property bool _hasPending: false

    Process {
        id: writeProc
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) console.log("[AutostartService] write failed:", text.trim())
            }
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.lastError = "Couldn't save autostart.lua"
                root.refresh()   // show what is really on disk
            }
            root._flush()
        }
    }

    function _flush() {
        if (!root._hasPending) return
        let text = root._pendingText
        root._hasPending = false
        // $1 = new file text. readlink -f keeps a symlinked file linked; the temp file sits next to the real one.
        writeProc.command = ["sh", "-c",
            't=$(readlink -f "' + root.autostartPath + '") && tmp="$t.tmp.$$" && printf "%s" "$1" > "$tmp" && mv "$tmp" "$t"',
            "sh", text]
        writeProc.running = true
    }

    function _write(newText) {
        // Never write something that lost the block the whole file depends on
        if (!root._bodyBounds(newText)) {
            root.lastError = "Refused to write: hyprland.start block not found"
            return false
        }
        root.rawText = newText
        root._parse()
        root._pendingText = newText
        root._hasPending = true
        if (!writeProc.running) root._flush()
        return true
    }

    // ---- Launching: detached from Quickshell so the app survives a shell switch/restart ----
    Component {
        id: launchComp
        Process {
            id: launchProc
            onExited: launchProc.destroy()
        }
    }

    function _launch(command) {
        launchComp.createObject(root, {
            command: ["sh", "-c", 'setsid -f sh -c "$1" >/dev/null 2>&1 </dev/null', "sh", command],
            running: true
        })
    }

    // ---- Parsing ----
    function _escape(s) { return s.replace(/\\/g, "\\\\").replace(/"/g, '\\"') }
    function _unescape(s) { return s.replace(/\\(["\\])/g, "$1") }

    function _bodyBounds(t) {
        let key = 'hl.on("hyprland.start", function()'
        let start = t.indexOf(key)
        if (start === -1) return null
        let bodyStart = start + key.length
        let end = t.indexOf("\nend)", bodyStart)
        if (end === -1) return null
        return { bodyStart, end }
    }

    // Walks the body lines once: Applications entries, the header line, and the last line of the section.
    function _scan(lines) {
        let section = ""
        let entries = []
        let headerIndex = -1
        let lastIndex = -1
        for (let i = 0; i < lines.length; i++) {
            let trimmed = lines[i].trim()
            if (trimmed.startsWith("--") && trimmed.indexOf("exec_cmd") === -1) {
                section = trimmed.replace(/^--\s*/, "")
                if (section === root.sectionName) { headerIndex = i; lastIndex = i }
                continue
            }
            if (section !== root.sectionName) continue
            if (trimmed.length > 0) lastIndex = i
            let m = trimmed.match(/^hl\.exec_cmd\("((?:[^"\\]|\\.)*)"\)\s*(?:--.*)?$/)
            if (m) entries.push({ index: i, command: root._unescape(m[1]) })
        }
        return { entries, headerIndex, lastIndex }
    }

    function _parse() {
        let t = root.rawText
        let b = root._bodyBounds(t)
        if (!b) {
            root.apps = []
            root.lastError = "Couldn't find the hyprland.start block in autostart.lua"
            return
        }
        let scan = root._scan(t.substring(b.bodyStart, b.end).split("\n"))
        root.apps = scan.entries.map(e => ({ command: e.command }))
    }

    function _fail(message) {
        root.lastError = message
        return false
    }

    // Adds a line under "-- Applications" (creating the header if it is missing) and launches it
    // right away, so the app opens now rather than only on the next login. Returns true on success.
    function addApp(rawCommand) {
        let command = String(rawCommand === undefined || rawCommand === null ? "" : rawCommand).trim()
        if (command.length === 0) return root._fail("Type a command first")
        if (command.indexOf("\n") !== -1) return root._fail("A command has to fit on one line")

        let t = root.rawText
        let b = root._bodyBounds(t)
        if (!b) return root._fail("Couldn't find the hyprland.start block in autostart.lua")

        let lines = t.substring(b.bodyStart, b.end).split("\n")
        let scan = root._scan(lines)
        if (scan.entries.some(e => e.command === command)) return root._fail("Already in startup apps")

        let cr = t.indexOf("\r\n") !== -1 ? "\r" : ""
        let newLine = '    hl.exec_cmd("' + root._escape(command) + '")' + cr
        if (scan.headerIndex === -1) {
            lines.push(cr, "    -- " + root.sectionName + cr, newLine)
        } else {
            lines.splice(scan.lastIndex + 1, 0, newLine)
        }

        if (!root._write(t.substring(0, b.bodyStart) + lines.join("\n") + t.substring(b.end))) return false
        root.lastError = ""
        root._launch(command)
        return true
    }

    function removeApp(command) {
        let t = root.rawText
        let b = root._bodyBounds(t)
        if (!b) return root._fail("Couldn't find the hyprland.start block in autostart.lua")

        let lines = t.substring(b.bodyStart, b.end).split("\n")
        let hit = root._scan(lines).entries.find(e => e.command === command)
        if (!hit) return root._fail("That entry is no longer in the file")

        lines.splice(hit.index, 1)
        if (!root._write(t.substring(0, b.bodyStart) + lines.join("\n") + t.substring(b.end))) return false
        root.lastError = ""
        return true
    }

    Component.onCompleted: refresh()
}
