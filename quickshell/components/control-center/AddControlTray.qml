import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"

ColumnLayout {
    id: root
    spacing: Dimens.spacingSm

    Text {
        text: "Add a control"
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeSm
        color: Colors.fgMuted
    }

    Flow {
        Layout.fillWidth: true
        spacing: Dimens.spacingSm

        // Adds the type to the grid at its smallest allowed size,
        // first-fit positioned.
        Repeater {
            model: ControlCenterLayoutService.unplacedTypes()

            delegate: Rectangle {
                id: addBtn
                required property string modelData
                readonly property var size: ControlCenterLayoutService.defaultSizeForType(addBtn.modelData)

                width: addLabel.implicitWidth + Dimens.paddingLg
                height: 36
                radius: Dimens.radiusFull
                color: Colors.subBgMica
                border.width: 1
                border.color: Colors.border

                Text {
                    id: addLabel
                    anchors.centerIn: parent
                    text: (ControlCenterLayoutService.typeDisplayNames[addBtn.modelData] || addBtn.modelData) + "  " + addBtn.size.c + "x" + addBtn.size.r
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeXSm
                    color: Colors.fg
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ControlCenterLayoutService.addTile(addBtn.modelData)
                }
            }
        }
    }
}