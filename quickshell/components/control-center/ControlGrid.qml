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

    implicitWidth: 548
    implicitHeight: ControlCenterLayoutService.rowCount() * 68 + Math.max(0, ControlCenterLayoutService.rowCount() - 1) * ControlCenterLayoutService.cellSpacing

    focus: editMode
    Keys.onPressed: (event) => {
        if (!root.editMode || root.selectedTileId === "") return
        var idx = ControlCenterLayoutService.indexForId(root.selectedTileId)
        if (idx < 0) return
        var tile = ControlCenterLayoutService.layoutModel.get(idx)

        if (event.key === Qt.Key_Left) {
            ControlCenterLayoutService.moveTile(root.selectedTileId, tile.col - 1, tile.row)
            event.accepted = true
        } else if (event.key === Qt.Key_Right) {
            ControlCenterLayoutService.moveTile(root.selectedTileId, tile.col + 1, tile.row)
            event.accepted = true
        } else if (event.key === Qt.Key_Up) {
            ControlCenterLayoutService.moveTile(root.selectedTileId, tile.col, tile.row - 1)
            event.accepted = true
        } else if (event.key === Qt.Key_Down) {
            ControlCenterLayoutService.moveTile(root.selectedTileId, tile.col, tile.row + 1)
            event.accepted = true
        } else if (event.key === Qt.Key_BracketRight) {
            ControlCenterLayoutService.stepSize(root.selectedTileId, 1)
            event.accepted = true
        } else if (event.key === Qt.Key_BracketLeft) {
            ControlCenterLayoutService.stepSize(root.selectedTileId, -1)
            event.accepted = true
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.editMode
        onClicked: root.selectedTileId = ""
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

            readonly property real cellW: (root.width - (ControlCenterLayoutService.columns - 1) * ControlCenterLayoutService.cellSpacing) / ControlCenterLayoutService.columns
            readonly property real cellH: 68

            x: col * (cellW + ControlCenterLayoutService.cellSpacing)
            y: row * (cellH + ControlCenterLayoutService.cellSpacing)
            width: colSpan * cellW + (colSpan - 1) * ControlCenterLayoutService.cellSpacing
            height: rowSpan * cellH + (rowSpan - 1) * ControlCenterLayoutService.cellSpacing

            // ---- x/y: the "move" morph, same spring/ease toggle as Island's width/height ----
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

            // ---- width/height: the "resize" morph. Disabled while actively
            // dragging the handle so it tracks the cursor 1:1 with no lag;
            // re-enabled the instant you let go, so the final snap to the
            // grid cell animates instead of jumping.
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

                // ---- border feedback: short plain ease, never spring —
                // same category as Island's radius/border.width treatment
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

    Component { id: wifiTile; WifiToggleTile { onSubviewRequested: root.subviewRequestedFor("wifi") } }
    Component { id: bluetoothTile; BluetoothToggleTile { onSubviewRequested: root.subviewRequestedFor("bluetooth") } }
    Component { id: focusTile; FocusToggleTile { onSubviewRequested: root.subviewRequestedFor("focus") } }
    Component { id: powerProfileTile; PowerProfileToggleTile { onSubviewRequested: root.subviewRequestedFor("powerprofile") } }
    Component { id: caffeineTile; CaffeineToggleTile { onSubviewRequested: root.subviewRequestedFor("caffeine") } }
    Component { id: nightlightTile; NightLightToggleTile {} }
    Component { id: airplaneTile; AirplaneModeToggleTile {} }
    Component { id: recordingTile; RecordingToggleTile {} }
    Component { id: lightmodeTile; LightModeToggleTile {} }
    Component { id: volumeTile; VolumeToggleTile {} }
    Component { id: brightnessTile; BrightnessToggleTile {} }
}