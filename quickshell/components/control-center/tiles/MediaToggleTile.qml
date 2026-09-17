// components/control-center/tiles/MediaToggleTile.qml
import QtQuick
import QtQuick.Layouts
import "../../../styles"
import "../../../services"

Rectangle {
    id: tile

    radius: ShellState.islandCornerRadius
    color: Colors.subBgMica
    border.width: 1
    border.color: Colors.border
    clip: true

    readonly property bool hasArt: AudioService.artUrl !== ""

    Behavior on color { ColorAnimation { duration: 150 } }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Dimens.paddingMd
        spacing: Dimens.spacingMd

        // ---- Album art ----
        Rectangle {
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64
            Layout.alignment: Qt.AlignVCenter
            radius: ShellState.islandCornerRadius
            color: Colors.mainBgMica
            clip: true

            Image {
                anchors.fill: parent
                source: AudioService.artUrl
                fillMode: Image.PreserveAspectCrop
                visible: tile.hasArt
            }

            Text {
                anchors.centerIn: parent
                text: "music_note"
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeXxl
                font.variableAxes: Fonts.iconAxes
                color: Colors.fgMuted
                visible: !tile.hasArt
            }
        }

        // ---- Track info + transport controls ----
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            Text {
                Layout.fillWidth: true
                text: AudioService.trackTitle
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeSm
                font.bold: true
                color: Colors.fg
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: AudioService.trackArtist
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXSm
                color: Colors.fgMuted
                elide: Text.ElideRight
            }

            RowLayout {
                Layout.topMargin: 6
                Layout.alignment: Qt.AlignHCenter
                spacing: 18

                Text {
                    text: "skip_previous"
                    font.family: Fonts.icon
                    font.pixelSize: Dimens.fontSizeXl
                    font.variableAxes: Fonts.iconAxes
                    color: prevMouse.containsMouse ? Colors.accent : Colors.fg

                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: AudioService.previousTrack()
                    }
                }

                Rectangle {
                    id: playButton
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: Dimens.radiusFull
                    color: Colors.accent
                    scale: playMouse.pressed ? 0.9 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: Motion.hoverMs; easing.type: Easing.OutCubic }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: AudioService.isPlaying ? "pause" : "play_arrow"
                        font.family: Fonts.icon
                        font.pixelSize: Dimens.fontSizeLg
                        font.variableAxes: Fonts.iconAxesFilled
                        color: Colors.bg
                    }

                    MouseArea {
                        id: playMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: AudioService.togglePlayPause()
                    }
                }

                Text {
                    text: "skip_next"
                    font.family: Fonts.icon
                    font.pixelSize: Dimens.fontSizeXl
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