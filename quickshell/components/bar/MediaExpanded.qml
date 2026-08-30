// components/bar/MediaExpanded.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../styles"
import "../../services"

Rectangle {
    id: root
    
    implicitWidth: 640
    implicitHeight: 110
    color: Colors.bg
    radius: Dimens.borderRadiusLarge
    clip: true // Prevents album art & track info overflow during island expansion

  /*  // Synchronized opacity behavior
    Behavior on opacity {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }*/

    RowLayout {
        anchors.fill: parent
        anchors.margins: Dimens.marginMedium
        spacing: 12

        // Album Art Thumbnail
        Rectangle {
            Layout.preferredWidth: 60
            Layout.preferredHeight: 60
            Layout.alignment: Qt.AlignVCenter
            radius: Dimens.borderRadiusSmall
            color: Colors.surface
            clip: true

            Image {
                anchors.fill: parent
                source: AudioService.artUrl
                fillMode: Image.PreserveAspectCrop
                visible: AudioService.artUrl !== ""
            }

            Text {
                anchors.centerIn: parent
                text: "󰎈"
                font.family: "JetBrains Mono Nerd Font Propo"
                font.pixelSize: Dimens.fontSizeHuge
                color: Colors.subtext
                visible: AudioService.artUrl === ""
            }
        }

        // Track Details
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                text: AudioService.trackTitle || "No Media Playing"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeMd
                font.bold: true
                color: Colors.fg
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: AudioService.artistName || "Unknown Artist"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeSm
                color: Colors.fgMuted
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.alignment: Qt.AlignHLeft
                Layout.topMargin: 4
                spacing: 16

                Text {
                    text: "󰒮"
                    font.family: "JetBrains Mono Nerd Font Propo"
                    font.pixelSize: Dimens.fontSizeXl
                    color: Colors.fg

                    MouseArea {
                        anchors.fill: parent
                        onClicked: AudioService.previousTrack()
                    }
                }

                Text {
                    text: AudioService.isPlaying ? "󰏤" : "󰐊"
                    font.family: "JetBrains Mono Nerd Font Propo"
                    font.pixelSize: Dimens.fontSizeXxl
                    color: Colors.accent

                    MouseArea {
                        anchors.fill: parent
                        onClicked: AudioService.togglePlayPause()
                    }
                }

                Text {
                    text: "󰒭"
                    font.family: "JetBrains Mono Nerd Font Propo"
                    font.pixelSize: Dimens.fontSizeXl
                    color: Colors.fg

                    MouseArea {
                        anchors.fill: parent
                        onClicked: AudioService.nextTrack()
                    }
                }
            }
        }
    }
}