// moules/TimerModule.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../styles"
import "../services"
import "../components/bar"

Item {
    id: root

    implicitWidth: ShellState.timerWidth
    implicitHeight: ShellState.timerHeight

    property int selectedMinutes: 5

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Timer"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeLg
                font.bold: true
                color: Colors.fg
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "󱎫"
                font.family: Fonts.icon || "JetBrainsMono Nerd Font"
                font.pixelSize: Dimens.fontSizeLg
                color: Colors.accent
            }
        }

        // Display or Preset Controls
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.centerIn: parent
                visible: TimerService.secondsRemaining > 0 || TimerService.running
                spacing: 8

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: TimerService.formatTime(TimerService.secondsRemaining)
                    font.family: Fonts.text
                    font.pixelSize: 36
                    font.bold: true
                    color: Colors.fg
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 12

                    Rectangle {
                        width: 70
                        height: 32
                        radius: 16
                        color: Colors.bgSurface
                        Text {
                            anchors.centerIn: parent
                            text: TimerService.running ? "Pause" : "Resume"
                            color: Colors.fg
                            font.pixelSize: Dimens.fontSizeSm
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: TimerService.togglePause()
                        }
                    }

                    Rectangle {
                        width: 70
                        height: 32
                        radius: 16
                        color: Colors.bgSurface
                        Text {
                            anchors.centerIn: parent
                            text: "Reset"
                            color: Colors.fg
                            font.pixelSize: Dimens.fontSizeSm
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: TimerService.reset()
                        }
                    }
                }
            }

            // Quick Preset Selection (when idle)
            ColumnLayout {
                anchors.centerIn: parent
                visible: TimerService.secondsRemaining === 0 && !TimerService.running
                spacing: 12

                RowLayout {
                    spacing: 8
                    Repeater {
                        model: [1, 5, 10, 15, 25]
                        Rectangle {
                            width: 44
                            height: 36
                            radius: 8
                            color: root.selectedMinutes === modelData ? Colors.accent : Colors.bgSurface
                            Text {
                                anchors.centerIn: parent
                                text: modelData + "m"
                                color: root.selectedMinutes === modelData ? Colors.bg : Colors.fg
                                font.bold: true
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.selectedMinutes = modelData
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 120
                    height: 36
                    radius: 18
                    color: Colors.accent
                    Text {
                        anchors.centerIn: parent
                        text: "Start Timer"
                        color: Colors.bg
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: TimerService.start(root.selectedMinutes * 60)
                    }
                }
            }
        }
    }
}