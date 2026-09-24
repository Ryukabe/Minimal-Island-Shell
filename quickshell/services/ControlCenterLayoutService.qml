pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../styles"

QtObject {
    id: root

    property int columns: 6
    property real cellSpacing: Dimens.spacingSm

    property var universalSizes: [
        {c:1,r:1}, {c:1,r:2}, {c:1,r:3}, {c:1,r:4},
        {c:2,r:1}, {c:2,r:2},
        {c:3,r:1}, {c:3,r:2},
        {c:4,r:2}, {c:4,r:4},
        {c:6,r:2}, {c:6,r:4}, {c:6,r:5}, {c:6,r:6}
    ]

    property var allowedSizes: ({
        "wifi": universalSizes,
        "bluetooth": universalSizes,
        "nightlight": universalSizes,
        "focus": universalSizes,
        "airplane": universalSizes,
        "caffeine": universalSizes,
        "recording": universalSizes,
        "powerprofile": universalSizes,
        "lightmode": universalSizes,
        "volume": universalSizes,
        "brightness": universalSizes,
        "media": universalSizes,
        "notifications": universalSizes
    })

    // Types with a real ToggleTile component wired in ControlGrid's Loader
    // switch. Only these appear in the Add-a-control tray.
    // ("notifications" is excluded: it has layout data but no rendering case yet.)
    property var manageableTypes: [
        "wifi", "bluetooth", "nightlight", "focus", "airplane", "caffeine",
        "recording", "powerprofile", "lightmode", "volume", "brightness", "media"
    ]

    property var typeDisplayNames: ({
        wifi: "Wi-Fi",
        bluetooth: "Bluetooth",
        nightlight: "Night Light",
        focus: "Focus",
        airplane: "Airplane Mode",
        caffeine: "Caffeine",
        recording: "Recording",
        powerprofile: "Power Profile",
        lightmode: "Light Mode",
        volume: "Volume",
        brightness: "Brightness",
        media: "Media"
    })

    property var defaultLayout: [
        { tileId: "wifi", type: "wifi", col: 0, row: 0, colSpan: 1, rowSpan: 1 },
        { tileId: "bluetooth", type: "bluetooth", col: 1, row: 0, colSpan: 1, rowSpan: 1 },
        { tileId: "nightlight", type: "nightlight", col: 2, row: 0, colSpan: 1, rowSpan: 1 },
        { tileId: "focus", type: "focus", col: 3, row: 0, colSpan: 1, rowSpan: 1 },
        { tileId: "airplane", type: "airplane", col: 4, row: 0, colSpan: 1, rowSpan: 1 },
        { tileId: "caffeine", type: "caffeine", col: 5, row: 0, colSpan: 1, rowSpan: 1 },
        { tileId: "recording", type: "recording", col: 0, row: 1, colSpan: 1, rowSpan: 1 },
        { tileId: "powerprofile", type: "powerprofile", col: 1, row: 1, colSpan: 1, rowSpan: 1 },
        { tileId: "lightmode", type: "lightmode", col: 2, row: 1, colSpan: 1, rowSpan: 1 },
        { tileId: "media", type: "media", col: 3, row: 1, colSpan: 3, rowSpan: 2 },
        { tileId: "volume", type: "volume", col: 0, row: 2, colSpan: 3, rowSpan: 1 },
        { tileId: "brightness", type: "brightness", col: 0, row: 3, colSpan: 3, rowSpan: 1 },
        { tileId: "notifications", type: "notifications", col: 3, row: 3, colSpan: 3, rowSpan: 2 }
    ]

    property ListModel layoutModel: ListModel {}

    // Undo history: array of full layout snapshots, most recent last.
    // Reassigned (never mutated in place) so bindings on undoStack.length
    // update reactively.
    property var undoStack: []

    property FileView layoutFile: FileView {
        id: layoutFile
        path: Quickshell.env("HOME") + "/.config/quickshell/control-center-layout.json"
        printErrors: false
        onLoaded: root.loadFromJson(text())
        onLoadFailed: (error) => root.resetToDefault()
    }

    // ---- Load / save ----

    function resetToDefault() {
        if (layoutModel.count > 0) pushUndoSnapshot()
        layoutModel.clear()
        for (var i = 0; i < defaultLayout.length; i++) {
            layoutModel.append(defaultLayout[i])
        }
        saveLayout()
    }

    // FIX: loads exactly what was saved. It no longer re-adds default tiles
    // that are missing from the file, which is what brought removed
    // controls back after every restart.
    function loadFromJson(jsonText) {
        if (!jsonText || jsonText.trim() === "") {
            resetToDefault()
            return
        }

        var arr
        try {
            arr = JSON.parse(jsonText)
        } catch (e) {
            console.warn("ControlCenterLayoutService: bad saved layout, using defaults", e)
            resetToDefault()
            return
        }

        if (!Array.isArray(arr)) {
            console.warn("ControlCenterLayoutService: saved layout is not a list, using defaults")
            resetToDefault()
            return
        }

        layoutModel.clear()
        for (var i = 0; i < arr.length; i++) {
            layoutModel.append(arr[i])
        }
        if (healOverlaps()) saveLayout()  
    }

    function snapshotLayout() {
        var arr = []
        for (var i = 0; i < layoutModel.count; i++) {
            var t = layoutModel.get(i)
            arr.push({ tileId: t.tileId, type: t.type, col: t.col, row: t.row, colSpan: t.colSpan, rowSpan: t.rowSpan })
        }
        return arr
    }

    function serializeLayout() {
        return JSON.stringify(snapshotLayout(), null, 2)
    }

    function saveLayout() {
        healOverlaps()  
        layoutFile.setText(serializeLayout())
    }

    // ---- Undo ----

    function pushUndoSnapshot() {
        var stack = undoStack.slice()
        stack.push(snapshotLayout())
        if (stack.length > 20) stack.shift()
        undoStack = stack
    }

    function undo() {
        if (undoStack.length === 0) return
        var stack = undoStack.slice()
        var prev = stack.pop()
        undoStack = stack

        layoutModel.clear()
        for (var i = 0; i < prev.length; i++) {
            layoutModel.append(prev[i])
        }
        saveLayout()
    }

    // ---- Helpers ----

    function rowCount() {
        var maxRow = 0
        for (var i = 0; i < layoutModel.count; i++) {
            var t = layoutModel.get(i)
            maxRow = Math.max(maxRow, t.row + t.rowSpan)
        }
        return Math.max(1, maxRow)
    }

    function indexForId(tileId) {
        for (var i = 0; i < layoutModel.count; i++) {
            if (layoutModel.get(i).tileId === tileId) return i
        }
        return -1
    }

    function rectsOverlap(a, b) {
        return a.col < b.col + b.colSpan && a.col + a.colSpan > b.col &&
               a.row < b.row + b.rowSpan && a.row + a.rowSpan > b.row
    }

    // ---- Swap / displacement logic ----

    // True if `rect` overlaps no tile, ignoring any tile whose id is a key
    // in the `ignore` map.
    function isFree(rect, ignore) {
        for (var i = 0; i < layoutModel.count; i++) {
            var t = layoutModel.get(i)
            if (ignore && ignore[t.tileId]) continue
            if (rectsOverlap(rect, t)) return false
        }
        return true
    }

    // Free spot for `tileId` (same size) closest to (refCol, refRow), in any
    // direction. Ties go to the earliest spot in reading order.
    function nearestFreeSpot(tileId, refCol, refRow, ignore) {
        var idx = indexForId(tileId)
        var t = layoutModel.get(idx)
        var cs = t.colSpan
        var rs = t.rowSpan
        var maxRow = rowCount() + rs

        var best = null
        var bestCost = Infinity

        for (var r = 0; r <= maxRow; r++) {
            for (var c = 0; c <= columns - cs; c++) {
                var rect = { col: c, row: r, colSpan: cs, rowSpan: rs }
                if (!isFree(rect, ignore)) continue
                var cost = Math.abs(c - refCol) + Math.abs(r - refRow)
                if (cost < bestCost) {
                    bestCost = cost
                    best = { col: c, row: r }
                }
            }
        }

        // Grid completely full, so use a fresh row below everything.
        if (!best) best = { col: 0, row: maxRow + 1 }
        return best
    }

    // The anchor tile stays where it is. Every tile it overlaps is moved to
    // the free spot nearest (refCol, refRow), the anchor's previous position.
    // When you drop a tile onto another of the same size, the other tile
    // lands exactly where yours came from, which is a swap. Nothing is ever
    // pushed on top of another tile.
    function resolveOverlaps(anchorId, refCol, refRow) {
        var anchorIdx = indexForId(anchorId)
        if (anchorIdx < 0) return
        var anchor = layoutModel.get(anchorIdx)
        var a = { col: anchor.col, row: anchor.row, colSpan: anchor.colSpan, rowSpan: anchor.rowSpan }

        var displaced = []
        for (var i = 0; i < layoutModel.count; i++) {
            if (i === anchorIdx) continue
            var other = layoutModel.get(i)
            if (rectsOverlap(a, other)) {
                displaced.push({ id: other.tileId, col: other.col, row: other.row })
            }
        }
        if (displaced.length === 0) return

        // Keep reading order so several displaced tiles stay in sequence.
        displaced.sort(function(x, y) { return (x.row - y.row) || (x.col - y.col) })

        // Displaced tiles ignore each other until each has been placed, so a
        // tile that is about to move never blocks another one.
        var ignore = {}
        for (var d = 0; d < displaced.length; d++) ignore[displaced[d].id] = true

        for (var k = 0; k < displaced.length; k++) {
            var id = displaced[k].id
            var spot = nearestFreeSpot(id, refCol, refRow, ignore)
            var idx = indexForId(id)
            layoutModel.setProperty(idx, "col", spot.col)
            layoutModel.setProperty(idx, "row", spot.row)
            delete ignore[id]
        }
    }

        // Safety net: if any tiles overlap (e.g. from a layout file saved by the
    // older buggy code), keep the tile that comes first in reading order and
    // move the others to their nearest free spot. Returns true if anything moved.
    function healOverlaps() {
        var order = []
        for (var i = 0; i < layoutModel.count; i++) {
            var t = layoutModel.get(i)
            order.push({ id: t.tileId, col: t.col, row: t.row })
        }
        order.sort(function(x, y) { return (x.row - y.row) || (x.col - y.col) })

        var unsettled = {}
        for (var k = 0; k < order.length; k++) unsettled[order[k].id] = true

        var changed = false
        for (var n = 0; n < order.length; n++) {
            var id = order[n].id
            var idx = indexForId(id)
            var tile = layoutModel.get(idx)
            var rect = { col: tile.col, row: tile.row, colSpan: tile.colSpan, rowSpan: tile.rowSpan }
            if (!isFree(rect, unsettled)) {
                var spot = nearestFreeSpot(id, tile.col, tile.row, unsettled)
                layoutModel.setProperty(idx, "col", spot.col)
                layoutModel.setProperty(idx, "row", spot.row)
                changed = true
            }
            delete unsettled[id]
        }
        return changed
    }

    // Pairwise resolution with no anchor, used after a column-count change
    // when many tiles can shift at once.
    function resolveAllOverlaps() {
        var guard = 0
        var changed = true
        while (changed && guard < 100) {
            changed = false
            guard++
            for (var i = 0; i < layoutModel.count; i++) {
                for (var j = i + 1; j < layoutModel.count; j++) {
                    var a = layoutModel.get(i)
                    var b = layoutModel.get(j)
                    if (rectsOverlap(a, b)) {
                        layoutModel.setProperty(j, "row", a.row + a.rowSpan)
                        changed = true
                    }
                }
            }
        }
    }

    // ---- Editing actions ----

    function moveTile(tileId, newCol, newRow) {
        var idx = indexForId(tileId)
        if (idx < 0) return
        var moving = layoutModel.get(idx)

        var oldCol = moving.col
        var oldRow = moving.row

        newCol = Math.max(0, Math.min(columns - moving.colSpan, newCol))
        newRow = Math.max(0, newRow)

        if (newCol === oldCol && newRow === oldRow) return

        layoutModel.setProperty(idx, "col", newCol)
        layoutModel.setProperty(idx, "row", newRow)
        resolveOverlaps(tileId, oldCol, oldRow)
        saveLayout()
    }

    function nearestAllowedSize(type, targetColSpan, targetRowSpan) {
        var sizes = allowedSizes[type]
        if (!sizes || sizes.length === 0) return { c: targetColSpan, r: targetRowSpan }
        var best = sizes[0]
        var bestDist = Infinity
        for (var i = 0; i < sizes.length; i++) {
            var s = sizes[i]
            var dist = Math.abs(s.c - targetColSpan) + Math.abs(s.r - targetRowSpan)
            if (dist < bestDist) { bestDist = dist; best = s }
        }
        return best
    }

    function resizeTile(tileId, targetColSpan, targetRowSpan) {
        var idx = indexForId(tileId)
        if (idx < 0) return
        var tile = layoutModel.get(idx)
        var snapped = nearestAllowedSize(tile.type, targetColSpan, targetRowSpan)

        var newCol = tile.col
        if (newCol + snapped.c > columns) {
            newCol = Math.max(0, columns - snapped.c)
            layoutModel.setProperty(idx, "col", newCol)
        }

        layoutModel.setProperty(idx, "colSpan", snapped.c)
        layoutModel.setProperty(idx, "rowSpan", snapped.r)
        resolveOverlaps(tileId, layoutModel.get(idx).col, layoutModel.get(idx).row)
        saveLayout()
    }

    function stepSize(tileId, direction) {
        var idx = indexForId(tileId)
        if (idx < 0) return
        var tile = layoutModel.get(idx)
        var sizes = allowedSizes[tile.type]
        if (!sizes || sizes.length === 0) return

        var currentIdx = -1
        for (var i = 0; i < sizes.length; i++) {
            if (sizes[i].c === tile.colSpan && sizes[i].r === tile.rowSpan) { currentIdx = i; break }
        }
        if (currentIdx < 0) currentIdx = 0

        var nextIdx = Math.max(0, Math.min(sizes.length - 1, currentIdx + direction))
        var next = sizes[nextIdx]

        var newCol = tile.col
        if (newCol + next.c > columns) newCol = Math.max(0, columns - next.c)

        layoutModel.setProperty(idx, "col", newCol)
        layoutModel.setProperty(idx, "colSpan", next.c)
        layoutModel.setProperty(idx, "rowSpan", next.r)
        resolveOverlaps(tileId, layoutModel.get(idx).col, layoutModel.get(idx).row)
        saveLayout()
    }

    // Changes the grid's column count. Clamps each tile's column so it
    // doesn't overflow the new width. Does not shrink colSpan, so a tile
    // wider than the new column count would still overflow (not an issue at
    // columns >= 5 with the current tile set).
    function setColumns(n) {
        pushUndoSnapshot()
        columns = n
        for (var i = 0; i < layoutModel.count; i++) {
            var t = layoutModel.get(i)
            var newCol = Math.min(t.col, Math.max(0, n - t.colSpan))
            if (newCol !== t.col) layoutModel.setProperty(i, "col", newCol)
        }
        resolveAllOverlaps()
        saveLayout()
    }

    // Repacks every tile top-left, in current list order, first-fit.
    function findFirstFit(colSpan, rowSpan, placed) {
        var row = 0
        while (row < 1000) {
            for (var col = 0; col <= columns - colSpan; col++) {
                var candidate = { col: col, row: row, colSpan: colSpan, rowSpan: rowSpan }
                var fits = true
                for (var k = 0; k < placed.length; k++) {
                    if (rectsOverlap(candidate, placed[k])) { fits = false; break }
                }
                if (fits) return { col: col, row: row }
            }
            row++
        }
        return { col: 0, row: row }
    }

    function tidyLayout() {
        pushUndoSnapshot()
        var placed = []
        for (var i = 0; i < layoutModel.count; i++) {
            var t = layoutModel.get(i)
            var pos = findFirstFit(t.colSpan, t.rowSpan, placed)
            layoutModel.setProperty(i, "col", pos.col)
            layoutModel.setProperty(i, "row", pos.row)
            placed.push({ col: pos.col, row: pos.row, colSpan: t.colSpan, rowSpan: t.rowSpan })
        }
        saveLayout()
    }

    // ---- Add-a-control tray ----

    // manageableTypes not currently placed in layoutModel (one instance per
    // type; tileId === type everywhere).
    function unplacedTypes() {
        var placed = {}
        for (var i = 0; i < layoutModel.count; i++) {
            placed[layoutModel.get(i).type] = true
        }
        var result = []
        for (var j = 0; j < manageableTypes.length; j++) {
            if (!placed[manageableTypes[j]]) result.push(manageableTypes[j])
        }
        return result
    }

    // Smallest-area allowed size for a type: the size a tile enters the
    // grid at when added from the tray.
    function defaultSizeForType(type) {
        var sizes = allowedSizes[type]
        if (!sizes || sizes.length === 0) return { c: 1, r: 1 }
        var best = sizes[0]
        for (var i = 1; i < sizes.length; i++) {
            if (sizes[i].c * sizes[i].r < best.c * best.r) best = sizes[i]
        }
        return best
    }

    function addTile(type) {
        if (indexForId(type) >= 0) return // already placed
        pushUndoSnapshot()
        var size = defaultSizeForType(type)
        var placedRects = []
        for (var i = 0; i < layoutModel.count; i++) {
            var t = layoutModel.get(i)
            placedRects.push({ col: t.col, row: t.row, colSpan: t.colSpan, rowSpan: t.rowSpan })
        }
        var pos = findFirstFit(size.c, size.r, placedRects)
        layoutModel.append({ tileId: type, type: type, col: pos.col, row: pos.row, colSpan: size.c, rowSpan: size.r })
        saveLayout()
    }

    function removeTile(tileId) {
        var idx = indexForId(tileId)
        if (idx < 0) return
        pushUndoSnapshot()
        layoutModel.remove(idx, 1)
        saveLayout()
    }
}