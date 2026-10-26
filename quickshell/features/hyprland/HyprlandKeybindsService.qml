// features/hyprland/HyprlandKeybindsService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string bindsDir: "~/.config/hypr/modules/binds/"
    readonly property string labelsPath: "~/.config/quickshell/keybind-labels.json"
    readonly property string mainModFile: "mainmod.lua"
    readonly property string customFile: "custom.lua"
    // Files shown in Settings.
    readonly property var bindFiles: ["common.lua", "qs.lua", "custom.lua"]

    property var fileTexts: ({})
    property var binds: []
    property var conflictCounts: ({})
    // Binds the parser skips (workspace 1-10 loops, mouse binds). They still own their keys.
    property var reserved: []
    property var labelOverrides: ({})
    property bool loaded: false
    property bool labelsLoaded: false
    property string lastLabelSaveError: ""

    property string mainMod: "SUPER"

    function refresh() { readProc.running = true; readLabelsProc.running = true }

    Process {
        id: readProc
        command: ["sh", "-c",
            "cd " + root.bindsDir + " && for f in " + root.mainModFile + " " +
            root.bindFiles.join(" ") +
            "; do printf '\\n@@FILE %s\\n' \"$f\"; cat \"$f\" 2>/dev/null; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                let map = {}
                for (let chunk of text.split("\n@@FILE ").slice(1)) {
                    let nl = chunk.indexOf("\n")
                    if (nl === -1) continue
                    map[chunk.substring(0, nl)] = chunk.substring(nl + 1)
                }
                root.fileTexts = map
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

    // Reload Hyprland only after the file write has finished
    Process {
        id: reloadProc
        command: ["hyprctl", "reload"]
    }
    Process {
        id: writeProc
        onExited: reloadProc.running = true
    }

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
    }

    function setMainMod(newMod) {
        if (root.mainMod === newMod) return
        root._write(root.mainModFile, 'return "' + newMod + '"\n')
    }

    // The two shell-switch binds belong with the shell shortcuts (the Shell page), not with the
    // window ones, so they count as "Quickshell" even though they call a script, not qs ipc.
    function _categorizeBind(action) {
        if (root._isShellBind(action)) {
            return "Quickshell"
        }
        if (/qs ipc call|quickshell ipc call/.test(action)) {
            return "Quickshell"
        }
        if (/playerctl|XF86Audio|brightness|hyprshot|hyprpicker|cliphist|wlogout|hyprlock/.test(action)) {
            return "Media & System"
        }
        return "Hyprland"
    }

    // The two shell-switch binds are listed first on their page
    function _isShellBind(action) {
        return /switch-shell\.sh/.test(action)
    }

    function _parse() {
        let mm = (root.fileTexts[root.mainModFile] || "").match(/return\s*"([^"]*)"/)
        root.mainMod = mm ? mm[1] : "SUPER"

        let results = []
        let reserved = []
        for (let name of root.bindFiles)
            root._parseFile(name, root.fileTexts[name] || "", results, reserved)

        // Shell-switch binds first, everything else keeps its order
        let shellBinds = results.filter(b => root._isShellBind(b.actionFull))
        let otherBinds = results.filter(b => !root._isShellBind(b.actionFull))
        results = shellBinds.concat(otherBinds)
        results.forEach((b, idx) => { b.id = idx })

        root.binds = results
        root.reserved = reserved
        root._buildConflicts()
    }

    function _parseFile(fileName, t, results, reserved) {
        let i = 0

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

            if (/\bkey\b|\bi\b|mouse:/.test(keyRaw)) {
                // Not listed in Settings, but remembered so the Add form can warn about their keys.
                reserved.push({
                    keyDisplay: root._resolveKeyDisplay(keyRaw),
                    actionFull: t.substring(keyExprEnd + 1, callEnd).trim().replace(/\s+/g, " ")
                })
                i = callEnd + 1
                continue
            }

            let fullCall = t.substring(callStart, callEnd + 1)
            let actionFull = t.substring(keyExprEnd + 1, callEnd).trim().replace(/\s+/g, " ")
            let actionPreview = actionFull.length > 70 ? actionFull.substring(0, 70) + "…" : actionFull

            results.push({
                id: results.length,
                file: fileName,
                keyRaw: keyRaw,
                keyDisplay: root._resolveKeyDisplay(keyRaw),
                actionPreview: actionPreview,
                actionFull: actionFull,
                actionKey: actionFull,
                category: root._categorizeBind(actionFull),
                isCustom: fileName === root.customFile,
                isMultiline: fullCall.indexOf("\n") !== -1,
                keyStart: keyStart,
                keyEnd: keyExprEnd,
                callStart: callStart,
                callEnd: callEnd + 1
            })

            i = callEnd + 1
        }
    }

    function _resolveKeyDisplay(keyRaw) {
        let parts = []
        let cur = "", inString = false, stringChar = ""
        for (let i = 0; i < keyRaw.length; i++) {
            let ch = keyRaw[i]
            if (inString) {
                cur += ch
                if (ch === "\\") { cur += keyRaw[++i] || ""; continue }
                if (ch === stringChar) inString = false
                continue
            }
            if (ch === '"' || ch === "'") { inString = true; stringChar = ch; cur += ch; continue }
            if (ch === "." && keyRaw[i + 1] === ".") {
                parts.push(cur.trim())
                cur = ""
                i++
                continue
            }
            cur += ch
        }
        if (cur.trim().length > 0) parts.push(cur.trim())

        const keyMap = {
            "mouse:272": "Left Mouse",
            "mouse:273": "Right Mouse",
            "mouse:274": "Middle Mouse",
            "XF86AudioMute": "F1",
            "XF86AudioLowerVolume": "F2",
            "XF86AudioRaiseVolume": "F3",
            "XF86AudioMicMute": "F4",
            "XF86MonBrightnessDown": "F5",
            "XF86MonBrightnessUp": "F6",
            "XF86AudioPrev": "F9",
            "XF86AudioPlay": "F10",
            "XF86AudioPause": "F10",
            "XF86AudioNext": "F11"
        }

        let resolved = parts.map(part => {
            let lit = part.match(/^"([^"]*)"$/) || part.match(/^'([^']*)'$/)
            if (lit) {
                let val = lit[1]
                return keyMap[val] !== undefined ? keyMap[val] : val
            }
            if (part === "mainMod") return root.mainMod
            if (part === "key" || part === "i") return "1-10"

            return "[" + part + "]"
        })

        return resolved.join("").trim().replace(/\s+/g, " ")
    }

    function _buildConflicts() {
        let counts = {}
        for (let b of root.binds) counts[b.keyDisplay] = (counts[b.keyDisplay] || 0) + 1
        root.conflictCounts = counts
    }

    function friendlyName(bind) {
        if (root.labelOverrides[bind.actionKey]) return root.labelOverrides[bind.actionKey]
        return root._autoLabel(bind.actionFull)
    }

    function isAutoNamed(bind) {
        return !root.labelOverrides[bind.actionKey]
    }

    // Whether a row should show the raw action under its name. A clear label already says what the
    // shortcut does, so the code line would only repeat it. It is shown where it adds information:
    // shortcuts you added, shortcuts you renamed, and ones with no recognised label ("Run: ...").
    function showsAction(bind) {
        return bind.isCustom
            || !root.isAutoNamed(bind)
            || root._knownLabel(bind.actionFull) === ""
    }

    // The readable label for every action this file recognises, or "" when it has none.
    function _knownLabel(action) {
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

        if (/switch-shell\.sh qs/.test(action)) return "Shell: Toggle Quickshell"
        if (/switch-shell\.sh ags/.test(action)) return "Shell: Toggle AGS"

        m = action.match(/open-default\.sh\s+(\w+)/)
        if (m) {
            const defaultNames = { browser: "Open Default Browser", terminal: "Open Default Terminal", files: "Open Default File Manager" }
            return defaultNames[m[1]] || ("Open Default: " + m[1])
        }

        if (/playerctl next/.test(action)) return "Next Track"
        if (/playerctl previous/.test(action)) return "Previous Track"
        if (/playerctl play-pause/.test(action)) return "Play / Pause"

        if (/hyprctl kill/.test(action)) return "Kill Active Window (Force)"
        if (/hyprctl reload/.test(action)) return "Reload Hyprland"
        if (/wlogout/.test(action)) return "Power Menu (wlogout)"
        if (/hyprlock/.test(action)) return "Lock Screen (hyprlock)"
        if (/cliphist wipe/.test(action)) return "Clear Clipboard History"
        if (/hyprshot -m output/.test(action)) return "Screenshot: Full Screen"
        if (/hyprshot -m region/.test(action)) return "Screenshot: Region"
        if (/hyprpicker/.test(action)) return "Color Picker"

        return ""
    }

    function _autoLabel(action) {
        let known = root._knownLabel(action)
        if (known !== "") return known

        let m = action.match(/exec_cmd\("([^"]+)"/)
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

    function _saveLabels() {
        let json = JSON.stringify(root.labelOverrides, null, 2)
        let b64 = Qt.btoa(json)
        writeLabelsProc.command = ["sh", "-c",
            "mkdir -p ~/.config/quickshell && echo '" + b64 + "' | base64 -d > " + root.labelsPath]
        writeLabelsProc.running = true
    }

    function rebindKey(bindId, newKeyDisplay) {
        let b = root.binds.find(x => x.id === bindId)
        if (!b) return false
        let t = root.fileTexts[b.file] || ""
        let replacement = "\"" + newKeyDisplay.replace(/"/g, '\\"') + "\""
        root._write(b.file, t.substring(0, b.keyStart) + replacement + t.substring(b.keyEnd))
        return true
    }

    function flattenBind(bindId) {
        let b = root.binds.find(x => x.id === bindId)
        if (!b) return false
        let t = root.fileTexts[b.file] || ""
        let call = t.substring(b.callStart, b.callEnd)
        let flat = call.replace(/\s*\n\s*/g, " ").replace(/\s+/g, " ")
        root._write(b.file, t.substring(0, b.callStart) + flat + t.substring(b.callEnd))
        return true
    }

    // ================= ADD FORM: checks =================

    // "SUPER + shift + a" and "super+SHIFT+A" are the same shortcut, so compare them in one form.
    function normalizeCombo(combo) {
        const order = ["SUPER", "CTRL", "ALT", "SHIFT"]
        const alias = { CONTROL: "CTRL", META: "SUPER", WIN: "SUPER", MOD4: "SUPER" }
        let mods = []
        let keys = []
        for (let raw of String(combo || "").split("+")) {
            let tok = raw.trim().toUpperCase()
            if (tok === "") continue
            if (alias[tok] !== undefined) tok = alias[tok]
            if (order.indexOf(tok) >= 0) {
                if (mods.indexOf(tok) < 0) mods.push(tok)
            } else {
                keys.push(tok)
            }
        }
        mods.sort((x, y) => order.indexOf(x) - order.indexOf(y))
        const key = keys.join(" ")
        return { mods: mods, key: key, text: mods.concat(key === "" ? [] : [key]).join(" + ") }
    }

    // The existing shortcut that already uses this combination, or null. The workspace 1-10 loop
    // binds are checked as a range, since the parser does not list them one by one.
    function findConflict(combo) {
        const n = root.normalizeCombo(combo)
        if (n.key === "") return null

        for (const b of root.binds) {
            if (root.normalizeCombo(b.keyDisplay).text === n.text)
                return { label: root.friendlyName(b), keyDisplay: b.keyDisplay }
        }

        for (const r of root.reserved) {
            const rn = root.normalizeCombo(r.keyDisplay)
            const sameMods = rn.mods.join("+") === n.mods.join("+")
            if (rn.text === n.text || (rn.key === "1-10" && /^[0-9]$/.test(n.key) && sameMods))
                return { label: root._autoLabel(r.actionFull), keyDisplay: r.keyDisplay }
        }
        return null
    }

    // How safe a combination is to bind. level: "ok" | "warn" (allowed, ask) | "block" (not allowed).
    function comboRisk(combo) {
        const n = root.normalizeCombo(combo)
        const ok = { level: "ok", text: "" }
        if (n.key === "") return ok

        // Keys you type with. A bare one, bound system-wide, stops working in every app.
        const typing = /^([A-Z0-9]|SPACE|RETURN|TAB|BACKSPACE|DELETE|LEFT|RIGHT|UP|DOWN|COMMA|PERIOD)$/.test(n.key)
        if (!typing) return ok

        if (n.mods.indexOf("SUPER") >= 0 || n.mods.indexOf(root.mainMod) >= 0) return ok

        if (n.mods.length === 0) {
            return { level: "block",
                text: "A shortcut with no modifier would stop " + n.key + " working in every app. Add "
                    + root.mainMod + " or another modifier." }
        }
        if (n.mods.length === 1 && n.mods[0] === "SHIFT") {
            return { level: "warn",
                text: "Shift plus a key is how you type capitals. This shortcut would stop that in every app." }
        }
        return { level: "warn",
            text: "Apps use this combination themselves (copy, paste, tabs). Hyprland takes it first, so they stop receiving it." }
    }

    // ================= ADD FORM: actions =================
    // Every action here is copied from your own binds files (common.lua, qs.lua) or from the
    // Hyprland wiki's Lua dispatcher page. build(value) returns { action, flags } or null while the
    // input is not valid yet. `flags` is the optional third argument of hl.bind, like { locked = true }.

    readonly property var actionGroups: ["Run", "Window", "Workspace", "Shell", "System"]

    readonly property var actionCatalog: [
        // ---- Run ----
        { group: "Run", title: "Run a command", input: "command",
          build: v => { v = v.trim(); return v === "" ? null : root._exec(v) } },
        { group: "Run", title: "Run in a floating window", input: "command",
          build: v => { v = v.trim(); return v === "" ? null
              : { action: 'hl.dsp.exec_cmd("' + root._luaString(v) + '", { float = true })', flags: "" } } },
        { group: "Run", title: "Open default app", input: "app",
          build: v => /^(terminal|browser|files)$/.test(v)
              ? root._exec("$HOME/.config/hypr/scripts/open-default.sh " + v) : null },

        // ---- Window ----
        { group: "Window", title: "Close window", input: "none",
          build: v => ({ action: "hl.dsp.window.close()", flags: "" }) },
        { group: "Window", title: "Force kill window", input: "none",
          build: v => ({ action: "hl.dsp.window.kill()", flags: "" }) },
        { group: "Window", title: "Toggle floating", input: "none",
          build: v => ({ action: 'hl.dsp.window.float({ action = "toggle" })', flags: "" }) },
        { group: "Window", title: "Toggle pseudotile", input: "none",
          build: v => ({ action: "hl.dsp.window.pseudo()", flags: "" }) },
        { group: "Window", title: "Focus window", input: "direction",
          build: v => /^(left|right|up|down)$/.test(v)
              ? { action: 'hl.dsp.focus({ direction = "' + v + '" })', flags: "" } : null },
        { group: "Window", title: "Toggle group", input: "none",
          build: v => ({ action: "hl.dsp.group.toggle()", flags: "" }) },
        { group: "Window", title: "Toggle split (dwindle layout only)", input: "none",
          build: v => ({ action: 'hl.dsp.layout("togglesplit")', flags: "" }) },

        // ---- Workspace ----
        { group: "Workspace", title: "Go to workspace", input: "workspace",
          build: v => /^([1-9]|10)$/.test(v)
              ? { action: "hl.dsp.focus({ workspace = " + v + " })", flags: "" } : null },
        { group: "Workspace", title: "Next workspace", input: "none",
          build: v => ({ action: 'hl.dsp.focus({ workspace = "e+1" })', flags: "" }) },
        { group: "Workspace", title: "Previous workspace", input: "none",
          build: v => ({ action: 'hl.dsp.focus({ workspace = "e-1" })', flags: "" }) },
        { group: "Workspace", title: "Move window to workspace", input: "workspace",
          build: v => /^([1-9]|10)$/.test(v)
              ? { action: "hl.dsp.window.move({ workspace = " + v + " })", flags: "" } : null },
        { group: "Workspace", title: "Toggle scratchpad", input: "name",
          build: v => /^[A-Za-z0-9_-]+$/.test(v)
              ? { action: 'hl.dsp.workspace.toggle_special("' + v + '")', flags: "" } : null },
        { group: "Workspace", title: "Send window to scratchpad", input: "name",
          build: v => /^[A-Za-z0-9_-]+$/.test(v)
              ? { action: 'hl.dsp.window.move({ workspace = "special:' + v + '" })', flags: "" } : null },

        // ---- Shell (qs.lua) ----
        { group: "Shell", title: "Toggle Settings", input: "none",
          build: v => root._exec("qs ipc call settings toggle") },
        { group: "Shell", title: "Toggle App Launcher", input: "none",
          build: v => root._exec("qs ipc call launcher toggle", "{ locked = true }") },
        { group: "Shell", title: "Toggle Clipboard", input: "none",
          build: v => root._exec("qs ipc call clipboard toggle") },
        { group: "Shell", title: "Toggle Control Center", input: "none",
          build: v => root._exec("qs ipc call controlcenter toggle") },
        { group: "Shell", title: "Toggle Notification Center", input: "none",
          build: v => root._exec("qs ipc call notificationcenter toggle") },
        { group: "Shell", title: "Toggle Power Menu", input: "none",
          build: v => root._exec("qs ipc call power toggle") },
        { group: "Shell", title: "Lock Screen", input: "none",
          build: v => root._exec("quickshell ipc call lock lock") },
        { group: "Shell", title: "Toggle Theme Switcher", input: "none",
          build: v => root._exec("qs ipc call themeswitcher toggle") },
        { group: "Shell", title: "Toggle Wallpaper Switcher", input: "none",
          build: v => root._exec("qs ipc call wallpaper toggle") },
        { group: "Shell", title: "Brightness Up", input: "none",
          build: v => root._exec("qs ipc call brightness increase", "{ locked = true, repeating = true }") },
        { group: "Shell", title: "Brightness Down", input: "none",
          build: v => root._exec("qs ipc call brightness decrease", "{ locked = true, repeating = true }") },
        { group: "Shell", title: "Volume Up", input: "none",
          build: v => root._exec("qs ipc call volume increase", "{ locked = true, repeating = true }") },
        { group: "Shell", title: "Volume Down", input: "none",
          build: v => root._exec("qs ipc call volume decrease", "{ locked = true, repeating = true }") },
        { group: "Shell", title: "Mute Toggle", input: "none",
          build: v => root._exec("qs ipc call volume toggle", "{ locked = true, repeating = true }") },

        // ---- System (common.lua) ----
        { group: "System", title: "Next Track", input: "none",
          build: v => root._exec("playerctl next", "{ locked = true }") },
        { group: "System", title: "Play / Pause", input: "none",
          build: v => root._exec("playerctl play-pause", "{ locked = true }") },
        { group: "System", title: "Previous Track", input: "none",
          build: v => root._exec("playerctl previous", "{ locked = true }") },
        { group: "System", title: "Screenshot: Region", input: "none",
          build: v => root._exec("hyprshot -m region -o $HOME/Pictures/Screenshot") },
        { group: "System", title: "Color Picker", input: "none",
          build: v => root._exec("hyprpicker -a -f hex") },
        { group: "System", title: "Clear Clipboard History", input: "none",
          build: v => root._exec("cliphist wipe") },
        { group: "System", title: "Power Menu (wlogout)", input: "none",
          build: v => root._exec("$HOME/.config/wlogout/scripts/wlogout.sh") },
        { group: "System", title: "Lock Screen (hyprlock)", input: "none",
          build: v => root._exec("hyprlock -c $HOME/.config/hypr/hyprlock/hyprlock.conf") },
        { group: "System", title: "Reload Hyprland", input: "none",
          build: v => root._exec("hyprctl reload") }
    ]

    function actionsForGroup(group) {
        return root.actionCatalog.filter(e => e.group === group)
    }

    // Escapes text for use inside a Lua "..." string.
    function _luaString(s) {
        return String(s).replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/[\r\n]+/g, " ")
    }

    function _exec(cmd, flags) {
        return { action: 'hl.dsp.exec_cmd("' + root._luaString(cmd) + '")', flags: flags || "" }
    }

    // Appends hl.bind(key, action[, flags]) to custom.lua. A name is optional: it becomes the
    // friendly label, stored under the same key the list uses (the text after the key comma).
    function addBind(newKeyDisplay, action, flags, name) {
        let t = root.fileTexts[root.customFile] || ""
        let tail = action + (flags ? ", " + flags : "")
        let line = 'hl.bind("' + root._luaString(newKeyDisplay) + '", ' + tail + ")"

        t = t.replace(/\s*$/, "") + "\n" + line + "\n"
        root._write(root.customFile, t)

        let label = (name || "").trim()
        if (label !== "") root.setLabel(tail.replace(/\s+/g, " ").trim(), label)
    }

    // Kept for older callers: a plain "run this command" shortcut.
    function addExecBind(newKeyDisplay, command) {
        let built = root._exec(command)
        root.addBind(newKeyDisplay, built.action, built.flags, "")
    }

    function removeCustomBind(bindId) {
        let b = root.binds.find(x => x.id === bindId)
        if (!b || !b.isCustom) return false
        let t = root.fileTexts[b.file] || ""
        let lineStart = t.lastIndexOf("\n", b.callStart) + 1
        let lineEnd = t.indexOf("\n", b.callEnd)
        root._write(b.file, t.substring(0, lineStart) + t.substring(lineEnd === -1 ? t.length : lineEnd + 1))
        return true
    }

    function _write(fileName, newText) {
        let marker = "QS_BINDS_EOF_" + Date.now()
        writeProc.command = ["sh", "-c",
            "cat > " + root.bindsDir + fileName + " << '" + marker + "'\n" + newText + "\n" + marker]
        writeProc.running = true

        let t = Object.assign({}, root.fileTexts)
        t[fileName] = newText
        root.fileTexts = t
        root._parse()
    }

    // NOTE: the "capture" submap used by KeyCaptureField.qml is declared in
    // modules/binds/submaps.lua. It must keep at least one real bind inside it,
    // or Hyprland refuses to switch into it.
    Component.onCompleted: refresh()
}
