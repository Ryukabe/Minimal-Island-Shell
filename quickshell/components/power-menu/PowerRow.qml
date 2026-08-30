import QtQuick
import QtQuick.Layouts
import "../../styles"

Rectangle {
    id: root
    property string label: ""
    property string iconSource: ""
    property string iconHoverSource: ""
    property bool selected: false
    signal activated()

    Layout.fillWidth: true
    height: 44
    radius: Dimens.islandRadius
    color: (ma.containsMouse || root.selected) ? Colors.bgSurface : "transparent"
    Behavior on color { ColorAnimation { duration: 140 } }

    // Active Indicator Bar
    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: (ma.containsMouse || root.selected) ? 3 : 0
        height: 22
        radius: Dimens.radiusXSmall
        color: Colors.fg
        Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
    }

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 14
        spacing: 12

        Image {
            source: (ma.containsMouse || root.selected) && root.iconHoverSource !== ""
                ? root.iconHoverSource
                : root.iconSource
            width: 18
            height: 18
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            sourceSize.width: 64
            sourceSize.height: 64
        }

        Text {
            text: root.label
            color: Colors.fg
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeMd
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }

    scale: ma.pressed ? 0.97 : 1.0
    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
}