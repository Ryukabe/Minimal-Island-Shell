// settings/common/SettingsToggleRow.qml
import QtQuick
import QtQuick.Layouts
import "../../styles"

Item {
    id: root
    property string label: ""
    property bool checked: false
    property bool showDivider: true
    signal toggled(bool checked)

    Layout.fillWidth: true
    implicitHeight: 44

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        spacing: Dimens.spacingSmall

        Text {
            text: root.label
            color: Colors.fg
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeBase
            Layout.fillWidth: true
        }

        // Custom, unboxed toggle switch with dynamic accent color
        Rectangle {
            id: toggleTrack
            implicitWidth: 40
            implicitHeight: 22
            radius: height / 2
            color: root.checked ? Colors.accent : Colors.elevatedBg
            border.color: root.checked ? Colors.accent : Colors.border
            border.width: 1

            Behavior on color { ColorAnimation { duration: 150 } }

            Rectangle {
                id: toggleHandle
                width: 16
                height: 16
                radius: 8
                x: root.checked ? toggleTrack.width - width - 3 : 3
                anchors.verticalCenter: parent.verticalCenter
                color: root.checked ? Colors.fg : Colors.fg

                Behavior on x {
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggled(!root.checked)
            }
        }
    }

    Rectangle {
        visible: root.showDivider
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        height: 1
        color: Colors.border
        opacity: 0.35
    }
}