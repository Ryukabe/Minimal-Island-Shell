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
    {c:1,r:2}, {c:1,r:3}, {c:1,r:4},
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

    // Undo history — array of full layout snapshots, most recent last.
    // Reassigned (never mutated in place) so bindings on undoStack.length
    // (e.g. the Undo button's enabled state) update reactively, same
    // pattern Colors.qml uses for hardcodedPalette.
    property var undoStack: []

    property FileView layoutFile: FileView {
        id: layoutFile
        path: Quickshell.env("HOME") + "/.config/quickshell/control-center-layout.json"
        printErrors: false
        onLoaded: root.loadFromJson(text())
        onLoadFailed: (error) => root.resetToDefault()
    }

    function resetToDefault() {
        if (layoutModel.count > 0) pushUndoSnapshot()
        layoutModel.clear()
        for (var i = 0; i < defaultLayout.length; i++) {
            layoutModel.append(defaultLayout[i])
        }
        saveLayout()
    }

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

        layoutModel.clear()
        var savedIds = {}
        for (var i = 0; i < arr.length; i++) {
            layoutModel.append(arr[i])
            savedIds[arr[i].tileId] = true
        }

        // Any tile type that exists in code but wasn't in the save
        // (e.g. a new control type added later) gets appended at its
        // default spot instead of silently vanishing from the grid.
        for (var j = 0; j < defaultLayout.length; j++) {
            if (!savedIds[defaultLayout[j].tileId]) {
                layoutModel.append(defaultLayout[j])
            }
        }
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
    resolveOverlaps(tileId)
    saveLayout()
}

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

    function moveTile(tileId, newCol, newRow) {
        var idx = indexForId(tileId)
        if (idx < 0) return
        var moving = layoutModel.get(idx)

        newCol = Math.max(0, Math.min(columns - moving.colSpan, newCol))
        newRow = Math.max(0, newRow)

        layoutModel.setProperty(idx, "col", newCol)
        layoutModel.setProperty(idx, "row", newRow)
        resolveOverlaps(tileId)
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
        resolveOverlaps(tileId)
        saveLayout()
    }

    function resolveOverlaps(anchorId) {
        var guard = 0
        var changed = true
        while (changed && guard < 50) {
            changed = false
            guard++
            var anchorIdx = indexForId(anchorId)
            var anchor = layoutModel.get(anchorIdx)
            for (var i = 0; i < layoutModel.count; i++) {
                if (i === anchorIdx) continue
                var other = layoutModel.get(i)
                if (rectsOverlap(anchor, other)) {
                    layoutModel.setProperty(i, "row", anchor.row + anchor.rowSpan)
                    changed = true
                }
            }
        }
    }

    // Generic pairwise overlap resolution (no single anchor tile) — used
    // after a column-count change, since many tiles can shift at once.
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

    // Changes the grid's column count. Clamps each tile's column position
    // so it doesn't overflow the new width. NOTE: does not shrink a
    // tile's colSpan — a tile wider than the new column count will still
    // overflow. Not an issue at columns >= 5 with the current tile set
    // (nothing wider than 3 cols by default), but flagged for later.
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
}