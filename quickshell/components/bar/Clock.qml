import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../styles"
import "../../services"

Item {
    id: root

    implicitWidth: Math.max(140, layout.implicitWidth + 32)
    implicitHeight: Math.max(36, layout.implicitHeight + 8)

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 14 // Increased overall spacing between items

        // 1. Music Visualizer (Left)
        RowLayout {
            spacing: 3
            visible: AudioService.isPlaying
            Layout.alignment: Qt.AlignVCenter

            Repeater {
                model: 4
                Item {
                    implicitWidth: 3
                    implicitHeight: 10

                    Rectangle {
                        width: parent.implicitWidth
                        color: Colors.accent
                        radius: 1.5
                        anchors.bottom: parent.bottom

                        SequentialAnimation on height {
                            running: AudioService.isPlaying
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

        // 2. Clock Display (Middle)
        Text {
            text: Qt.formatDateTime(clock.date, "hh:mm AP")
            color: Colors.fg
            font {
                family: Fonts.display
                pixelSize: 13
                weight: 700
            }
        }

        // 3. Timer Quick Icon (Right Side - Click toggles global timer page)
        Text {
            text: "timer"
            font.family: Fonts.icon
            font.pixelSize: 14
            color: TimerService.running || TimerService.secondsRemaining > 0 ? Colors.accent : Colors.fgMuted
            Layout.alignment: Qt.AlignVCenter
            visible: TimerService.secondsRemaining > 0 || TimerService.running 

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    ShellState.togglePage("timertoast")
                }
            }
        }

        // 4. Recording Indicator (Right)
        RecordingIndicator {
            active: RecordingService.enabled
            dotSize: 6
            dotColor: Colors.red
            Layout.alignment: Qt.AlignVCenter
        }
    }
}