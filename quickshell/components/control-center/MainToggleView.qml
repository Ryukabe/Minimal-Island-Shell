pragma ComponentBehavior: Bound

import QtQuick
import "../../styles"
import "../../services"

Item {
    id: root
    implicitWidth: 580
    implicitHeight: grid.implicitHeight + 32

    signal subviewRequestedFor(string viewName)

    Text {
        id: editToggle
        text: grid.editMode ? "Done" : "Edit Layout"
        color: Colors.accent
        font.pixelSize: Dimens.fontSizeSm
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 16

        MouseArea {
            anchors.fill: parent
            anchors.margins: -8
            cursorShape: Qt.PointingHandCursor
            onClicked: grid.editMode = !grid.editMode
        }
    }

    ControlGrid {
        id: grid
        anchors.top: editToggle.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        
        onSubviewRequestedFor: (type) => root.subviewRequestedFor(type)
    }
}