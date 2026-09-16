pragma ComponentBehavior: Bound

import QtQuick
import "../../styles"
import "../../services"
import "./tiles"

Item {
    id: root

    property bool editMode: false
    signal subviewRequestedFor(string tileType)

    implicitWidth: 548
    implicitHeight: ControlCenterLayoutService.rowCount() * 68 + Math.max(0, ControlCenterLayoutService.rowCount() - 1) * ControlCenterLayoutService.cellSpacing

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

            readonly property real cellW: (root.width - (ControlCenterLayoutService.columns - 1) * ControlCenterLayoutService.cellSpacing) / ControlCenterLayoutService.columns
            readonly property real cellH: 68

            x: col * (cellW + ControlCenterLayoutService.cellSpacing)
            y: row * (cellH + ControlCenterLayoutService.cellSpacing)
            width: colSpan * cellW + (colSpan - 1) * ControlCenterLayoutService.cellSpacing
            height: rowSpan * cellH + (rowSpan - 1) * ControlCenterLayoutService.cellSpacing

            Behavior on x { enabled: !dragArea.drag.active; NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            Behavior on y { enabled: !dragArea.drag.active; NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

            // Dynamic Tile Instantiation mapped directly to existing files
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

            // Edit Overlay & Resize Handles
            Rectangle {
                anchors.fill: parent
                radius: Dimens.radiusMedium
                color: "transparent"
                border.color: Colors.accent
                border.width: 2
                visible: root.editMode
                z: 10

                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    drag.target: tileWrapper
                    enabled: root.editMode

                    onReleased: {
                        var targetCol = Math.round(tileWrapper.x / (tileWrapper.cellW + ControlCenterLayoutService.cellSpacing))
                        var targetRow = Math.round(tileWrapper.y / (tileWrapper.cellH + ControlCenterLayoutService.cellSpacing))
                        ControlCenterLayoutService.moveTile(tileWrapper.tileId, targetCol, targetRow)
                    }
                }

                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    color: Colors.accent
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: -4
                    visible: root.editMode

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.SizeFDiagCursor

                        property point startPos

                        onPressed: (mouse) => startPos = Qt.point(mouse.x, mouse.y)
                        onPositionChanged: (mouse) => {
                            var deltaX = mouse.x - startPos.x
                            var deltaY = mouse.y - startPos.y

                            var stepW = tileWrapper.cellW + ControlCenterLayoutService.cellSpacing
                            var stepH = tileWrapper.cellH + ControlCenterLayoutService.cellSpacing

                            var targetColSpan = Math.max(1, Math.round((tileWrapper.width + deltaX) / stepW))
                            var targetRowSpan = Math.max(1, Math.round((tileWrapper.height + deltaY) / stepH))

                            ControlCenterLayoutService.resizeTile(tileWrapper.tileId, targetColSpan, targetRowSpan)
                        }
                    }
                }
            }
        }
    }

    // --- Component Mappings matching existing QML Tiles ---
    Component {
        id: wifiTile
        WifiToggleTile {
            onSubviewRequested: root.subviewRequestedFor("wifi")
        }
    }

    Component {
        id: bluetoothTile
        BluetoothToggleTile {
            onSubviewRequested: root.subviewRequestedFor("bluetooth")
        }
    }

    Component {
        id: focusTile
        FocusToggleTile {
            onSubviewRequested: root.subviewRequestedFor("focus")
        }
    }

    Component {
        id: powerProfileTile
        PowerProfileToggleTile {
            onSubviewRequested: root.subviewRequestedFor("powerprofile")
        }
    }

    Component {
        id: caffeineTile
        CaffeineToggleTile {
            onSubviewRequested: root.subviewRequestedFor("caffeine")
        }
    }

    Component {
        id: nightlightTile
        NightLightToggleTile {}
    }

    Component {
        id: airplaneTile
        AirplaneModeToggleTile {}
    }

    Component {
        id: recordingTile
        RecordingToggleTile {}
    }

    Component {
        id: lightmodeTile
        LightModeToggleTile {}
    }

    Component {
        id: volumeTile
        VolumeToggleTile {}
    }

    Component {
        id: brightnessTile
        BrightnessToggleTile {}
    }
}