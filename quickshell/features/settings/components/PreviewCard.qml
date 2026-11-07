// components/PreviewCard.qml — one choice in a row of mock-up cards, like Windows 11's Taskbar position.
// Put the mock-up inside as children. The selected card gets a bright outline; the label sits under it.
import QtQuick
import "../../../core/styles"
import "../../../core/shell"

Item {
    id: root

    property string label: ""
    property bool selected: false
    default property alias content: screen.data
    signal clicked()

    readonly property int screenHeight: 76

    implicitWidth: 150
    implicitHeight: root.screenHeight + Dimens.spacingSmall + labelText.implicitHeight

    // Selection ring, drawn just outside the screen so the mock-up keeps its full size.
    Rectangle {
        anchors.fill: screen
        anchors.margins: -4
        radius: screen.radius + 4
        color: "transparent"
        border.width: 2
        border.color: Colors.fg
        opacity: root.selected ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
        }
    }

    Rectangle {
        id: screen
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: root.screenHeight
        radius: Dimens.settingsControlRadius
        color: Colors.bg
        border.width: 1
        border.color: cardMouse.containsMouse ? Colors.fgMuted : Colors.border
        clip: true

        Behavior on border.color {
            ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
        }
    }

    Text {
        id: labelText
        anchors.left: parent.left
        anchors.top: screen.bottom
        anchors.topMargin: Dimens.spacingSmall
        text: root.label
        color: Colors.fg
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeBase
    }

    MouseArea {
        id: cardMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}