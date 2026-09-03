import QtQuick
import "../../styles"

Item {
    id: root
    property bool checked: false
    signal toggled(bool checked)

    implicitWidth: 44
    implicitHeight: 24

    Rectangle {
        id: track
        anchors.fill: parent
        radius: Dimens.radiusFull
        color: root.checked ? Colors.accent : Colors.surface
        border.width: root.checked ? 0 : 1
        border.color: Colors.border

        Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }

        Rectangle {
            id: knob
            width: parent.height - 4
            height: parent.height - 4
            radius: Dimens.radiusFull
            color: Colors.white
            anchors.verticalCenter: parent.verticalCenter
            x: root.checked ? parent.width - width - 2 : 2

            Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
}