import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"
import "../../settings/common"

RowLayout {
    id: root

    property string tileId: ""
    visible: root.tileId !== ""
    spacing: Dimens.spacingSm

    readonly property var tile: {
        var idx = ControlCenterLayoutService.indexForId(root.tileId)
        return idx >= 0 ? ControlCenterLayoutService.layoutModel.get(idx) : null
    }
    readonly property var sizes: root.tile ? (ControlCenterLayoutService.allowedSizes[root.tile.type] || []) : []

    Text {
        text: root.tile ? (ControlCenterLayoutService.typeDisplayNames[root.tile.type] || root.tile.type) + " · " + root.tile.colSpan + "x" + root.tile.rowSpan : ""
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeSm
        color: Colors.fg
    }

    Row {
        spacing: Dimens.spacingSm

        Repeater {
            model: root.sizes

            delegate: Rectangle {
                id: sizeBtn
                required property var modelData
                readonly property bool active: root.tile && root.tile.colSpan === sizeBtn.modelData.c && root.tile.rowSpan === sizeBtn.modelData.r

                width: sizeLabel.implicitWidth + Dimens.paddingMd
                height: 24
                radius: Dimens.radiusFull
                color: sizeBtn.active ? Colors.accent : Colors.subBgMica
                border.width: 1
                border.color: Colors.border

                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    id: sizeLabel
                    anchors.centerIn: parent
                    text: sizeBtn.modelData.c + "x" + sizeBtn.modelData.r
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeXSm
                    color: sizeBtn.active ? Colors.bg : Colors.fg
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        ControlCenterLayoutService.pushUndoSnapshot()
                        ControlCenterLayoutService.resizeTile(root.tileId, sizeBtn.modelData.c, sizeBtn.modelData.r)
                    }
                }
            }
        }
    }

    Item { Layout.fillWidth: true }

    SettingsButton {
        text: "Remove"
        onClicked: ControlCenterLayoutService.removeTile(root.tileId)
    }
}