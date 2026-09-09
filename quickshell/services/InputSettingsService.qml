// services/InputSettingsService.qml — reads/writes ~/.config/hypr/modules/input.lua.
// Uses the same bracket-depth-scoping technique as
// HyprlandKeybindsService._parse (for hl.bind calls) to isolate the
// "touchpad = { ... }" object and the "hl.device({ ... })" object before
// doing any field regex — this matters because "sensitivity" and
// "scroll_factor" each appear in more than one place in the file (global
// vs touchpad vs per-device override), so a naive whole-file regex would
// risk editing the wrong occurrence. Rewrite-then-reload pattern matches
// the other Hyprland-config services in this project.
//
// Slider drags fire many rapid value changes; writing the Lua file +
// hyprctl reload on every single one caused visible stutter. All writes
// go through _debouncedWrite() so only the last value in a drag burst
// actually gets written, ~150ms after the user stops moving the slider.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string inputPath: "~/.config/hypr/modules/input.lua"

    property string rawText: ""
    property bool loaded: false

    // Global (applies to mouse + any device without an override)
    property real sensitivity: 0
    property real scrollFactor: 1.0

    // Touchpad-specific
    property bool touchpadNaturalScroll: false
    property real touchpadScrollFactor: 1.0

    // Per-device override (targets the confirmed real touchpad device
    // name via hl.device({ name = "synps/2-synaptics-touchpad", ... }))
    property real touchpadSensitivity: 0

    function refresh() { readProc.running = true }

    Process {
        id: readProc
        command: ["sh", "-c", "cat " + root.inputPath]
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

    // ---- debounce ----
    property var _pendingWrite: null

    Timer {
        id: writeDebounce
        interval: 150
        repeat: false
        onTriggered: {
            if (root._pendingWrite) {
                root._pendingWrite()
                root._pendingWrite = null
            }
        }
    }

    function _debouncedWrite(fn) {
        root._pendingWrite = fn
        writeDebounce.restart()
    }

    // ---- bracket-depth scoping helpers ----
    function _touchpadBounds(t) {
        let key = "touchpad = {"
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

    function _deviceBounds(t) {
        let key = "hl.device({"
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
        let touchpadIdx = t.indexOf("touchpad = {")
        let topText = touchpadIdx !== -1 ? t.substring(0, touchpadIdx) : t

        let sensMatch = topText.match(/sensitivity\s*=\s*([^,]*),/)
        root.sensitivity = sensMatch ? parseFloat(sensMatch[1]) : 0

        let scrollMatch = topText.match(/scroll_factor\s*=\s*([^,]*),/)
        root.scrollFactor = scrollMatch ? parseFloat(scrollMatch[1]) : 1.0

        let touchpadB = root._touchpadBounds(t)
        if (touchpadB) {
            let inner = t.substring(touchpadB.innerStart, touchpadB.innerEnd)
            let nsMatch = inner.match(/natural_scroll\s*=\s*(true|false)/)
            root.touchpadNaturalScroll = nsMatch ? nsMatch[1] === "true" : false
            let tsfMatch = inner.match(/scroll_factor\s*=\s*([^,]*),/)
            root.touchpadScrollFactor = tsfMatch ? parseFloat(tsfMatch[1]) : 1.0
        }

        let deviceB = root._deviceBounds(t)
        if (deviceB) {
            let dinner = t.substring(deviceB.innerStart, deviceB.innerEnd)
            let dsMatch = dinner.match(/sensitivity\s*=\s*([^,]*),/)
            root.touchpadSensitivity = dsMatch ? parseFloat(dsMatch[1]) : 0
        }
    }

    function setSensitivity(val) {
        root._debouncedWrite(() => {
            let t = root.rawText
            let touchpadIdx = t.indexOf("touchpad = {")
            let topText = touchpadIdx !== -1 ? t.substring(0, touchpadIdx) : t
            let restText = touchpadIdx !== -1 ? t.substring(touchpadIdx) : ""
            let newTop = topText.replace(/sensitivity(\s*)=(\s*)[^,]*,/, "sensitivity$1=$2" + val + ",")
            root._write(newTop + restText)
        })
    }

    function setScrollFactor(val) {
        root._debouncedWrite(() => {
            let t = root.rawText
            let touchpadIdx = t.indexOf("touchpad = {")
            let topText = touchpadIdx !== -1 ? t.substring(0, touchpadIdx) : t
            let restText = touchpadIdx !== -1 ? t.substring(touchpadIdx) : ""
            let newTop = topText.replace(/scroll_factor(\s*)=(\s*)[^,]*,/, "scroll_factor$1=$2" + val + ",")
            root._write(newTop + restText)
        })
    }

    function setTouchpadNaturalScroll(val) {
        // Discrete toggle click, not a drag — writes immediately, no
        // debounce needed.
        let t = root.rawText
        let b = root._touchpadBounds(t)
        if (!b) return
        let inner = t.substring(b.innerStart, b.innerEnd)
        let newInner = inner.replace(/natural_scroll(\s*)=(\s*)(true|false)/, "natural_scroll$1=$2" + (val ? "true" : "false"))
        root._write(t.substring(0, b.innerStart) + newInner + t.substring(b.innerEnd))
    }

    function setTouchpadScrollFactor(val) {
        root._debouncedWrite(() => {
            let t = root.rawText
            let b = root._touchpadBounds(t)
            if (!b) return
            let inner = t.substring(b.innerStart, b.innerEnd)
            let newInner = inner.replace(/scroll_factor(\s*)=(\s*)[^,]*,/, "scroll_factor$1=$2" + val + ",")
            root._write(t.substring(0, b.innerStart) + newInner + t.substring(b.innerEnd))
        })
    }

    function setTouchpadSensitivity(val) {
        root._debouncedWrite(() => {
            let t = root.rawText
            let b = root._deviceBounds(t)
            if (!b) return
            let inner = t.substring(b.innerStart, b.innerEnd)
            let newInner = inner.replace(/sensitivity(\s*)=(\s*)[^,]*,/, "sensitivity$1=$2" + val + ",")
            root._write(t.substring(0, b.innerStart) + newInner + t.substring(b.innerEnd))
        })
    }

    function _write(newText) {
        let marker = "QS_INPUT_EOF_" + Date.now()
        writeProc.command = ["sh", "-c",
            "cat > " + root.inputPath + " << '" + marker + "'\n" + newText + "\n" + marker]
        writeProc.running = true
        reloadProc.command = ["hyprctl", "reload"]
        reloadProc.running = true
        root.rawText = newText
        root._parse()
    }

    Component.onCompleted: refresh()
}