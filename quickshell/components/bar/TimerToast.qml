import QtQuick
import QtQuick.Layouts
import "../../modules"
import "../../styles"
import "../../services"

Item {
    id: root

    implicitWidth: contentRow.implicitWidth + 36
    implicitHeight: 36

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 12

        RowLayout {
            spacing: 8

            Text {
                text: "timer"
                font.family: Fonts.icon 
                font.pixelSize: Dimens.fontSizeMd
                font.variableAxes: Fonts.iconAxes
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

        RowLayout {
            spacing: 6

            // -5m button
            Rectangle {
                width: 24
                height: 24
                color: Colors.bgMica
                radius: Dimens.islandRadius // Added radius

                Text {
                    anchors.centerIn: parent
                    text: "replay_5"
                    font.family: Fonts.icon
                    font.pixelSize: Dimens.fontSizeMd
                    font.variableAxes: Fonts.iconAxes
                    color: Colors.fg
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var newSeconds = Math.max(0, TimerService.secondsRemaining - 300)
                        if (newSeconds === 0) {
                            TimerService.reset()
                        } else {
                            TimerService.start(newSeconds)
                        }
                    }
                }
            }

            // +5m button
            Rectangle {
                width: 24
                height: 24
                color: Colors.bgMica
                radius: Dimens.islandRadius // Added radius

                Text {
                    anchors.centerIn: parent
                    text: "forward_5"
                    font.family: Fonts.icon
                    font.pixelSize: Dimens.fontSizeMd
                    font.variableAxes: Fonts.iconAxes
                    color: Colors.fg
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        TimerService.start(TimerService.secondsRemaining + 300)
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1 
        cursorShape: Qt.PointingHandCursor
        onClicked: ShellState.togglePage("clock")
    }
}