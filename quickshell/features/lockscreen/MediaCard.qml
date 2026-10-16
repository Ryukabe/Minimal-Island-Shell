// features/lockscreen/MediaCard.qml
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "."
import "../sound"
import "../../core/shell"
import "../../core/styles"

Item {
    id: root

    property bool entrance: false   // lock screen: fade/slide in like the other blocks

    readonly property var player: AudioService.activePlayer
    readonly property bool hideDetails: LockScreenSettings.mediaHideDetails
    readonly property bool hasArt: !root.hideDetails && AudioService.artUrl !== ""

    readonly property real pad: 12
    readonly property real artSize: 72
    readonly property real cornerRadius: ShellState.islandCornerRadius
    readonly property real artRadius: Math.max(4, root.cornerRadius - root.pad)

    readonly property bool canShowProgress: root.player !== null
        && root.player.positionSupported && root.player.lengthSupported && root.player.length > 0
    readonly property real ratio: root.canShowProgress
        ? Math.max(0, Math.min(1, root.player.position / root.player.length)) : 0

    visible: LockScreenSettings.showMedia && root.player !== null
    width: 340
    height: root.artSize + root.pad * 2
    opacity: 0

    transform: Translate { id: slide; y: 18 }

    Component.onCompleted: {
        if (root.entrance) {
            enterAnim.start()
        } else {
            root.opacity = 1
            slide.y = 0
        }
    }

    SequentialAnimation {
        id: enterAnim
        PauseAnimation { duration: ShellState.motionDuration(520) }
        ParallelAnimation {
            NumberAnimation { target: root; property: "opacity"; from: 0; to: 1; duration: ShellState.motionDuration(450); easing.type: Easing.OutCubic }
            NumberAnimation { target: slide; property: "y"; from: 18; to: 0; duration: ShellState.motionDuration(520); easing.type: Easing.OutCubic }
        }
    }

    // MPRIS doesn't push position updates, so nudge it once a second while playing.
    Timer {
        interval: 1000
        repeat: true
        running: root.visible && AudioService.isPlaying && root.canShowProgress
        onTriggered: root.player.positionChanged()
    }

    // Tint + frosted base
    Rectangle {
        id: card
        anchors.fill: parent
        radius: root.cornerRadius
        color: Colors.darkMode ? Qt.rgba(0, 0, 0, 0.35) : Qt.rgba(1, 1, 1, 0.35)
    }

    // Blurred album art behind everything, rounded to the card
    Item {
        anchors.fill: parent
        visible: LockScreenSettings.mediaBlurBackdrop && root.hasArt
        layer.enabled: visible
        layer.effect: OpacityMask {
            maskSource: Rectangle { width: card.width; height: card.height; radius: card.radius }
        }

        Image {
            id: backdropArt
            anchors.fill: parent
            source: AudioService.artUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: false
        }

        FastBlur {
            anchors.fill: parent
            source: backdropArt
            radius: 48
            opacity: 0.6
        }
    }

    // Outline on top
    Rectangle {
        anchors.fill: parent
        radius: root.cornerRadius
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(Colors.border.r, Colors.border.g, Colors.border.b, 0.5)
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: root.pad
        spacing: 14

        // Album art
        Item {
            Layout.preferredWidth: root.artSize
            Layout.preferredHeight: root.artSize
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                anchors.fill: parent
                radius: root.artRadius
                color: Colors.subBgMica
                visible: !root.hasArt

                Text {
                    anchors.centerIn: parent
                    text: "music_note"
                    font.family: Fonts.icon
                    font.pixelSize: Dimens.fontSizeHuge
                    font.variableAxes: Fonts.iconAxes
                    color: Colors.fgMuted
                }
            }

            Image {
                anchors.fill: parent
                source: root.hasArt ? AudioService.artUrl : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: root.hasArt
                layer.enabled: visible
                layer.effect: OpacityMask {
                    maskSource: Rectangle { width: root.artSize; height: root.artSize; radius: root.artRadius }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                text: AudioService.isPlaying ? "NOW PLAYING" : "PAUSED"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXs
                font.letterSpacing: 2
                color: Colors.fgMuted
            }

            Text {
                Layout.fillWidth: true
                text: root.hideDetails ? "Hidden while locked" : AudioService.trackTitle
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
                font.bold: true
                color: Colors.fg
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                Layout.fillWidth: true
                visible: !root.hideDetails
                text: AudioService.trackArtist
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeSm
                color: Colors.fgMuted
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Row {
                Layout.topMargin: 4
                spacing: 18

                Text {
                    text: "skip_previous"
                    font.family: Fonts.icon
                    font.pixelSize: Dimens.fontSizeXl
                    font.variableAxes: Fonts.iconAxes
                    color: prevArea.containsMouse ? Colors.accent : Colors.fg

                    MouseArea {
                        id: prevArea
                        anchors.fill: parent
                        anchors.margins: -6
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: AudioService.previousTrack()
                    }
                }

                Text {
                    text: AudioService.isPlaying ? "pause" : "play_arrow"
                    font.family: Fonts.icon
                    font.pixelSize: Dimens.fontSizeXl
                    font.variableAxes: Fonts.iconAxesFilled
                    color: playArea.containsMouse ? Colors.accent : Colors.fg

                    MouseArea {
                        id: playArea
                        anchors.fill: parent
                        anchors.margins: -6
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: AudioService.togglePlayPause()
                    }
                }

                Text {
                    text: "skip_next"
                    font.family: Fonts.icon
                    font.pixelSize: Dimens.fontSizeXl
                    font.variableAxes: Fonts.iconAxes
                    color: nextArea.containsMouse ? Colors.accent : Colors.fg

                    MouseArea {
                        id: nextArea
                        anchors.fill: parent
                        anchors.margins: -6
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: AudioService.nextTrack()
                    }
                }
            }

            // Thin progress line
            Item {
                Layout.fillWidth: true
                Layout.topMargin: 4
                implicitHeight: 2
                visible: LockScreenSettings.mediaShowProgress && root.canShowProgress

                Rectangle {
                    anchors.fill: parent
                    radius: 1
                    color: Colors.fg
                    opacity: 0.15
                }

                Rectangle {
                    width: parent.width * root.ratio
                    height: parent.height
                    radius: 1
                    color: Colors.accent
                }
            }
        }
    }
}