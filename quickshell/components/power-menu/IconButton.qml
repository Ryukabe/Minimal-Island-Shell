import QtQuick
import "../../styles"

Rectangle {
    id: root
    property string iconSource: ""
    property string iconHoverSource: ""
    property bool selected: false
    signal clicked()

    width: 44
    height: 44
    radius: Dimens.radiusLarge
    color: (mouseArea.containsMouse || root.selected) ? Colors.bgSurface : "transparent"
    Behavior on color { ColorAnimation { duration: 120 } }

    Image {
        anchors.centerIn: parent
        source: (mouseArea.containsMouse || root.selected) && root.iconHoverSource !== "" 
            ? root.iconHoverSource 
            : root.iconSource
        width: 22
        height: 22
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        sourceSize.width: 64
        sourceSize.height: 64
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    scale: mouseArea.pressed ? 0.95 : 1.0
    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
}