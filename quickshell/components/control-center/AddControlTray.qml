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

        // Real, functional — adds the type to the grid at its smallest
        // allowed size, first-fit positioned.
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

        // Decorative only — matches the reference mockup's UI but has no
        // backend type, no tile component, and no click behavior. Confirm
        // with Alvi before wiring any of these up for real.
        Repeater {
            model: [
                { label: "Peace", size: "4x1" },
                { label: "Night Light", size: "1x1" },
                { label: "Game Mode", size: "1x1" },
                { label: "Lock", size: "1x1" }
            ]

            delegate: Rectangle {
                id: mockBtn
                required property var modelData

                width: mockLabel.implicitWidth + Dimens.paddingLg
                height: 36
                radius: Dimens.radiusFull
                color: Colors.subBgMica
                opacity: 0.5
                border.width: 1
                border.color: Colors.border

                Text {
                    id: mockLabel
                    anchors.centerIn: parent
                    text: mockBtn.modelData.label + "  " + mockBtn.modelData.size
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeXSm
                    color: Colors.fgMuted
                }
            }
        }
    }
}