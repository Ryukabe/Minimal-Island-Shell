// Small icon button for Dashboard components: a Material icon that turns accent on hover.
import QtQuick
import "../../../core/shell"
import "../../../core/styles"

Item {
    id: root

    property alias text: label.text
    property bool active: false
    signal clicked()

    implicitWidth: Math.max(28, label.implicitWidth)
    implicitHeight: Math.max(28, label.implicitHeight)

    Text {
        id: label
        anchors.centerIn: parent
        font.family: Fonts.icon
        font.pixelSize: Dimens.fontSizeLg
        font.variableAxes: Fonts.iconAxes
        color: (root.active || mouse.containsMouse) ? Colors.accent : Colors.fgMuted

        Behavior on color {
            ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}