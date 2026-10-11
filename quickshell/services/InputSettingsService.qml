// services/InputSettingsService.qml — reads/writes ~/.config/hypr/modules/input.lua.
// Uses bracket-depth scoping to isolate the "touchpad = { ... }" object and the
// "hl.device({ ... })" object before doing any field regex, because "sensitivity" and
// "scroll_factor" each appear in more than one place in the file (global vs touchpad
// vs per-device override). A naive whole-file regex could edit the wrong occurrence.
//
// Slider drags fire many rapid value changes, so slider writes go through
// _debouncedWrite(): only the last value in a drag burst is written, ~150 ms after
// the user stops moving the slider.
//
// _write() saves the file and reloads Hyprland in ONE shell command, so the reload
// can never run before the file is written.
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
    property bool touchpadTapToClick: true

    // Per-device override (hl.device({ name = "synps/2-synaptics-touchpad", ... }))
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

    // Two decimals is plenty for these sliders and avoids float noise
    // like -0.1499999999999999 ending up in the file.
    function _round(val) { return Math.round(val * 100) / 100 }

    // ---- bracket-depth scoping helpers ----
    function _boundsAfter(t, key) {
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

    function _touchpadBounds(t) { return root._boundsAfter(t, "touchpad = {") }
    function _deviceBounds(t)   { return root._boundsAfter(t, "hl.device({") }

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
            let ttcMatch = inner.match(/tap_to_click\s*=\s*(true|false)/)
            root.touchpadTapToClick = ttcMatch ? ttcMatch[1] === "true" : true
        }

        let deviceB = root._deviceBounds(t)
        if (deviceB) {
            let dinner = t.substring(deviceB.innerStart, deviceB.innerEnd)
            let dsMatch = dinner.match(/sensitivity\s*=\s*([^,]*),/)
            root.touchpadSensitivity = dsMatch ? parseFloat(dsMatch[1]) : 0
        }
    }

    // ---- setters: sliders (debounced, rounded) ----
    function setSensitivity(val) {
        val = root._round(val)
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
        val = root._round(val)
        root._debouncedWrite(() => {
            let t = root.rawText
            let touchpadIdx = t.indexOf("touchpad = {")
            let topText = touchpadIdx !== -1 ? t.substring(0, touchpadIdx) : t
            let restText = touchpadIdx !== -1 ? t.substring(touchpadIdx) : ""
            let newTop = topText.replace(/scroll_factor(\s*)=(\s*)[^,]*,/, "scroll_factor$1=$2" + val + ",")
            root._write(newTop + restText)
        })
    }

    function setTouchpadScrollFactor(val) {
        val = root._round(val)
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
        val = root._round(val)
        root._debouncedWrite(() => {
            let t = root.rawText
            let b = root._deviceBounds(t)
            if (!b) return
            let inner = t.substring(b.innerStart, b.innerEnd)
            let newInner = inner.replace(/sensitivity(\s*)=(\s*)[^,]*,/, "sensitivity$1=$2" + val + ",")
            root._write(t.substring(0, b.innerStart) + newInner + t.substring(b.innerEnd))
        })
    }

    // ---- setters: toggles (discrete clicks, written immediately) ----
    function setTouchpadNaturalScroll(val) {
        let t = root.rawText
        let b = root._touchpadBounds(t)
        if (!b) return
        const v = val ? "true" : "false"
        let inner = t.substring(b.innerStart, b.innerEnd)
        let newInner = /natural_scroll\s*=/.test(inner)
            ? inner.replace(/natural_scroll(\s*)=(\s*)(true|false)/, "natural_scroll$1=$2" + v)
            : "\n            natural_scroll = " + v + "," + inner
        root._write(t.substring(0, b.innerStart) + newInner + t.substring(b.innerEnd))
    }

    function setTouchpadTapToClick(val) {
        let t = root.rawText
        let b = root._touchpadBounds(t)
        if (!b) return
        const v = val ? "true" : "false"
        let inner = t.substring(b.innerStart, b.innerEnd)
        // Replace the line if it exists, insert it at the top of the block if it doesn't.
        let newInner = /tap_to_click\s*=/.test(inner)
            ? inner.replace(/tap_to_click(\s*)=(\s*)(true|false)/, "tap_to_click$1=$2" + v)
            : "\n            tap_to_click   = " + v + "," + inner
        root._write(t.substring(0, b.innerStart) + newInner + t.substring(b.innerEnd))
    }

    // Save the file, THEN reload, in one shell command so they can't run out of order.
    function _write(newText) {
        root.rawText = newText
        root._parse()
        const marker = "QS_INPUT_EOF_" + Date.now()
        writeProc.command = ["sh", "-c",
            "cat > " + root.inputPath + " << '" + marker + "'\n" + newText + "\n" + marker +
            "\nhyprctl reload"]
        writeProc.running = true
    }

    Component.onCompleted: refresh()
}