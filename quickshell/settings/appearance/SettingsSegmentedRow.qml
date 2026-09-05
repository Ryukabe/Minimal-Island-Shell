// settings/components/SettingsSegmentedRow.qml — label + inline segmented button group.
// Currently used for Icon Style; reusable for any future exclusive-choice row.
import QtQuick
import QtQuick.Layouts
import "../../styles"

RowLayout {
    id: root

    property string label: ""
    property var options: []
    property string selectedValue: ""

    signal optionSelected(string value)

    Layout.fillWidth: true
    implicitHeight: 36

    Text {
        text: root.label
        color: Colors.fg
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeBase
        Layout.fillWidth: true
    }

    Rectangle {
        implicitWidth: segmentedRow.implicitWidth + 8
        implicitHeight: 32
        color: Qt.rgba(1, 1, 1, 0.04)
        radius: Dimens.radiusMedium
        border.color: Qt.rgba(1, 1, 1, 0.12)

        RowLayout {
            id: segmentedRow
            anchors.centerIn: parent
            spacing: 2

            Repeater {
                model: root.options

                delegate: Rectangle {
                    required property string modelData
                    property bool isSelected: root.selectedValue === modelData

                    implicitWidth: 72
                    implicitHeight: 26
                    radius: Dimens.radiusSmall
                    color: isSelected ? Colors.accent : (segMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: isSelected ? Colors.fg : Colors.subtext
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeSm
                        font.weight: isSelected ? Font.Medium : Font.Normal
                    }

                    MouseArea {
                        id: segMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.optionSelected(modelData)
                    }
                }
            }
        }
    }
}