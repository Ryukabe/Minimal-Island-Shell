// services/HyprlandDecorationService.qml — reads/writes the decoration.blur
// block in ~/.config/hypr/modules/decoration.lua. Same rewrite-then-reload
// pattern as HyprlandAnimationsService.setEnabled() — edits the real
// hl.config({ decoration = { blur = { enabled = ... } } }) line rather
// than a runtime-only hyprctl keyword, since (per the Reduce Motion /
// animations:enabled lesson) a bare keyword change gets clobbered on the
// next hyprctl reload triggered anywhere else in the shell.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string decorationPath: "~/.config/hypr/modules/decoration.lua"

    property string rawText: ""
    property bool blurEnabled: true
    property bool loaded: false

    function refresh() { readProc.running = true }

    Process {
        id: readProc
        command: ["sh", "-c", "cat " + root.decorationPath]
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

    // Isolates the blur = { ... } block via brace-depth scoping (same
    // technique as InputSettingsService's _touchpadBounds), since
    // "enabled" appears elsewhere in this file too (decoration.shadow
    // has its own enabled field) — a naive whole-file regex would risk
    // flipping the wrong one.
    function _blurBounds(t) {
        let key = "blur = {"
        let start = t.indexOf(key)
        if (start === -1) return null
        let braceOpen = start + key.length - 1
        let depth = 1
        let pos = braceOpen + 1
        while (pos < t.length && depth > 0) {
            if (t[pos] === "{") depth++
            else if (t[pos] === "}") depth--
            pos++
        }
        return { innerStart: braceOpen + 1, innerEnd: pos - 1 }
    }

    function _parse() {
        let t = root.rawText
        let b = root._blurBounds(t)
        if (!b) return
        let inner = t.substring(b.innerStart, b.innerEnd)
        let match = inner.match(/enabled\s*=\s*(true|false)/)
        root.blurEnabled = match ? match[1] === "true" : true
    }

    function setBlurEnabled(enabled) {
        let t = root.rawText
        let b = root._blurBounds(t)
        if (!b) return
        let inner = t.substring(b.innerStart, b.innerEnd)
        let newInner = inner.replace(/enabled(\s*)=(\s*)(true|false)/, "enabled$1=$2" + (enabled ? "true" : "false"))
        root._write(t.substring(0, b.innerStart) + newInner + t.substring(b.innerEnd))
    }

    function _write(newText) {
        let marker = "QS_DECORATION_EOF_" + Date.now()
        writeProc.command = ["sh", "-c",
            "cat > " + root.decorationPath + " << '" + marker + "'\n" + newText + "\n" + marker]
        writeProc.running = true
        reloadProc.command = ["hyprctl", "reload"]
        reloadProc.running = true
        root.rawText = newText
        root._parse()
    }

    Component.onCompleted: refresh()
}