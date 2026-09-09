// services/MonitorSettingsService.qml — fully dynamic multi-monitor
// management. Nothing here hardcodes a monitor name. Two data sources:
//   1. `hyprctl monitors -j` — live hardware state (which monitors exist
//      right now, their current mode/scale, and every mode the panel
//      actually supports). This is queried fresh, never stored, so it's
//      always accurate to whatever machine/display is plugged in.
//   2. monitors.lua — the persisted config file Quickshell edits. Each
//      physical monitor gets its own hl.monitor({ output = "...", ... })
//      block; this service locates blocks by output name using the same
//      bracket-depth scoping InputSettingsService uses for touchpad/
//      device blocks, so it works whether the file has one monitor block
//      or several.
// Because the monitor list and mode list both come from hyprctl at
// runtime, this file works unmodified on any machine — single monitor,
// multi-monitor, different panel entirely.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string monitorsPath: "~/.config/hypr/modules/monitors.lua"

    property string rawText: ""
    property var monitors: []   // [{ name, description, width, height, refreshRate, scale, x, y, availableModes: ["1920x1080@60", ...] }]
    property bool loaded: false

    function refresh() {
        queryProc.running = true
        readProc.running = true
    }

    // ---- live hardware state ----
    Process {
        id: queryProc
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let data = JSON.parse(text)
                    root.monitors = data.map(m => ({
                        name: m.name,
                        description: m.description || m.name,
                        width: m.width,
                        height: m.height,
                        refreshRate: m.refreshRate,
                        scale: m.scale,
                        x: m.x,
                        y: m.y,
                        // Hyprland reports modes like "1920x1080@60.00Hz".
                        // Normalize to the "WxHxRR" form (integer refresh,
                        // no "Hz") that monitors.lua's mode field expects.
                        availableModes: (m.availableModes || []).map(mode => {
                            let match = mode.match(/^(\d+x\d+)@([\d.]+)Hz$/)
                            if (!match) return mode
                            return match[1] + "@" + Math.round(parseFloat(match[2]))
                        }).filter((v, i, arr) => arr.indexOf(v) === i) // dedupe after rounding
                    }))
                } catch (e) {
                    console.log("[MonitorSettingsService] failed to parse hyprctl monitors -j:", e)
                }
            }
        }
    }

    // ---- persisted config file ----
    Process {
        id: readProc
        command: ["sh", "-c", "cat " + root.monitorsPath]
        stdout: StdioCollector {
            onStreamFinished: {
                root.rawText = text
                root.loaded = true
            }
        }
    }

    Process { id: reloadProc }
    Process { id: writeProc }

    // ---- debounce (same pattern as InputSettingsService) ----
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

    // Locates the hl.monitor({ ... }) block whose output field matches
    // outputName. Scans ALL hl.monitor(...) calls in the file (not just
    // the first) since a multi-monitor setup will have more than one.
    function _findMonitorBlock(t, outputName) {
        let searchFrom = 0
        while (true) {
            let callStart = t.indexOf("hl.monitor({", searchFrom)
            if (callStart === -1) return null
            let braceOpen = callStart + "hl.monitor({".length - 1
            let depth = 1
            let pos = braceOpen + 1
            while (pos < t.length && depth > 0) {
                if (t[pos] === "{") depth++
                else if (t[pos] === "}") depth--
                pos++
            }
            let innerStart = braceOpen + 1
            let innerEnd = pos - 1
            let inner = t.substring(innerStart, innerEnd)
            let outMatch = inner.match(/output\s*=\s*"([^"]*)"/)
            if (outMatch && outMatch[1] === outputName) {
                return { innerStart, innerEnd }
            }
            searchFrom = pos
        }
    }

    // Generic field setter — locates outputName's block, replaces the
    // field if present, appends it if the field doesn't exist yet in that
    // block, or appends a whole new hl.monitor block if this output has
    // no block at all yet (e.g. a newly connected second monitor).
    function _writeField(outputName, fieldName, newValueLiteral) {
        root._debouncedWrite(() => {
            let t = root.rawText
            let block = root._findMonitorBlock(t, outputName)
            if (!block) {
                let newBlock = "\n\nhl.monitor({\n    output   = \"" + outputName + "\",\n    " + fieldName + " = " + newValueLiteral + ",\n})\n"
                root._write(t.replace(/\s*$/, "") + newBlock)
                return
            }
            let inner = t.substring(block.innerStart, block.innerEnd)
            let re = new RegExp(fieldName + "(\\s*)=(\\s*)[^,]*,")
            let newInner = re.test(inner)
                ? inner.replace(re, fieldName + "$1=$2" + newValueLiteral + ",")
                : inner.replace(/\s*$/, "") + "\n    " + fieldName + " = " + newValueLiteral + ",\n"
            root._write(t.substring(0, block.innerStart) + newInner + t.substring(block.innerEnd))
        })
    }

    function setMode(outputName, modeString) {
        root._writeField(outputName, "mode", "\"" + modeString + "\"")
    }

    function setScale(outputName, scaleValue) {
        root._writeField(outputName, "scale", scaleValue)
    }

    function _write(newText) {
        let marker = "QS_MONITORS_EOF_" + Date.now()
        writeProc.command = ["sh", "-c",
            "cat > " + root.monitorsPath + " << '" + marker + "'\n" + newText + "\n" + marker]
        writeProc.running = true
        reloadProc.command = ["hyprctl", "reload"]
        reloadProc.running = true
        root.rawText = newText
        // Re-query hyprctl shortly after, so the UI reflects Hyprland's
        // actual resulting state (it may adjust/reject a requested mode).
        refreshDelayTimer.restart()
    }

    Timer {
        id: refreshDelayTimer
        interval: 400
        repeat: false
        onTriggered: queryProc.running = true
    }

    Component.onCompleted: refresh()
}