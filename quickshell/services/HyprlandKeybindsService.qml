// services/HyprlandKeybindsService.qml — parses ~/.config/hypr/modules/binds.lua
// and lets the Settings app rebind the key-combo portion of ANY hl.bind(...)
// call, including dispatcher-based ones, WITHOUT touching the action/options
// that follow it. New binds can only be added as exec_cmd (app/script/qs ipc)
// since dispatcher call syntax is too varied to safely generate from a UI.
// Multi-line binds are never auto-rewritten in structure — only flattened to
// one line on request, or have their key combo swapped.
//
// Friendly names: auto-detected for common dispatcher shapes; anything else
// (or any auto-name you don't like) can be manually overridden. Overrides are
// stored in a separate sidecar JSON file, written via base64 (avoids heredoc/
// quoting fragility) — binds.lua is read-only from this feature's perspective.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string bindsPath: "~/.config/hypr/modules/binds.lua"
    readonly property string labelsPath: "~/.config/quickshell/keybind-labels.json"
    readonly property string customMarker: "-- === Custom binds (added via Settings) ==="

    property string rawText: ""
    property var binds: []       // [{ id, keyDisplay, keyRaw, actionPreview, actionFull, actionKey, isCustom, isMultiline, keyStart, keyEnd, callStart, callEnd }]
    property var conflictCounts: ({})   // keyDisplay -> how many binds currently use it
    property var labelOverrides: ({})   // actionKey -> custom label string
    property bool loaded: false
    property bool labelsLoaded: false
    property string lastLabelSaveError: ""

    property string _mainMod: "SUPER"
    property string _subMod: "CTRL + ALT"

    function refresh() { readProc.running = true; readLabelsProc.running = true }

    Process {
        id: readProc
        command: ["sh", "-c", "cat " + root.bindsPath]
        stdout: StdioCollector {
            onStreamFinished: {
                root.rawText = text
                root._parse()
                root.loaded = true
            }
        }
    }

    Process {
        id: readLabelsProc
        command: ["sh", "-c", "cat " + root.labelsPath + " 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                let trimmed = text.trim()
                if (trimmed.length > 0) {
                    try { root.labelOverrides = JSON.parse(trimmed) }
                    catch (e) { root.labelOverrides = ({}) }
                }
                root.labelsLoaded = true
            }
        }
    }

    Process { id: reloadProc }
    Process { id: writeProc }

    Process {
        id: writeLabelsProc
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    root.lastLabelSaveError = text.trim()
                    console.log("[HyprlandKeybindsService] label save failed:", text.trim())
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.log("[HyprlandKeybindsService] label save process exited with code", exitCode)
            }
        }
    }

    // --- Parsing: bracket/string-aware so multi-line function() ... end
    // blocks and nested tables are treated as one statement, not split apart.
    function _parse() {
        let t = root.rawText
        let mm = t.match(/local\s+mainMod\s*=\s*"([^"]*)"/)
        let sm = t.match(/local\s+subMod\s*=\s*"([^"]*)"/)
        root._mainMod = mm ? mm[1] : "SUPER"
        root._subMod = sm ? sm[1] : "CTRL + ALT"

        let results = []
        let i = 0, id = 0

        while (true) {
            let callStart = t.indexOf("hl.bind(", i)
            if (callStart === -1) break

            let lineStart = t.lastIndexOf("\n", callStart) + 1
            if (t.substring(lineStart, callStart).indexOf("--") !== -1) {
                i = callStart + 8
                continue
            }

            let pos = callStart + 8, depth = 1, inString = false, stringChar = ""
            let keyExprEnd = -1

            while (pos < t.length && depth > 0) {
                let ch = t[pos]
                if (inString) {
                    if (ch === "\\") { pos += 2; continue }
                    if (ch === stringChar) inString = false
                } else if (ch === '"' || ch === "'") {
                    inString = true; stringChar = ch
                } else if (ch === "(") depth++
                else if (ch === ")") { depth--; if (depth === 0) break }
                else if (keyExprEnd === -1 && depth === 1 && ch === ",") {
                    keyExprEnd = pos
                }
                pos++
            }

            let callEnd = pos
            if (keyExprEnd === -1) { i = callEnd + 1; continue }

            let keyStart = callStart + 8
            let keyRaw = t.substring(keyStart, keyExprEnd).trim()
            let fullCall = t.substring(callStart, callEnd + 1)
            let actionFull = t.substring(keyExprEnd + 1, callEnd).trim().replace(/\s+/g, " ")
            let actionPreview = actionFull.length > 70 ? actionFull.substring(0, 70) + "…" : actionFull

            results.push({
                id: id++,
                keyRaw: keyRaw,
                keyDisplay: root._resolveKeyDisplay(keyRaw),
                actionPreview: actionPreview,
                actionFull: actionFull,
                actionKey: actionFull,   // stable-ish identifier for label overrides
                isCustom: false,
                isMultiline: fullCall.indexOf("\n") !== -1,
                keyStart: keyStart,
                keyEnd: keyExprEnd,
                callStart: callStart,
                callEnd: callEnd + 1
            })

            i = callEnd + 1
        }

        let markerPos = t.indexOf(root.customMarker)
        if (markerPos !== -1) {
            for (let r of results) r.isCustom = r.callStart > markerPos
        }

        root.binds = results
        root._buildConflicts()
    }

    function _resolveKeyDisplay(keyRaw) {
        let lit = keyRaw.match(/^"([^"]*)"$/)
        if (lit) return lit[1].trim().replace(/\s+/g, " ")

        let cat = keyRaw.match(/^(mainMod|subMod)\s*\.\.\s*"([^"]*)"$/)
        if (cat) {
            let base = cat[1] === "mainMod" ? root._mainMod : root._subMod
            return (base + cat[2]).trim().replace(/\s+/g, " ")
        }
        return keyRaw
    }

    function _buildConflicts() {
        let counts = {}
        for (let b of root.binds) counts[b.keyDisplay] = (counts[b.keyDisplay] || 0) + 1
        root.conflictCounts = counts
    }

    // --- Friendly names ---
    function friendlyName(bind) {
        if (root.labelOverrides[bind.actionKey]) return root.labelOverrides[bind.actionKey]
        return root._autoLabel(bind.actionFull)
    }

    function isAutoNamed(bind) {
        return !root.labelOverrides[bind.actionKey]
    }

    function _autoLabel(action) {
        let m

        if (/window\.float/.test(action)) return "Toggle Floating"
        if (/window\.pseudo/.test(action)) return "Toggle Pseudotile"
        if (/window\.close/.test(action)) return "Close Window"
        if (/window\.drag/.test(action)) return "Drag Window (Mouse)"
        if (/window\.resize/.test(action)) return "Resize Window (Mouse)"
        if (/window\.bring_to_top/.test(action) && /cycle_next/.test(action)) return "Cycle Windows (Alt-Tab style)"
        if (/window\.cycle_next/.test(action)) return "Focus Next Window"

        m = action.match(/focus\(\{\s*direction\s*=\s*"(\w+)"/)
        if (m) return "Focus Window: " + m[1].charAt(0).toUpperCase() + m[1].slice(1)

        if (/focus\(\{\s*workspace\s*=\s*i\s*\}/.test(action)) return "Switch to Workspace (1-10)"
        if (/window\.move\(\{\s*workspace\s*=\s*i\s*\}/.test(action)) return "Move Window to Workspace (1-10)"

        m = action.match(/focus\(\{\s*workspace\s*=\s*"?([\w+-]+)"?\s*\}/)
        if (m) return "Switch to Workspace " + m[1]

        if (/qs ipc call settings/.test(action)) return "Toggle Settings"
        if (/qs ipc call launcher/.test(action)) return "Toggle App Launcher"
        if (/qs ipc call clipboard/.test(action)) return "Toggle Clipboard"
        if (/qs ipc call controlcenter/.test(action)) return "Toggle Control Center"
        if (/qs ipc call notificationcenter/.test(action)) return "Toggle Notification Center"
        if (/qs ipc call power/.test(action)) return "Toggle Power Menu"
        if (/qs ipc call themeswitcher/.test(action)) return "Toggle Theme Switcher"
        if (/qs ipc call wallpaper/.test(action)) return "Toggle Wallpaper Switcher"
        if (/qs ipc call workspaces/.test(action)) return "Toggle Workspace Switcher"
        if (/qs ipc call brightness increase/.test(action)) return "Brightness Up"
        if (/qs ipc call brightness decrease/.test(action)) return "Brightness Down"
        if (/qs ipc call volume increase/.test(action)) return "Volume Up"
        if (/qs ipc call volume decrease/.test(action)) return "Volume Down"
        if (/qs ipc call volume toggle/.test(action)) return "Mute Toggle"
        if (/quickshell ipc call lock/.test(action)) return "Lock Screen"

        if (/playerctl next/.test(action)) return "Next Track"
        if (/playerctl previous/.test(action)) return "Previous Track"
        if (/playerctl play-pause/.test(action)) return "Play / Pause"

        if (/hyprctl kill/.test(action)) return "Kill Active Window (Force)"
        if (/wlogout/.test(action)) return "Power Menu (wlogout)"
        if (/hyprlock/.test(action)) return "Lock Screen (hyprlock)"
        if (/cliphist wipe/.test(action)) return "Clear Clipboard History"
        if (/hyprshot -m output/.test(action)) return "Screenshot: Full Screen"
        if (/hyprshot -m region/.test(action)) return "Screenshot: Region"
        if (/hyprpicker/.test(action)) return "Color Picker"

        m = action.match(/exec_cmd\("([^"]+)"/)
        if (m) {
            let cmd = m[1]
            let bin = cmd.split("/").pop().split(" ")[0]
            return "Run: " + bin
        }

        return action.length > 40 ? action.substring(0, 40) + "…" : action
    }

    function setLabel(actionKey, label) {
        let trimmed = label.trim()
        let updated = Object.assign({}, root.labelOverrides)
        if (trimmed.length === 0) {
            delete updated[actionKey]
        } else {
            updated[actionKey] = trimmed
        }
        root.labelOverrides = updated
        root._saveLabels()
    }

    // Rebuilt to avoid heredoc/quoting fragility entirely: the JSON is
    // base64-encoded in QML, then decoded straight to the target file in one
    // single-line shell command. No embedded newlines in the command string,
    // no quote-escaping to get wrong. stderr/exit code are now surfaced to
    // the log (see writeLabelsProc above) instead of failing silently.
    function _saveLabels() {
        let json = JSON.stringify(root.labelOverrides, null, 2)
        let b64 = Qt.btoa(json)
        writeLabelsProc.command = ["sh", "-c",
            "mkdir -p ~/.config/quickshell && echo '" + b64 + "' | base64 -d > " + root.labelsPath]
        writeLabelsProc.running = true
    }

    // Rebinds only the key-combo argument. Everything from the first comma
    // onward — the dispatcher call, exec_cmd, function block, options table —
    // is copied through unchanged, regardless of whether it spans multiple lines.
    function rebindKey(bindId, newKeyDisplay) {
        let b = root.binds.find(x => x.id === bindId)
        if (!b) return false
        let t = root.rawText
        let replacement = "\"" + newKeyDisplay.replace(/"/g, '\\"') + "\""
        root._write(t.substring(0, b.keyStart) + replacement + t.substring(b.keyEnd))
        return true
    }

    // Collapses a multi-line hl.bind(...) call onto one line — joins wrapped
    // lines with a single space. Does not alter key combo or action logic,
    // purely whitespace/newline cleanup.
    function flattenBind(bindId) {
        let b = root.binds.find(x => x.id === bindId)
        if (!b) return false
        let t = root.rawText
        let call = t.substring(b.callStart, b.callEnd)
        let flat = call.replace(/\s*\n\s*/g, " ").replace(/\s+/g, " ")
        root._write(t.substring(0, b.callStart) + flat + t.substring(b.callEnd))
        return true
    }

    // Appends a new exec_cmd-only bind under a dedicated marker section,
    // created on first use.
    function addExecBind(newKeyDisplay, command) {
        let t = root.rawText
        let keyLit = "\"" + newKeyDisplay.replace(/"/g, '\\"') + "\""
        let cmdLit = command.replace(/"/g, '\\"')
        let line = "hl.bind(" + keyLit + ", hl.dsp.exec_cmd(\"" + cmdLit + "\"))"

        if (t.indexOf(root.customMarker) === -1) {
            t = t.replace(/\s*$/, "") + "\n\n" + root.customMarker + "\n" + line + "\n"
        } else {
            t = t.replace(/\s*$/, "") + "\n" + line + "\n"
        }
        root._write(t)
    }

    // Only binds added by this service (below the marker) can be removed —
    // original hand-written binds elsewhere in the file are never deletable
    // through this path.
    function removeCustomBind(bindId) {
        let b = root.binds.find(x => x.id === bindId)
        if (!b || !b.isCustom) return false
        let t = root.rawText
        let lineStart = t.lastIndexOf("\n", b.callStart) + 1
        let lineEnd = t.indexOf("\n", b.callEnd)
        root._write(t.substring(0, lineStart) + t.substring(lineEnd === -1 ? t.length : lineEnd + 1))
        return true
    }

    // Written via heredoc — separate from label-saving above, and unrelated
    // to the bug we just fixed (binds.lua rewrites were already confirmed
    // working correctly in earlier testing).
    function _write(newText) {
        let marker = "QS_BINDS_EOF_" + Date.now()
        writeProc.command = ["sh", "-c",
            "cat > " + root.bindsPath + " << '" + marker + "'\n" + newText + "\n" + marker]
        writeProc.running = true
        reloadProc.command = ["hyprctl", "reload"]
        reloadProc.running = true
        root.rawText = newText
        root._parse()
    }

    Component.onCompleted: refresh()
}