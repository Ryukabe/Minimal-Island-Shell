import QtQuick
import QtQuick.Layouts
import Quickshell
import "../styles"
import "../services"

Rectangle {
    id: root
    implicitWidth: 520
    implicitHeight: 172
    color: Colors.bg
    radius: Dimens.radiusXLarge
    focus: true

    // Request keyboard focus immediately on reveal
    Component.onCompleted: root.forceActiveFocus()

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    function dayAt(offset) {
        var d = new Date(clock.date)
        d.setDate(d.getDate() + offset)
        return d
    }

    // ================= MEDIA PLAYER (left side top) =================
    Item {
        id: mediaSection
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 16
        width: 250
        height: 72

        Rectangle {
            id: art
            anchors.left: parent.left
            anchors.top: parent.top
            width: 72
            height: 72
            radius: Dimens.radiusMediumLarge
                color: Colors.subBgMica
            clip: true

            Image {
                anchors.fill: parent
                source: AudioService.artUrl
                fillMode: Image.PreserveAspectCrop
                visible: AudioService.artUrl !== ""
                asynchronous: true
            }
            Text {
                anchors.centerIn: parent
                text: "󰎈"
                font.family: Fonts.icon || "JetBrainsMono Nerd Font"
                font.pixelSize: Dimens.fontSizeXxxl
                color: Colors.subtext
                visible: AudioService.artUrl === ""
            }
        }

        Column {
            anchors.left: art.right
            anchors.leftMargin: 14
            anchors.verticalCenter: art.verticalCenter
            spacing: 4

            Text {
                text: AudioService.trackTitle || "No Media Playing"
                color: Colors.fg
                font.pixelSize: Dimens.fontSizeBase
                font.bold: true
                elide: Text.ElideRight
                width: 150
            }
            Text {
                text: AudioService.trackArtist || "Unknown Artist"
                color: Colors.fgMuted
                font.pixelSize: Dimens.fontSizeXSm
                elide: Text.ElideRight
                width: 150
            }

            Row {
                spacing: 16
                topPadding: 4

                Text {
                    text: "󰒮"
                    color: Colors.fg
                    font.family: Fonts.icon || "JetBrainsMono Nerd Font"
                    font.pixelSize: Dimens.fontSizeXl
                    TapHandler { onTapped: AudioService.previousTrack() }
                }

                Text {
                    text: AudioService.isPlaying ? "󰏤" : "󰐊"
                    color: Colors.fg
                    font.family: Fonts.icon || "JetBrainsMono Nerd Font"
                    font.pixelSize: Dimens.fontSizeXl
                    TapHandler { onTapped: AudioService.togglePlayPause() }
                }

                Text {
                    text: "󰒭"
                    color: Colors.fg
                    font.family: Fonts.icon || "JetBrainsMono Nerd Font"
                    font.pixelSize: Dimens.fontSizeXl
                    TapHandler { onTapped: AudioService.nextTrack() }
                }
            }
        }
    }

    // ================= TIMER CARD (left side bottom) =================
    Rectangle {
        id: timerCard
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.top: mediaSection.bottom
        anchors.topMargin: 16
        width: 250
        height: 40
        radius: Dimens.borderRadiusMedium
        color: Colors.bgSurface

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 12

            Text {
                text: "󱎫" // Replaced hourglass with unified Nerd Font Timer icon
                font.family: Fonts.icon || "JetBrainsMono Nerd Font"
                font.pixelSize: Dimens.fontSizeMd
                color: Colors.accent
            }

            Text {
                text: "Timer"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeMd
                color: Colors.fg
            }

            Item { Layout.fillWidth: true }

            Text {
                text: TimerService.secondsRemaining > 0 
                    ? TimerService.formatTime(TimerService.secondsRemaining) 
                    : "Off"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeSm
                color: Colors.fgMuted
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: ShellState.showPage("timer")
        }
    }

    // ================= CLOCK + CALENDAR (right side) =================
    Column {
        anchors.right: parent.right
        anchors.rightMargin: 18
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "hh:mm AP")
            color: Colors.fg
            font.family: Fonts.display
            font.pixelSize: Dimens.fontSizeXxl
            font.weight: 800
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12

            Repeater {
                model: [-2, -1, 0, 1, 2]

                delegate: Column {
                    readonly property date dayDate: root.dayAt(modelData)
                    readonly property bool isToday: modelData === 0
                    readonly property bool isFriday: dayDate.getDay() === 5
                    spacing: 4

                    Rectangle {
                        width: isToday ? 26 : 22
                        height: isToday ? 26 : 22
                        radius: width / 2
                        color: isToday ? Colors.accent : "transparent"
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            anchors.centerIn: parent
                            text: Qt.formatDateTime(dayDate, "d")
                            color: isToday ? Colors.bg : (isFriday ? Colors.red : Colors.fg)
                            font.pixelSize: isToday ? 12 : 11
                            font.bold: isToday
                        }
                    }

                    Text {
                        text: Qt.formatDateTime(dayDate, "ddd")
                        color: isFriday ? Colors.red : (isToday ? Colors.accent : Colors.fgMuted)
                        font.pixelSize: Dimens.fontSizeXs
                        font.bold: isToday || isFriday
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
}