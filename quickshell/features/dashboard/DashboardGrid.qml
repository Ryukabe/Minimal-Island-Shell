// features/dashboard/DashboardGrid.qml — the component grid. Read-only on the Dashboard; in the
// settings preview (editMode) drag a component to move it and use the four corner dots to resize it.
pragma ComponentBehavior: Bound

import QtQuick
import "."
import "components"
import "../../core/shell"
import "../../core/styles"

Item {
    id: root

    property bool editMode: false
    property string selectedTileId: ""

    // ---- Grid geometry ----
    readonly property int columns: DashboardLayoutService.columns
    readonly property int rows: DashboardLayoutService.rows
    readonly property real gap: Dimens.spacingSm
    readonly property real cellW: Math.max(1, (width - (columns - 1) * gap) / columns)
    readonly property real cellH: Math.max(1, (height - (rows - 1) * gap) / rows)
    readonly property real stepX: cellW + gap
    readonly property real stepY: cellH + gap

    // ---- Drag state (filled in by whichever tile is being dragged) ----
    property string dragTileId: ""
    property real dragX: 0
    property real dragY: 0
    property int dragColSpan: 1
    property int dragRowSpan: 1
    readonly property bool dragActive: dragTileId !== ""
    readonly property int dragTargetCol: Math.max(0, Math.min(columns - dragColSpan, Math.round(dragX / stepX)))
    readonly property int dragTargetRow: Math.max(0, Math.min(rows - dragRowSpan, Math.round(dragY / stepY)))

    // Arrow keys move the selected component, Shift + arrows resize it.
    focus: editMode
    Keys.onPressed: (event) => {
        if (!root.editMode || root.selectedTileId === "") return
        var tile = DashboardLayoutService.tileInfo(root.selectedTileId)
        if (!tile) return
        var dx = 0
        var dy = 0
        if (event.key === Qt.Key_Left) dx = -1
        else if (event.key === Qt.Key_Right) dx = 1
        else if (event.key === Qt.Key_Up) dy = -1
        else if (event.key === Qt.Key_Down) dy = 1
        else return
        DashboardLayoutService.pushUndoSnapshot()
        if (event.modifiers & Qt.ShiftModifier) {
            DashboardLayoutService.resizeTile(root.selectedTileId, tile.colSpan + dx, tile.rowSpan + dy)
        } else {
            DashboardLayoutService.moveTile(root.selectedTileId, tile.col + dx, tile.row + dy)
        }
        event.accepted = true
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.editMode
        onClicked: root.selectedTileId = ""
    }

    // ---- Guide dots (edit mode only), behind the tiles ----
    Repeater {
        model: root.editMode ? root.columns * root.rows : 0

        delegate: Item {
            id: guide
            required property int index
            readonly property int c: index % root.columns
            readonly property int r: Math.floor(index / root.columns)
            readonly property bool inTarget: root.dragActive
                && c >= root.dragTargetCol && c < root.dragTargetCol + root.dragColSpan
                && r >= root.dragTargetRow && r < root.dragTargetRow + root.dragRowSpan

            x: c * root.stepX
            y: r * root.stepY
            width: root.cellW
            height: root.cellH

            Rectangle {
                anchors.centerIn: parent
                width: guide.inTarget ? 8 : 4
                height: width
                radius: width / 2
                color: guide.inTarget ? Colors.accent : Colors.fg
                opacity: guide.inTarget ? 1.0 : 0.22

                Behavior on width {
                    NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs); easing.type: Easing.OutCubic }
                }
                Behavior on opacity { NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) } }
                Behavior on color { ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) } }
            }
        }
    }

    // ---- Components ----
    Repeater {
        model: DashboardLayoutService.layoutModel

        delegate: Item {
            id: tile

            required property string tileId
            required property string type
            required property int col
            required property int row
            required property int colSpan
            required property int rowSpan

            // Position and size only glide after the tile has settled, so the grid appearing
            // (or the panel changing size) never makes tiles fly in.
            property bool animReady: false
            Timer {
                interval: 150
                running: true
                onTriggered: tile.animReady = true
            }
            readonly property bool selected: root.selectedTileId === tile.tileId
            readonly property bool isDragged: dragArea.drag.active
            readonly property bool springOn: ShellState.motionSpringEnabled && !ShellState.motionReduced

            z: isDragged ? 20 : (selected ? 5 : 0)

            onIsDraggedChanged: {
                if (isDragged) {
                    root.dragColSpan = colSpan
                    root.dragRowSpan = rowSpan
                    root.dragX = x
                    root.dragY = y
                    root.dragTileId = tileId
                } else if (root.dragTileId === tileId) {
                    root.dragTileId = ""
                }
            }
            onXChanged: if (isDragged) root.dragX = x
            onYChanged: if (isDragged) root.dragY = y

            x: col * root.stepX
            y: row * root.stepY
            width: colSpan * root.stepX - root.gap
            height: rowSpan * root.stepY - root.gap

            // Position / size follow the glide tier (spring or ease, like Control Center tiles).
            SpringAnimation { id: xSpring; spring: Motion.glideSpring; damping: Motion.glideDamping; mass: Motion.glideMass; epsilon: Motion.epsilon }
            NumberAnimation { id: xEase; duration: ShellState.motionDuration(Motion.glideMs); easing.type: Easing.BezierSpline; easing.bezierCurve: [0.15, 1.0, 0.05, 1.0, 1, 1] }
            Behavior on x { enabled: tile.animReady && !dragArea.drag.active; animation: tile.springOn ? xSpring : xEase }

            SpringAnimation { id: ySpring; spring: Motion.glideSpring; damping: Motion.glideDamping; mass: Motion.glideMass; epsilon: Motion.epsilon }
            NumberAnimation { id: yEase; duration: ShellState.motionDuration(Motion.glideMs); easing.type: Easing.BezierSpline; easing.bezierCurve: [0.15, 1.0, 0.05, 1.0, 1, 1] }
            Behavior on y { enabled: tile.animReady && !dragArea.drag.active; animation: tile.springOn ? ySpring : yEase }

            SpringAnimation { id: wSpring; spring: Motion.glideSpring; damping: Motion.glideDamping; mass: Motion.glideMass; epsilon: Motion.epsilon }
            NumberAnimation { id: wEase; duration: ShellState.motionDuration(Motion.glideMs); easing.type: Easing.BezierSpline; easing.bezierCurve: [0.15, 1.0, 0.05, 1.0, 1, 1] }
            Behavior on width { enabled: tile.animReady && !tile.resizing; animation: tile.springOn ? wSpring : wEase }

            SpringAnimation { id: hSpring; spring: Motion.glideSpring; damping: Motion.glideDamping; mass: Motion.glideMass; epsilon: Motion.epsilon }
            NumberAnimation { id: hEase; duration: ShellState.motionDuration(Motion.glideMs); easing.type: Easing.BezierSpline; easing.bezierCurve: [0.15, 1.0, 0.05, 1.0, 1, 1] }
            Behavior on height { enabled: tile.animReady && !tile.resizing; animation: tile.springOn ? hSpring : hEase }

            Loader {
                anchors.fill: parent
                sourceComponent: {
                    switch (tile.type) {
                    case "quicknote": return noteComp
                    case "media": return mediaComp
                    case "stats": return statsComp
                    case "calendar": return calendarComp
                    default: return null
                    }
                }
            }

            // ---- Edit overlay ----
            Rectangle {
                anchors.fill: parent
                radius: Dimens.radiusCard
                color: "transparent"
                border.color: tile.selected ? Colors.accent : Colors.border
                border.width: tile.selected ? 2 : 1
                visible: root.editMode
                z: 10

                Behavior on border.color { ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) } }

                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    drag.target: tile
                    drag.minimumX: 0
                    drag.maximumX: root.width - tile.width
                    drag.minimumY: 0
                    drag.maximumY: root.height - tile.height
                    preventStealing: true

                    onPressed: {
                        root.selectedTileId = tile.tileId
                        root.forceActiveFocus()
                    }

                    onReleased: {
                        var targetCol = Math.max(0, Math.min(root.columns - tile.colSpan, Math.round(tile.x / root.stepX)))
                        var targetRow = Math.max(0, Math.min(root.rows - tile.rowSpan, Math.round(tile.y / root.stepY)))
                        if (targetCol !== tile.col || targetRow !== tile.row) {
                            DashboardLayoutService.pushUndoSnapshot()
                            DashboardLayoutService.moveTile(tile.tileId, targetCol, targetRow)
                        }
                        tile.x = Qt.binding(function () { return tile.col * root.stepX })
                        tile.y = Qt.binding(function () { return tile.row * root.stepY })
                    }
                }

                // Four corner handles, shown on the selected component only.
                Repeater {
                    model: tile.selected ? 4 : 0

                    delegate: Rectangle {
                        id: handle
                        required property int index
                        readonly property bool atLeft: index === 0 || index === 2
                        readonly property bool atTop: index === 0 || index === 1

                        width: Dimens.fontSizeBase
                        height: width
                        radius: width / 2
                        color: Colors.accent
                        x: atLeft ? -width / 2 : parent.width - width / 2
                        y: atTop ? -height / 2 : parent.height - height / 2

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -Dimens.paddingSmall
                            cursorShape: handle.atLeft === handle.atTop ? Qt.SizeFDiagCursor : Qt.SizeBDiagCursor
                            preventStealing: true

                            property point startScene
                            property int startCol: 0
                            property int startRow: 0
                            property int startCs: 1
                            property int startRs: 1

                            onPressed: (mouse) => {
                                DashboardLayoutService.pushUndoSnapshot()
                                root.selectedTileId = tile.tileId
                                root.forceActiveFocus()
                                tile.resizing = true
                                startScene = mapToItem(null, mouse.x, mouse.y)
                                startCol = tile.col
                                startRow = tile.row
                                startCs = tile.colSpan
                                startRs = tile.rowSpan
                            }

                            onPositionChanged: (mouse) => {
                                if (!pressed) return
                                var p = mapToItem(null, mouse.x, mouse.y)
                                var dCol = Math.round((p.x - startScene.x) / root.stepX)
                                var dRow = Math.round((p.y - startScene.y) / root.stepY)
                                var m = DashboardLayoutService.minFor(tile.type)

                                var cs = Math.max(m.c, handle.atLeft ? startCs - dCol : startCs + dCol)
                                var rs = Math.max(m.r, handle.atTop ? startRs - dRow : startRs + dRow)
                                var c0 = handle.atLeft ? startCol + startCs - cs : startCol
                                var r0 = handle.atTop ? startRow + startRs - rs : startRow

                                if (c0 < 0) { cs += c0; c0 = 0 }
                                if (r0 < 0) { rs += r0; r0 = 0 }
                                if (c0 + cs > root.columns) cs = root.columns - c0
                                if (r0 + rs > root.rows) rs = root.rows - r0

                                // Rejected (too small, or it would hit a neighbour): stays at the last valid size.
                                DashboardLayoutService.setRect(tile.tileId, c0, r0, cs, rs)
                            }

                            onReleased: tile.resizing = false
                        }
                    }
                }
            }
        }
    }

    // ---- Drop preview ----
    Rectangle {
        id: ghost
        visible: root.editMode && root.dragActive
        z: 15
        x: root.dragTargetCol * root.stepX
        y: root.dragTargetRow * root.stepY
        width: root.dragColSpan * root.stepX - root.gap
        height: root.dragRowSpan * root.stepY - root.gap
        radius: Dimens.radiusCard
        color: "transparent"
        border.width: 2
        border.color: Colors.accent

        Rectangle {
            anchors.fill: parent
            radius: ghost.radius
            color: Colors.accent
            opacity: 0.14
        }
    }

    Component { id: noteComp; QuickNote {} }
    Component { id: mediaComp; MediaCD {} }
    Component { id: statsComp; SystemStats {} }
    Component { id: calendarComp; CalendarCard {} }
}