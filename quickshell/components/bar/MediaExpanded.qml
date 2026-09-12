// components/bar/MediaExpanded.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../styles"
import "../../services"

Rectangle {
    id: root
    
    implicitWidth: 320
    implicitHeight: 90
    
    // Distinct solid-tinted card background so it stands out clearly inside the panel
    color: Qt.tint(Colors.bg, Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.15))
    border.color: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.4)
    border.width: 1
    
    radius: Dimens.borderRadiusLarge
    clip: true

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 14

        // Album Art Thumbnail
        Rectangle {
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64
            Layout.alignment: Qt.AlignVCenter
            radius: Dimens.borderRadiusSmall
            color: Colors.subBgMica
            clip: true

            Image {
                anchors.fill: parent
                source: AudioService.artUrl
                fillMode: Image.PreserveAspectCrop
                visible: AudioService.artUrl !== ""
            }

            Text {
                anchors.centerIn: parent
                text: "music_note"
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeHuge
                font.variableAxes: Fonts.iconAxes
                color: Colors.subtext
                visible: AudioService.artUrl === ""
            }
        }

        // Track Details & Controls
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            Text {
                text: AudioService.trackTitle || "No Media Playing"
                font.family: Fonts.text
                font.pixelSize: 13
                font.bold: true
                color: Colors.fg
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: AudioService.artistName || "Unknown Artist"
                font.family: Fonts.text
                font.pixelSize: 11
                color: Colors.fgMuted
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            // Playback Controls Row
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 2
                spacing: 20

                // Previous Button
                Text {
                    text: "skip_previous"
                    font.family: Fonts.icon
                    font.pixelSize: 20
                    font.variableAxes: Fonts.iconAxes
                    color: prevMouse.containsMouse ? Colors.accent : Colors.fg

                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: AudioService.previousTrack()
                    }
                }

                // Play/Pause Button
                Text {
                    text: AudioService.isPlaying ? "pause" : "play_arrow"
                    font.family: Fonts.icon
                    font.pixelSize: 24
                    font.variableAxes: Fonts.iconAxesFilled
                    color: Colors.accent

                    MouseArea {
                        id: playMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: AudioService.togglePlayPause()
                    }
                }

                // Next Button
                Text {
                    text: "skip_next"
                    font.family: Fonts.icon
                    font.pixelSize: 20
                    font.variableAxes: Fonts.iconAxes
                    color: nextMouse.containsMouse ? Colors.accent : Colors.fg

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: AudioService.nextTrack()
                    }
                }
            }
        }
    }
}