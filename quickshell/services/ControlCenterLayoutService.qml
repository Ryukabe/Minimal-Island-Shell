pragma Singleton
import QtQuick
import "../styles"

QtObject {
    id: root

    property int columns: 6
    property real cellSpacing: Dimens.spacingSm

property var allowedSizes: ({
    "wifi": [{c:1,r:1}, {c:2,r:1}, {c:3,r:1}, {c:1,r:2}, {c:2,r:2}],
    "bluetooth": [{c:1,r:1}, {c:2,r:1}, {c:3,r:1}, {c:1,r:2}, {c:2,r:2}],
    "nightlight": [{c:1,r:1}, {c:2,r:1}, {c:3,r:1}, {c:1,r:2}],
    "focus": [{c:1,r:1}, {c:2,r:1}, {c:3,r:1}, {c:1,r:2}, {c:2,r:2}],
    "airplane": [{c:1,r:1}, {c:2,r:1}, {c:3,r:1}, {c:1,r:2}],
    "caffeine": [{c:1,r:1}, {c:2,r:1}, {c:3,r:1}, {c:1,r:2}],
    "recording": [{c:1,r:1}, {c:2,r:1}, {c:3,r:1}, {c:1,r:2}],
    "powerprofile": [{c:1,r:1}, {c:2,r:1}, {c:3,r:1}, {c:1,r:2}],
    "lightmode": [{c:1,r:1}, {c:2,r:1}, {c:3,r:1}, {c:1,r:2}],
    "volume": [{c:2,r:1}, {c:3,r:1}, {c:4,r:1}, {c:6,r:1}, {c:3,r:2}],
    "brightness": [{c:2,r:1}, {c:3,r:1}, {c:4,r:1}, {c:6,r:1}, {c:3,r:2}]
})

    property ListModel layoutModel: ListModel {
        ListElement { tileId: "wifi"; type: "wifi"; col: 0; row: 0; colSpan: 1; rowSpan: 1 }
        ListElement { tileId: "bluetooth"; type: "bluetooth"; col: 1; row: 0; colSpan: 1; rowSpan: 1 }
        ListElement { tileId: "nightlight"; type: "nightlight"; col: 2; row: 0; colSpan: 1; rowSpan: 1 }
        ListElement { tileId: "focus"; type: "focus"; col: 3; row: 0; colSpan: 1; rowSpan: 1 }
        ListElement { tileId: "airplane"; type: "airplane"; col: 4; row: 0; colSpan: 1; rowSpan: 1 }
        ListElement { tileId: "caffeine"; type: "caffeine"; col: 5; row: 0; colSpan: 1; rowSpan: 1 }
        ListElement { tileId: "recording"; type: "recording"; col: 0; row: 1; colSpan: 1; rowSpan: 1 }
        ListElement { tileId: "powerprofile"; type: "powerprofile"; col: 1; row: 1; colSpan: 1; rowSpan: 1 }
        ListElement { tileId: "lightmode"; type: "lightmode"; col: 2; row: 1; colSpan: 1; rowSpan: 1 }
        ListElement { tileId: "volume"; type: "volume"; col: 0; row: 2; colSpan: 3; rowSpan: 1 }
        ListElement { tileId: "brightness"; type: "brightness"; col: 0; row: 3; colSpan: 3; rowSpan: 1 }
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
}