// Small icon button for Dashboard components: a Material icon that turns accent on hover.
import QtQuick
import "../../../core/shell"
import "../../../core/styles"

Text {
    id: root

    property bool active: false
    signal clicked()

    font.family: Fonts.icon
    font.pixelSize: Dimens.fontSizeLg
    font.variableAxes: Fonts.iconAxes
    color: (root.active || mouse.containsMouse) ? Colors.accent : Colors.fgMuted

    Behavior on color {
        ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        anchors.margins: -Dimens.spacingSm / 2
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}