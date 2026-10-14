// services/ClockLayoutService.qml — order of the items inside the bar clock.
// Stores ORDER ONLY. Whether an item shows is still decided by the existing
// ShellState clock* toggles (single source of truth for visibility).
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    // Every item type the clock knows. Add new types here AND in Clock.qml.
    readonly property var defaultOrder: ["workspaces", "visualizer", "date", "time", "timer", "recording"]

    readonly property var typeDisplayNames: ({
        workspaces: "Workspaces",
        visualizer: "Visualizer",
        date: "Date",
        time: "Time",
        timer: "Timer icon",
        recording: "Recording dot"
    })

    property ListModel layoutModel: ListModel {}
    property var undoStack: []

    readonly property string _home: Quickshell.env("HOME")

    property FileView layoutFile: FileView {
        path: root._home + "/.config/quickshell/state/clock-layout.json"
        printErrors: false
        onLoaded: root.loadFromJson(text())
        // No saved file yet: keep the defaults filled in at startup.
        onLoadFailed: root.loadFromJson("")
    }

    Component.onCompleted: {
        if (layoutModel.count === 0) _fill(defaultOrder)
    }

    function _fill(ids) {
        layoutModel.clear()
        for (var i = 0; i < ids.length; i++) layoutModel.append({ itemId: ids[i] })
    }

    function snapshot() {
        var arr = []
        for (var i = 0; i < layoutModel.count; i++) arr.push(layoutModel.get(i).itemId)
        return arr
    }

    function loadFromJson(jsonText) {
        var ids = []
        if (jsonText && jsonText.trim() !== "") {
            try {
                var parsed = JSON.parse(jsonText)
                if (Array.isArray(parsed)) ids = parsed
            } catch (e) {
                console.warn("ClockLayoutService: bad saved layout, using defaults", e)
            }
        }

        // Keep known types once each, drop the rest, then append any type the file
        // does not mention yet, so items added in future updates always appear.
        var seen = {}
        var clean = []
        for (var i = 0; i < ids.length; i++) {
            if (defaultOrder.indexOf(ids[i]) >= 0 && !seen[ids[i]]) {
                seen[ids[i]] = true
                clean.push(ids[i])
            }
        }
        for (var j = 0; j < defaultOrder.length; j++) {
            if (!seen[defaultOrder[j]]) clean.push(defaultOrder[j])
        }

        _fill(clean)
        if (JSON.stringify(clean) !== JSON.stringify(ids)) saveLayout()
    }

    function saveLayout() {
        layoutFile.setText(JSON.stringify(snapshot(), null, 2))
    }

    function pushUndoSnapshot() {
        var stack = undoStack.slice()
        stack.push(snapshot())
        if (stack.length > 20) stack.shift()
        undoStack = stack
    }

    function undo() {
        if (undoStack.length === 0) return
        var stack = undoStack.slice()
        var prev = stack.pop()
        undoStack = stack
        _fill(prev)
        saveLayout()
    }

    function resetToDefault() {
        if (layoutModel.count > 0) pushUndoSnapshot()
        _fill(defaultOrder)
        saveLayout()
    }

    function indexForId(itemId) {
        for (var i = 0; i < layoutModel.count; i++) {
            if (layoutModel.get(i).itemId === itemId) return i
        }
        return -1
    }

    function moveItem(from, to) {
        to = Math.max(0, Math.min(layoutModel.count - 1, to))
        if (from < 0 || from >= layoutModel.count || from === to) return
        pushUndoSnapshot()
        layoutModel.move(from, to, 1)
        saveLayout()
    }

    function moveItemBy(itemId, delta) {
        var idx = indexForId(itemId)
        if (idx >= 0) moveItem(idx, idx + delta)
    }

    // Used only by the settings editor to dim items that are switched off.
    function isEnabled(type) {
        switch (type) {
            case "workspaces": return ShellState.clockShowWorkspaces
            case "visualizer": return ShellState.clockShowVisualizer
            case "date": return ShellState.clockDateStyle > 0
            case "time": return true
            case "timer": return ShellState.clockShowTimerIcon
            case "recording": return ShellState.clockShowRecordingIndicator
            default: return true
        }
    }
}