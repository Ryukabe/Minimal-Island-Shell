pragma ComponentBehavior: Bound

import QtQuick
import "../../styles"
import "../../services"
import "./tiles"

Item {
    id: root

    property bool editMode: false
    property string selectedTileId: ""
    signal subviewRequestedFor(string tileType)

    // ---- Grid geometry (shared by tiles, guide dots and the drop preview) ----
    readonly property int columns: ControlCenterLayoutService.columns
    readonly property real gap: ControlCenterLayoutService.cellSpacing
    readonly property real cellW: (width - (columns - 1) * gap) / columns
    readonly property real cellH: 68
    readonly property real stepX: cellW + gap
    readonly property real stepY: cellH + gap
    // In edit mode one spare row is shown so a tile can be dragged below the last one
    readonly property int gridRows: ControlCenterLayoutService.rowCount() + (editMode ? 1 : 0)

    implicitWidth: 548
    implicitHeight: gridRows * cellH + Math.max(0, gridRows - 1) * gap

    // ---- Drag state (filled in by whichever tile is being dragged) ----
    property string dragTileId: ""
    property real dragX: 0
    property real dragY: 0
    property int dragColSpan: 1
    property int dragRowSpan: 1
    readonly property bool dragActive: dragTileId !== ""
    // Same snapping maths the drop uses (see onReleased below and moveTile in the service)
    readonly property int dragTargetCol: Math.max(0, Math.min(columns - dragColSpan, Math.round(dragX / stepX)))
    readonly property int dragTargetRow: Math.max(0, Math.round(dragY / stepY))

    focus: editMode
    Keys.onPressed: (event) => {
        if (!root.editMode || root.selectedTileId === "") return
        var idx = ControlCenterLayoutService.indexForId(root.selectedTileId)
        if (idx < 0) return
        var tile = ControlCenterLayoutService.layoutModel.get(idx)

        if (event.key === Qt.Key_Left) {
            ControlCenterLayoutService.pushUndoSnapshot()
            ControlCenterLayoutService.moveTile(root.selectedTileId, tile.col - 1, tile.row)
            event.accepted = true
        } else if (event.key === Qt.Key_Right) {
            ControlCenterLayoutService.pushUndoSnapshot()
            ControlCenterLayoutService.moveTile(root.selectedTileId, tile.col + 1, tile.row)
            event.accepted = true
        } else if (event.key === Qt.Key_Up) {
            ControlCenterLayoutService.pushUndoSnapshot()
            ControlCenterLayoutService.moveTile(root.selectedTileId, tile.col, tile.row - 1)
            event.accepted = true
        } else if (event.key === Qt.Key_Down) {
            ControlCenterLayoutService.pushUndoSnapshot()
            ControlCenterLayoutService.moveTile(root.selectedTileId, tile.col, tile.row + 1)
            event.accepted = true
        } else if (event.key === Qt.Key_BracketRight) {
            ControlCenterLayoutService.pushUndoSnapshot()
            ControlCenterLayoutService.stepSize(root.selectedTileId, 1)
            event.accepted = true
        } else if (event.key === Qt.Key_BracketLeft) {
            ControlCenterLayoutService.pushUndoSnapshot()
            ControlCenterLayoutService.stepSize(root.selectedTileId, -1)
            event.accepted = true
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.editMode
        onClicked: root.selectedTileId = ""
    }

    // ---- Guide dots: one per cell, edit mode only (declared before the tiles so they sit behind them) ----
    Repeater {
        model: root.editMode ? root.columns * root.gridRows : 0

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
                Behavior on opacity {
                    NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                }
                Behavior on color {
                    ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                }
            }
        }
    }

    Repeater {
        model: ControlCenterLayoutService.layoutModel

        delegate: Item {
            id: tileWrapper

            required property string tileId
            required property string type
            required property int col
            required property int row
            required property int colSpan
            required property int rowSpan

            property bool resizing: false
            readonly property bool selected: root.selectedTileId === tileId
            readonly property bool isDragged: dragArea.drag.active

            readonly property real cellW: root.cellW
            readonly property real cellH: root.cellH

            // The dragged tile stays above the drop preview
            z: isDragged ? 20 : 0

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

            x: col * (cellW + ControlCenterLayoutService.cellSpacing)
            y: row * (cellH + ControlCenterLayoutService.cellSpacing)
            width: colSpan * cellW + (colSpan - 1) * ControlCenterLayoutService.cellSpacing
            height: rowSpan * cellH + (rowSpan - 1) * ControlCenterLayoutService.cellSpacing

            SpringAnimation {
                id: xSpringAnim
                spring: Motion.glideSpring
                damping: Motion.glideDamping
                mass: Motion.glideMass
                epsilon: Motion.epsilon
            }
            NumberAnimation {
                id: xEaseAnim
                duration: ShellState.motionDuration(Motion.glideMs)
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.15, 1.0, 0.05, 1.0, 1, 1]
            }
            Behavior on x {
                enabled: !dragArea.drag.active
                animation: (ShellState.motionSpringEnabled && !ShellState.motionReduced) ? xSpringAnim : xEaseAnim
            }

            SpringAnimation {
                id: ySpringAnim
                spring: Motion.glideSpring
                damping: Motion.glideDamping
                mass: Motion.glideMass
                epsilon: Motion.epsilon
            }
            NumberAnimation {
                id: yEaseAnim
                duration: ShellState.motionDuration(Motion.glideMs)
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.15, 1.0, 0.05, 1.0, 1, 1]
            }
            Behavior on y {
                enabled: !dragArea.drag.active
                animation: (ShellState.motionSpringEnabled && !ShellState.motionReduced) ? ySpringAnim : yEaseAnim
            }

            SpringAnimation {
                id: widthSpringAnim
                spring: Motion.glideSpring
                damping: Motion.glideDamping
                mass: Motion.glideMass
                epsilon: Motion.epsilon
            }
            NumberAnimation {
                id: widthEaseAnim
                duration: ShellState.motionDuration(Motion.glideMs)
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.15, 1.0, 0.05, 1.0, 1, 1]
            }
            Behavior on width {
                enabled: !tileWrapper.resizing
                animation: (ShellState.motionSpringEnabled && !ShellState.motionReduced) ? widthSpringAnim : widthEaseAnim
            }

            SpringAnimation {
                id: heightSpringAnim
                spring: Motion.glideSpring
                damping: Motion.glideDamping
                mass: Motion.glideMass
                epsilon: Motion.epsilon
            }
            NumberAnimation {
                id: heightEaseAnim
                duration: ShellState.motionDuration(Motion.glideMs)
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.15, 1.0, 0.05, 1.0, 1, 1]
            }
            Behavior on height {
                enabled: !tileWrapper.resizing
                animation: (ShellState.motionSpringEnabled && !ShellState.motionReduced) ? heightSpringAnim : heightEaseAnim
            }

            Loader {
                id: tileLoader
                anchors.fill: parent
                onLoaded: {
                    if (item) {
                        item.anchors.fill = tileLoader
                    }
                }
                sourceComponent: {
                    switch (tileWrapper.type) {
                    case "wifi": return wifiTile
                    case "bluetooth": return bluetoothTile
                    case "nightlight": return nightlightTile
                    case "focus": return focusTile
                    case "airplane": return airplaneTile
                    case "caffeine": return caffeineTile
                    case "recording": return recordingTile
                    case "powerprofile": return powerProfileTile
                    case "lightmode": return lightmodeTile
                    case "volume": return volumeTile
                    case "brightness": return brightnessTile
                    case "media": return mediaTile
                    default: return null
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: ShellState.islandCornerRadius
                color: "transparent"
                border.color: tileWrapper.selected ? Colors.accent : Colors.border
                border.width: tileWrapper.selected ? 2 : 1
                visible: root.editMode
                z: 10

                Behavior on border.color {
                    ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                }
                Behavior on border.width {
                    NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs); easing.type: Easing.OutCubic }
                }

                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    drag.target: tileWrapper
                    enabled: root.editMode
                    preventStealing: true

                    onPressed: {
                        ControlCenterLayoutService.pushUndoSnapshot()
                        root.selectedTileId = tileWrapper.tileId
                        root.forceActiveFocus()
                    }

                    onReleased: {
                        var targetCol = Math.round(tileWrapper.x / (tileWrapper.cellW + ControlCenterLayoutService.cellSpacing))
                        var targetRow = Math.round(tileWrapper.y / (tileWrapper.cellH + ControlCenterLayoutService.cellSpacing))
                        ControlCenterLayoutService.moveTile(tileWrapper.tileId, targetCol, targetRow)

                        tileWrapper.x = Qt.binding(function() {
                            return tileWrapper.col * (tileWrapper.cellW + ControlCenterLayoutService.cellSpacing)
                        })
                        tileWrapper.y = Qt.binding(function() {
                            return tileWrapper.row * (tileWrapper.cellH + ControlCenterLayoutService.cellSpacing)
                        })
                    }
                }

                Rectangle {
                    width: 16
                    height: 16
                    radius: ShellState.islandCornerRadius
                    color: Colors.accent
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: -4
                    visible: root.editMode

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.SizeFDiagCursor
                        preventStealing: true

                        property point startScenePos
                        property size startSize

                        onPressed: (mouse) => {
                            ControlCenterLayoutService.pushUndoSnapshot()
                            root.selectedTileId = tileWrapper.tileId
                            root.forceActiveFocus()
                            tileWrapper.resizing = true
                            startScenePos = mapToItem(null, mouse.x, mouse.y)
                            startSize = Qt.size(tileWrapper.width, tileWrapper.height)
                        }
                        onPositionChanged: (mouse) => {
                            var currentScenePos = mapToItem(null, mouse.x, mouse.y)
                            var deltaX = currentScenePos.x - startScenePos.x
                            var deltaY = currentScenePos.y - startScenePos.y

                            var stepW = tileWrapper.cellW + ControlCenterLayoutService.cellSpacing
                            var stepH = tileWrapper.cellH + ControlCenterLayoutService.cellSpacing

                            var targetColSpan = Math.max(1, Math.round((startSize.width + deltaX) / stepW))
                            var targetRowSpan = Math.max(1, Math.round((startSize.height + deltaY) / stepH))

                            ControlCenterLayoutService.resizeTile(tileWrapper.tileId, targetColSpan, targetRowSpan)
                        }
                        onReleased: {
                            tileWrapper.resizing = false
                        }
                    }
                }
            }
        }
    }

    // ---- Drop preview: where the dragged tile will snap ----
    Rectangle {
        id: ghost
        visible: root.editMode && root.dragActive
        z: 15

        x: root.dragTargetCol * root.stepX
        y: root.dragTargetRow * root.stepY
        width: root.dragColSpan * root.cellW + (root.dragColSpan - 1) * root.gap
        height: root.dragRowSpan * root.cellH + (root.dragRowSpan - 1) * root.gap

        radius: ShellState.islandCornerRadius
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

    Component { id: wifiTile; WifiToggleTile { onSubviewRequested: root.subviewRequestedFor("wifi") } }
    Component { id: bluetoothTile; BluetoothToggleTile { onSubviewRequested: root.subviewRequestedFor("bluetooth") } }
    Component { id: focusTile; FocusToggleTile { onSubviewRequested: root.subviewRequestedFor("focus") } }
    Component { id: powerProfileTile; PowerProfileToggleTile { onSubviewRequested: root.subviewRequestedFor("powerprofile") } }
    Component { id: caffeineTile; CaffeineToggleTile { onSubviewRequested: root.subviewRequestedFor("caffeine") } }
    Component { id: nightlightTile; NightLightToggleTile {} }
    Component { id: airplaneTile; AirplaneModeToggleTile {} }
    Component { id: recordingTile; RecordingToggleTile {} }
    Component { id: lightmodeTile; LightModeToggleTile {} }
    Component { id: mediaTile; MediaToggleTile {} }
    Component { id: volumeTile; VolumeToggleTile { onSubviewRequested: root.subviewRequestedFor("volume") } }
    Component { id: brightnessTile; BrightnessToggleTile { onSubviewRequested: root.subviewRequestedFor("brightness") } }
}