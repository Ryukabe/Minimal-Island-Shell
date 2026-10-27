// features/bar/ClockLayoutService.qml — which items the bar clock shows, and in what order.
// The layout IS the visibility: an item in the list is on the bar (while its own runtime
// condition holds, e.g. the visualizer only while music plays); an item not in the list is off.
// Saved as { "version": 2, "items": [...] } in state/clock-layout.json.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    // Every item type the clock knows. A new type needs an entry here, in typeDisplayNames,
    // and in Clock.qml (itemShown + componentFor). It starts off until the user adds it.
    readonly property var allTypes: ["workspaces", "visualizer", "date", "time", "timer", "privacy", "recording"]

    // What a fresh install starts with (Date stays off until it is added).
    readonly property var defaultOrder: ["workspaces", "visualizer", "time", "timer", "privacy", "recording"]

    // Items that cannot be taken off the bar.
    readonly property var requiredTypes: ["time"]

    readonly property var typeDisplayNames: ({
        workspaces: "Workspaces",
        visualizer: "Visualizer",
        date: "Date",
        time: "Time",
        timer: "Timer icon",
        privacy: "Mic & camera dot",
        recording: "Recording dot"
    })

    // Placed items only, in bar order.
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
        var ids = null
        var legacy = false
        if (jsonText && jsonText.trim() !== "") {
            try {
                var parsed = JSON.parse(jsonText)
                if (Array.isArray(parsed)) {
                    // Old format: a bare array that listed every item (visibility lived in
                    // the ShellState clock* toggles).
                    ids = parsed
                    legacy = true
                } else if (parsed && Array.isArray(parsed.items)) {
                    ids = parsed.items
                }
            } catch (e) {
                console.warn("ClockLayoutService: bad saved layout, using defaults", e)
            }
        }

        if (ids === null) {
            _fill(defaultOrder)
            return
        }

        // Keep known types once each. Types missing from the file stay off.
        var seen = {}
        var clean = []
        for (var i = 0; i < ids.length; i++) {
            var id = ids[i]
            if (allTypes.indexOf(id) < 0 || seen[id]) continue
            // Date used to be driven by its own setting and is off by default, so a migrated
            // layout starts without it.
            if (legacy && id === "date") continue
            seen[id] = true
            clean.push(id)
        }

        // Migration: the privacy dot had no slot in the old layout, so slot it in before the
        // recording dot.
        if (legacy && !seen["privacy"]) {
            var rec = clean.indexOf("recording")
            if (rec >= 0) clean.splice(rec, 0, "privacy")
            else clean.push("privacy")
        }

        for (var r = 0; r < requiredTypes.length; r++) {
            if (clean.indexOf(requiredTypes[r]) < 0) clean.push(requiredTypes[r])
        }

        _fill(clean)
        if (legacy || JSON.stringify(clean) !== JSON.stringify(ids)) saveLayout()
    }

    function saveLayout() {
        layoutFile.setText(JSON.stringify({ version: 2, items: snapshot() }, null, 2))
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

    function canRemove(type) {
        return requiredTypes.indexOf(type) < 0
    }

    // Puts an item on the bar, at the end of the row.
    function addItem(type) {
        if (allTypes.indexOf(type) < 0 || indexForId(type) >= 0) return
        pushUndoSnapshot()
        layoutModel.append({ itemId: type })
        saveLayout()
    }

    // Puts an item on the bar at a given position (0 = first).
    function addItemAt(type, index) {
        if (allTypes.indexOf(type) < 0 || indexForId(type) >= 0) return
        pushUndoSnapshot()
        layoutModel.insert(Math.max(0, Math.min(layoutModel.count, index)), { itemId: type })
        saveLayout()
    }

    function removeItem(type) {
        var idx = indexForId(type)
        if (idx < 0 || !canRemove(type)) return
        pushUndoSnapshot()
        layoutModel.remove(idx)
        saveLayout()
    }

    // Types that are currently off, in the order of allTypes.
    function unplacedTypes() {
        var out = []
        for (var i = 0; i < allTypes.length; i++) {
            if (indexForId(allTypes[i]) < 0) out.push(allTypes[i])
        }
        return out
    }
}
