pragma ComponentBehavior: Bound

import QtQuick
import "../../styles"
import "../../services"

Item {
    id: root
    implicitWidth: 580
    implicitHeight: grid.implicitHeight + 32

    signal subviewRequestedFor(string viewName)

    ControlGrid {
        id: grid
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        editMode: false

        onSubviewRequestedFor: (type) => root.subviewRequestedFor(type)
    }
}