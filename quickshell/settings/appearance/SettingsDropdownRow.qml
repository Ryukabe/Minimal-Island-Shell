// settings/appearance/SettingsDropdownRow.qml
import QtQuick
import QtQuick.Layouts
import "../common"
import "../../styles"

Item {
    id: root

    property string label: ""
    property var options: []
    property string selectedValue: ""
    property bool isOpen: false
    property real popupWidth: 240

    signal toggled()
    signal optionSelected(string value)

    Layout.fillWidth: true
    implicitHeight: row.implicitHeight
    z: root.isOpen ? 200 : 1

    SettingsRow {
        id: row
        anchors.fill: parent
        label: root.label
        value: root.selectedValue
        showChevron: true
        showDivider: false
        onClicked: root.toggled()
    }

    Rectangle {
        visible: root.isOpen
        width: root.popupWidth
        anchors.top: parent.bottom
        anchors.topMargin: 4
        anchors.right: parent.right
        color: Colors.elevatedBg
        radius: Dimens.radiusMedium
        border.color: Qt.rgba(1, 1, 1, 0.12)
        border.width: 1
        z: 210
        height: Math.min(optionsList.contentHeight + 8, 180)

        MouseArea {
            anchors.fill: parent
            onWheel: (wheel) => {
                optionsList.contentY = Math.max(0, Math.min(optionsList.contentY - wheel.angleDelta.y, optionsList.contentHeight - optionsList.height))
                wheel.accepted = true
            }
        }

        ListView {
            id: optionsList
            anchors.fill: parent
            anchors.margins: 4
            clip: true
            model: root.options

            delegate: Item {
                width: optionsList.width
                height: 36

                property bool isSelected: modelData === root.selectedValue
                property bool isHighlighted: optMouse.containsMouse || isSelected

                Rectangle {
                    anchors.fill: parent
                    color: isHighlighted ? Colors.accent : "transparent"
                    opacity: isHighlighted ? (isSelected ? 0.3 : 0.15) : 0
                    radius: Dimens.radiusSmall
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    Text {
                        text: modelData
                        color: Colors.fg
                        font.family: modelData
                        font.pixelSize: Dimens.fontSizeBase
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        visible: isSelected
                        text: "check"
                        color: Colors.accent
                        font.family: Fonts.icon
                        font.pixelSize: Dimens.fontSizeMd
                    }
                }

                MouseArea {
                    id: optMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.optionSelected(modelData)
                }
            }
        }
    }
}