import QtQuick
import "../../core/shell"
import "../../core/styles"

Rectangle {
    id: root

    property string icon: ""
    property real size: 44
    signal clicked()

    implicitWidth: size
    implicitHeight: size
    radius: size / 2
    color: mouse.containsMouse ? Colors.accent : Colors.subBgMica
    border.width: 1
    border.color: Colors.border

    scale: mouse.pressed ? 0.92 : (mouse.containsMouse ? 1.1 : 1.0)

    Behavior on scale {
        NumberAnimation {
            duration: ShellState.motionDuration(Motion.snapMs)
            easing.type: Easing.OutCubic
        }
    }
    Behavior on color {
        ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: Fonts.icon
        font.pixelSize: Dimens.fontSizeXl
        font.variableAxes: Fonts.iconAxes
        font.features: { "liga": 1, "dlig": 1 }
        color: mouse.containsMouse ? Colors.bg : Colors.fg
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}