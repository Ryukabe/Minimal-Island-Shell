import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"

Item {
    id: root

    implicitWidth: contentRow.implicitWidth + 28
    implicitHeight: 36

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: "󱎫"
            font.family: Fonts.icon || "JetBrainsMono Nerd Font"
            font.pixelSize: Dimens.fontSizeMd
            color: Colors.accent
        }

        Text {
            text: TimerService.secondsRemaining > 0 ? TimerService.formatTime(TimerService.secondsRemaining) : "Timer"
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeBase
            font.bold: true
            color: Colors.fg
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: ShellState.togglePage("timer")
    }
}