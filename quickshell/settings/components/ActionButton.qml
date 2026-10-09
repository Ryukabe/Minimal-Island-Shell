// components/ActionButton.qml — small button. `primary` = accent fill. `busy` shows "…" and ignores clicks.
import QtQuick
import "../../styles"
import "../../services"

Rectangle {
    id: root

    property string text: ""
    property bool primary: false
    property bool busy: false
    signal clicked()

    implicitHeight: 34
    implicitWidth: buttonLabel.implicitWidth + Dimens.paddingLarge * 2
    radius: Dimens.settingsControlRadius
    color: root.primary ? Colors.accent : Colors.elevatedBg
    opacity: root.enabled ? 1.0 : 0.4

    Behavior on opacity {
        NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
    }

    // Hover tint on top of the base colour
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: Colors.fg
        opacity: (buttonMouse.containsMouse && root.enabled && !root.busy) ? 0.08 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
        }
    }

    Text {
        id: buttonLabel
        anchors.centerIn: parent
        text: root.busy ? root.text + "…" : root.text
        color: root.primary ? Colors.mainBgMica : Colors.fg
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeBase
        font.weight: Font.Medium
    }

    MouseArea {
        id: buttonMouse
        anchors.fill: parent
        enabled: root.enabled && !root.busy
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
