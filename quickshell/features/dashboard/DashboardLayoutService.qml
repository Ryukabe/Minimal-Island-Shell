// features/dashboard/DashboardLayoutService.qml — where each Dashboard component sits on the grid.
// Columns are a setting; rows are not stored. The panel is as tall as the lowest component
// (like Control Center), so there is one source of truth for the Dashboard size: this layout.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property int columns: 12

    // The panel can grow down to this many rows; components cannot be placed below it.
    readonly property int maxRows: 10
    // Size of one grid cell. Panel size = columns / rows of these plus the gaps and padding.
    readonly property real cellWidth: 56
    readonly property real cellHeight: 60

    readonly property var manageableTypes: [
        "quicknote", "media", "stats", "calendar", "countdown", "study", "checklist", "sysinfo"
    ]
    readonly property var typeDisplayNames: ({
        quicknote: "Quick note", media: "Media", stats: "System stats", calendar: "Calendar",
        countdown: "Countdown", study: "Study tracker", checklist: "Checklist", sysinfo: "System info"
    })
    // Smallest size (in cells) each component still lays out properly at.
    readonly property var minSizes: ({
        quicknote: { c: 3, r: 3 }, media: { c: 3, r: 2 }, stats: { c: 3, r: 3 }, calendar: { c: 3, r: 3 },
        countdown: { c: 3, r: 3 }, study: { c: 3, r: 3 }, checklist: { c: 3, r: 3 }, sysinfo: { c: 3, r: 3 }
    })
    // Size a component gets when added, for those that are not in defaultLayout.
    readonly property var extraSizes: ({
        countdown: { c: 4, r: 3 }, study: { c: 4, r: 3 }, checklist: { c: 4, r: 4 }, sysinfo: { c: 4, r: 3 }
    })
    readonly property var defaultLayout: [
        { tileId: "media", type: "media", col: 0, row: 0, colSpan: 4, rowSpan: 3 },
        { tileId: "calendar", type: "calendar", col: 0, row: 3, colSpan: 4, rowSpan: 3 },
        { tileId: "quicknote", type: "quicknote", col: 4, row: 0, colSpan: 4, rowSpan: 6 },
        { tileId: "stats", type: "stats", col: 8, row: 0, colSpan: 4, rowSpan: 6 }
    ]

    property ListModel layoutModel: ListModel {}
    property var undoStack: []
    // Bumps on every change so bindings that call hasType() / tileInfo() / rowCount() re-evaluate.
    property int revision: 0
    property bool _loaded: false

    readonly property string _home: Quickshell.env("HOME")

    property FileView layoutFile: FileView {
        path: root._home + "/.config/quickshell/state/dashboard-layout.json"
        printErrors: false
        onLoaded: root._load(text())
        onLoadFailed: root._firstRun()
    }

    property Timer saveTimer: Timer {
        interval: 300
        onTriggered: root.layoutFile.setText(JSON.stringify(root._state(), null, 2))
    }

    // ---------- small helpers ----------
    function _clamp(v, lo, hi) { return Math.max(lo, Math.min(hi, v)) }
    function minFor(type) { return root.minSizes[type] || { c: 1, r: 1 } }

    function indexForId(tileId) {
        for (var i = 0; i < root.layoutModel.count; i++) {
            if (root.layoutModel.get(i).tileId === tileId) return i
        }
        return -1
    }

    function hasType(type) {
        root.revision
        return root.indexForId(type) >= 0
    }

    function tileInfo(tileId) {
        root.revision
        var idx = root.indexForId(tileId)
        if (idx < 0) return null
        var t = root.layoutModel.get(idx)
        return { tileId: t.tileId, type: t.type, col: t.col, row: t.row, colSpan: t.colSpan, rowSpan: t.rowSpan }
    }

    // How many rows the components use (at least 1). This is what sizes the panel.
    function rowCount() {
        root.revision
        var maxRow = 0
        for (var i = 0; i < root.layoutModel.count; i++) {
            var t = root.layoutModel.get(i)
            maxRow = Math.max(maxRow, t.row + t.rowSpan)
        }
        return Math.max(1, maxRow)
    }

    function _snapshot() {
        var arr = []
        for (var i = 0; i < root.layoutModel.count; i++) {
            var t = root.layoutModel.get(i)
            arr.push({ tileId: t.tileId, type: t.type, col: t.col, row: t.row, colSpan: t.colSpan, rowSpan: t.rowSpan })
        }
        return arr
    }

    function _state() { return { columns: root.columns, tiles: root._snapshot() } }
    function _touch() { root.revision++ }
    function _changed() { root._touch(); root.saveTimer.restart() }

    function _restore(tiles) {
        root.layoutModel.clear()
        for (var i = 0; i < tiles.length; i++) root.layoutModel.append(tiles[i])
        root._touch()
    }

    function _rects(ignoreId) {
        var arr = []
        for (var i = 0; i < root.layoutModel.count; i++) {
            var t = root.layoutModel.get(i)
            if (t.tileId === ignoreId) continue
            arr.push({ col: t.col, row: t.row, colSpan: t.colSpan, rowSpan: t.rowSpan })
        }
        return arr
    }

    function _overlaps(a, b) {
        return a.col < b.col + b.colSpan && a.col + a.colSpan > b.col &&
               a.row < b.row + b.rowSpan && a.row + a.rowSpan > b.row
    }

    function _isFree(rect, others) {
        for (var i = 0; i < others.length; i++) {
            if (root._overlaps(rect, others[i])) return false
        }
        return true
    }

    // Free spot closest to (refCol, refRow), or null when the size does not fit anywhere.
    function _nearest(others, cs, rs, refCol, refRow) {
        var best = null
        var bestCost = Infinity
        for (var r = 0; r <= root.maxRows - rs; r++) {
            for (var c = 0; c <= root.columns - cs; c++) {
                if (!root._isFree({ col: c, row: r, colSpan: cs, rowSpan: rs }, others)) continue
                var cost = Math.abs(c - refCol) + Math.abs(r - refRow)
                if (cost < bestCost) { bestCost = cost; best = { col: c, row: r } }
            }
        }
        return best
    }

    function _firstFit(others, cs, rs) {
        for (var r = 0; r <= root.maxRows - rs; r++) {
            for (var c = 0; c <= root.columns - cs; c++) {
                if (root._isFree({ col: c, row: r, colSpan: cs, rowSpan: rs }, others)) return { col: c, row: r }
            }
        }
        return null
    }

    // Moves every tile that overlaps the anchor tile to the free spot nearest (refCol, refRow).
    // Returns false when one of them has nowhere to go (the caller then rolls the change back).
    function _displace(anchorId, refCol, refRow) {
        var ai = root.indexForId(anchorId)
        if (ai < 0) return true
        var a = root.layoutModel.get(ai)
        var arect = { col: a.col, row: a.row, colSpan: a.colSpan, rowSpan: a.rowSpan }

        var moved = []
        var movedIds = {}
        for (var i = 0; i < root.layoutModel.count; i++) {
            if (i === ai) continue
            var t = root.layoutModel.get(i)
            if (root._overlaps(arect, t)) {
                moved.push({ id: t.tileId, col: t.col, row: t.row, cs: t.colSpan, rs: t.rowSpan })
                movedIds[t.tileId] = true
            }
        }
        if (moved.length === 0) return true

        moved.sort(function (x, y) { return (x.row - y.row) || (x.col - y.col) })

        // Everything that stays put is an obstacle, including the anchor.
        var fixed = []
        for (var j = 0; j < root.layoutModel.count; j++) {
            var o = root.layoutModel.get(j)
            if (movedIds[o.tileId]) continue
            fixed.push({ col: o.col, row: o.row, colSpan: o.colSpan, rowSpan: o.rowSpan })
        }

        for (var k = 0; k < moved.length; k++) {
            var m = moved[k]
            var spot = root._nearest(fixed, m.cs, m.rs, refCol, refRow)
            if (!spot) return false
            var idx = root.indexForId(m.id)
            root.layoutModel.set(idx, { col: spot.col, row: spot.row })
            fixed.push({ col: spot.col, row: spot.row, colSpan: m.cs, rowSpan: m.rs })
        }
        return true
    }

    // Makes every tile valid for the current grid: inside the bounds, at least its minimum size,
    // not overlapping. A tile that cannot fit anywhere is dropped (it shows up under "Components" again).
    function normalize() {
        var items = root._snapshot()
        items.sort(function (a, b) { return (a.row - b.row) || (a.col - b.col) })
        var placed = []
        root.layoutModel.clear()
        for (var i = 0; i < items.length; i++) {
            var t = items[i]
            if (root.manageableTypes.indexOf(t.type) < 0) continue
            var m = root.minFor(t.type)
            var cs = Math.max(m.c, Math.min(t.colSpan, root.columns))
            var rs = Math.max(m.r, Math.min(t.rowSpan, root.maxRows))
            if (cs > root.columns || rs > root.maxRows) continue
            var col = root._clamp(t.col, 0, root.columns - cs)
            var row = root._clamp(t.row, 0, root.maxRows - rs)
            if (!root._isFree({ col: col, row: row, colSpan: cs, rowSpan: rs }, placed)) {
                var spot = root._nearest(placed, cs, rs, col, row)
                if (!spot) {
                    cs = m.c
                    rs = m.r
                    spot = root._nearest(placed, cs, rs, col, row)
                }
                if (!spot) continue
                col = spot.col
                row = spot.row
            }
            placed.push({ col: col, row: row, colSpan: cs, rowSpan: rs })
            root.layoutModel.append({ tileId: t.tileId, type: t.type, col: col, row: row, colSpan: cs, rowSpan: rs })
        }
        root._touch()
    }

    function _apply(state) {
        root.columns = state.columns
        root.layoutModel.clear()
        for (var i = 0; i < state.tiles.length; i++) {
            var t = state.tiles[i]
            root.layoutModel.append({
                tileId: String(t.tileId), type: String(t.type),
                col: Math.round(Number(t.col)) || 0, row: Math.round(Number(t.row)) || 0,
                colSpan: Math.round(Number(t.colSpan)) || 1, rowSpan: Math.round(Number(t.rowSpan)) || 1
            })
        }
        root.normalize()
    }

    function _load(txt) {
        var data
        try {
            data = JSON.parse(txt)
        } catch (e) {
            console.warn("DashboardLayoutService: bad saved layout, using defaults", e)
            root._firstRun()
            return
        }
        if (!data || !Array.isArray(data.tiles)) {
            root._firstRun()
            return
        }
        // An older saved file may still contain "rows"; it is ignored now.
        root._apply({
            columns: root._clamp(Math.round(Number(data.columns)) || 12, 6, 20),
            tiles: data.tiles
        })
        root._loaded = true
    }

    function _firstRun() {
        root._apply({ columns: 12, tiles: root.defaultLayout })
        root._loaded = true
        root._changed()
    }

    // ---------- undo ----------
    function pushUndoSnapshot() {
        var stack = root.undoStack.slice()
        stack.push(root._state())
        if (stack.length > 20) stack.shift()
        root.undoStack = stack
    }

    function undo() {
        if (root.undoStack.length === 0) return
        var stack = root.undoStack.slice()
        var prev = stack.pop()
        root.undoStack = stack
        root._apply(prev)
        root._changed()
    }

    // ---------- editing ----------
    // Callers push an undo snapshot first. A tile dropped onto others pushes them to the nearest
    // free spot; when that is impossible nothing changes and false is returned.
    function setRect(tileId, col, row, cs, rs) {
        var idx = root.indexForId(tileId)
        if (idx < 0) return false
        var t = root.layoutModel.get(idx)
        var m = root.minFor(t.type)
        if (cs < m.c || rs < m.r || col < 0 || row < 0 || col + cs > root.columns || row + rs > root.maxRows) return false
        if (t.col === col && t.row === row && t.colSpan === cs && t.rowSpan === rs) return true

        var before = root._snapshot()
        var oldCol = t.col
        var oldRow = t.row
        root.layoutModel.set(idx, { col: col, row: row, colSpan: cs, rowSpan: rs })
        if (!root._displace(tileId, oldCol, oldRow)) {
            root._restore(before)
            return false
        }
        root._changed()
        return true
    }

    function moveTile(tileId, col, row) {
        var idx = root.indexForId(tileId)
        if (idx < 0) return false
        var t = root.layoutModel.get(idx)
        col = root._clamp(col, 0, root.columns - t.colSpan)
        row = root._clamp(row, 0, root.maxRows - t.rowSpan)
        return root.setRect(tileId, col, row, t.colSpan, t.rowSpan)
    }

    // Keeps the top-left corner and clamps the request to the minimum size and the grid.
    function resizeTile(tileId, cs, rs) {
        var idx = root.indexForId(tileId)
        if (idx < 0) return false
        var t = root.layoutModel.get(idx)
        var m = root.minFor(t.type)
        cs = Math.max(m.c, Math.min(cs, root.columns - t.col))
        rs = Math.max(m.r, Math.min(rs, root.maxRows - t.row))
        return root.setRect(tileId, t.col, t.row, cs, rs)
    }

    function defaultSizeForType(type) {
        for (var i = 0; i < root.defaultLayout.length; i++) {
            var d = root.defaultLayout[i]
            if (d.type === type) return { c: d.colSpan, r: d.rowSpan }
        }
        if (root.extraSizes[type]) return root.extraSizes[type]
        var m = root.minFor(type)
        return { c: m.c, r: m.r }
    }

    // Component types that are not on the Dashboard right now.
    function unplacedTypes() {
        root.revision
        var out = []
        for (var i = 0; i < root.manageableTypes.length; i++) {
            if (root.indexForId(root.manageableTypes[i]) < 0) out.push(root.manageableTypes[i])
        }
        return out
    }

    function addTile(type) {
        if (root.indexForId(type) >= 0) return true
        var m = root.minFor(type)
        var sizes = []
        var d = root.defaultSizeForType(type)
        if (d.c <= root.columns && d.r <= root.maxRows) sizes.push({ c: d.c, r: d.r })
        sizes.push({ c: m.c, r: m.r })
        var others = root._rects("")
        for (var s = 0; s < sizes.length; s++) {
            var spot = root._firstFit(others, sizes[s].c, sizes[s].r)
            if (!spot) continue
            root.pushUndoSnapshot()
            root.layoutModel.append({ tileId: type, type: type, col: spot.col, row: spot.row, colSpan: sizes[s].c, rowSpan: sizes[s].r })
            root._changed()
            return true
        }
        return false
    }

    function removeTile(tileId) {
        var idx = root.indexForId(tileId)
        if (idx < 0) return
        root.pushUndoSnapshot()
        root.layoutModel.remove(idx, 1)
        root._changed()
    }

    function setColumns(cols) {
        root.pushUndoSnapshot()
        root.columns = cols
        root.normalize()
        root._changed()
    }

    function resetToDefault() {
        if (root.layoutModel.count > 0) root.pushUndoSnapshot()
        root._apply({ columns: 12, tiles: root.defaultLayout })
        root._changed()
    }
}