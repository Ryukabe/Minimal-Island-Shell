// features/dashboard/DashboardLayoutService.qml — where each Dashboard component sits on the grid.
// The grid size (columns x rows) lives here too, in the same file, so there is one source of truth.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property int columns: 12
    property int rows: 6

    readonly property var manageableTypes: ["quicknote", "media", "stats", "calendar"]
    readonly property var typeDisplayNames: ({
        quicknote: "Quick note", media: "Media", stats: "System stats", calendar: "Calendar"
    })
    // Smallest size (in cells) each component still lays out properly at.
    readonly property var minSizes: ({
        quicknote: { c: 3, r: 3 }, media: { c: 3, r: 2 }, stats: { c: 3, r: 3 }, calendar: { c: 3, r: 3 }
    })
    readonly property var defaultLayout: [
        { tileId: "media", type: "media", col: 0, row: 0, colSpan: 4, rowSpan: 3 },
        { tileId: "calendar", type: "calendar", col: 0, row: 3, colSpan: 4, rowSpan: 3 },
        { tileId: "quicknote", type: "quicknote", col: 4, row: 0, colSpan: 4, rowSpan: 6 },
        { tileId: "stats", type: "stats", col: 8, row: 0, colSpan: 4, rowSpan: 6 }
    ]

    property ListModel layoutModel: ListModel {}
    property var undoStack: []
    // Bumps on every change so bindings that call hasType() / tileInfo() re-evaluate.
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

    function _snapshot() {
        var arr = []
        for (var i = 0; i < root.layoutModel.count; i++) {
            var t = root.layoutModel.get(i)
            arr.push({ tileId: t.tileId, type: t.type, col: t.col, row: t.row, colSpan: t.colSpan, rowSpan: t.rowSpan })
        }
        return arr
    }

    function _state() { return { columns: root.columns, rows: root.rows, tiles: root._snapshot() } }
    function _touch() { root.revision++ }
    function _changed() { root._touch(); root.saveTimer.restart() }

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
        for (var r = 0; r <= root.rows - rs; r++) {
            for (var c = 0; c <= root.columns - cs; c++) {
                if (!root._isFree({ col: c, row: r, colSpan: cs, rowSpan: rs }, others)) continue
                var cost = Math.abs(c - refCol) + Math.abs(r - refRow)
                if (cost < bestCost) { bestCost = cost; best = { col: c, row: r } }
            }
        }
        return best
    }

    function _firstFit(others, cs, rs) {
        for (var r = 0; r <= root.rows - rs; r++) {
            for (var c = 0; c <= root.columns - cs; c++) {
                if (root._isFree({ col: c, row: r, colSpan: cs, rowSpan: rs }, others)) return { col: c, row: r }
            }
        }
        return null
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
            var rs = Math.max(m.r, Math.min(t.rowSpan, root.rows))
            if (cs > root.columns || rs > root.rows) continue
            var col = root._clamp(t.col, 0, root.columns - cs)
            var row = root._clamp(t.row, 0, root.rows - rs)
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
        root.rows = state.rows
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
        root._apply({
            columns: root._clamp(Math.round(Number(data.columns)) || 12, 6, 20),
            rows: root._clamp(Math.round(Number(data.rows)) || 6, 3, 10),
            tiles: data.tiles
        })
        root._loaded = true
    }

    function _firstRun() {
        root._apply({ columns: 12, rows: 6, tiles: root.defaultLayout })
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
    // Callers push an undo snapshot first; these only change the layout when the result is valid.
    function setRect(tileId, col, row, cs, rs) {
        var idx = root.indexForId(tileId)
        if (idx < 0) return false
        var t = root.layoutModel.get(idx)
        var m = root.minFor(t.type)
        if (cs < m.c || rs < m.r || col < 0 || row < 0 || col + cs > root.columns || row + rs > root.rows) return false
        if (!root._isFree({ col: col, row: row, colSpan: cs, rowSpan: rs }, root._rects(tileId))) return false
        if (t.col === col && t.row === row && t.colSpan === cs && t.rowSpan === rs) return true
        root.layoutModel.set(idx, { col: col, row: row, colSpan: cs, rowSpan: rs })
        root._changed()
        return true
    }

    function moveTile(tileId, col, row) {
        var idx = root.indexForId(tileId)
        if (idx < 0) return false
        var t = root.layoutModel.get(idx)
        col = root._clamp(col, 0, root.columns - t.colSpan)
        row = root._clamp(row, 0, root.rows - t.rowSpan)
        if (root.setRect(tileId, col, row, t.colSpan, t.rowSpan)) return true
        var spot = root._nearest(root._rects(tileId), t.colSpan, t.rowSpan, col, row)
        if (!spot) return false
        return root.setRect(tileId, spot.col, spot.row, t.colSpan, t.rowSpan)
    }

    // Keeps the top-left corner; shrinks the request until it is valid.
    function resizeTile(tileId, cs, rs) {
        var idx = root.indexForId(tileId)
        if (idx < 0) return false
        var t = root.layoutModel.get(idx)
        var m = root.minFor(t.type)
        cs = Math.min(cs, root.columns - t.col)
        rs = Math.min(rs, root.rows - t.row)
        var others = root._rects(tileId)
        var best = null
        var bestCost = Infinity
        for (var c = cs; c >= m.c; c--) {
            for (var r = rs; r >= m.r; r--) {
                if (!root._isFree({ col: t.col, row: t.row, colSpan: c, rowSpan: r }, others)) continue
                var cost = (cs - c) + (rs - r)
                if (cost < bestCost) { bestCost = cost; best = { c: c, r: r } }
            }
        }
        if (!best) return false
        return root.setRect(tileId, t.col, t.row, best.c, best.r)
    }

    function addTile(type) {
        if (root.indexForId(type) >= 0) return true
        var m = root.minFor(type)
        var sizes = []
        for (var i = 0; i < root.defaultLayout.length; i++) {
            var d = root.defaultLayout[i]
            if (d.type === type && d.colSpan <= root.columns && d.rowSpan <= root.rows) {
                sizes.push({ c: d.colSpan, r: d.rowSpan })
            }
        }
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

    function setGrid(cols, rws) {
        root.pushUndoSnapshot()
        root.columns = cols
        root.rows = rws
        root.normalize()
        root._changed()
    }

    function resetToDefault() {
        if (root.layoutModel.count > 0) root.pushUndoSnapshot()
        root._apply({ columns: 12, rows: 6, tiles: root.defaultLayout })
        root._changed()
    }
}