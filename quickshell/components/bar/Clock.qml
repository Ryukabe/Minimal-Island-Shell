import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../services"
import "../../styles"

Item {
    id: root

    implicitWidth: Math.max(140, layout.implicitWidth + 32)
    implicitHeight: Math.max(36, layout.implicitHeight + 8)

    // Only ticks every second while the user has "Show Seconds" on.
    SystemClock {
        id: clock
        precision: ShellState.clockShowSeconds ? SystemClock.Seconds : SystemClock.Minutes
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 14 // Increased overall spacing between items

        // 1. Music Visualizer (Left)
        RowLayout {
            spacing: 3
            visible: ShellState.clockShowVisualizer && AudioService.isPlaying
            Layout.alignment: Qt.AlignVCenter

            Repeater {
                model: 4
                Item {
                    implicitWidth: 3
                    implicitHeight: 10

                    Rectangle {
                        width: parent.implicitWidth
                        color: Colors.accent
                        radius: ShellState.islandCornerRadius
                        anchors.bottom: parent.bottom

                        SequentialAnimation on height {
                            running: ShellState.clockShowVisualizer && AudioService.isPlaying
                            loops: Animation.Infinite

                            NumberAnimation {
                                to: 3 + ((index % 3) * 2)
                                duration: 420 + (index * 110)
                                easing.type: Easing.InOutSine
                            }
                            NumberAnimation {
                                to: 10 - ((index % 2) * 3)
                                duration: 480 + (index * 90)
                                easing.type: Easing.InOutSine
                            }
                        }
                    }
                }
            }
        }

        // 2. Date (optional, before the time)
        Text {
            visible: ShellState.clockDateStyle > 0
            text: Qt.formatDateTime(clock.date, ShellState.clockDateFormat)
            color: Colors.fgMuted
            Layout.alignment: Qt.AlignVCenter
            font {
                family: Fonts.display
                pixelSize: 13
                weight: 500
            }
        }

        // 3. Clock Display (Middle)
        Text {
            text: Qt.formatDateTime(clock.date, ShellState.clockTimeFormat)
            color: Colors.fg
            font {
                family: Fonts.display
                pixelSize: 13
                weight: 700
            }
        }

        // 4. Timer Quick Icon (Right Side - Click toggles global timer page)
        Text {
            text: "timer"
            font.family: Fonts.icon
            font.pixelSize: 14
            color: TimerService.running || TimerService.secondsRemaining > 0 ? Colors.accent : Colors.fgMuted
            Layout.alignment: Qt.AlignVCenter
            visible: ShellState.clockShowTimerIcon && (TimerService.secondsRemaining > 0 || TimerService.running)

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    ShellState.togglePage("timertoast")
                }
            }
        }

        // 5. Recording Indicator (Right) — always shown, not user-hideable
        RecordingIndicator {
            active: RecordingService.enabled
            dotSize: 6
            dotColor: Colors.red
            Layout.alignment: Qt.AlignVCenter
        }
    }
}