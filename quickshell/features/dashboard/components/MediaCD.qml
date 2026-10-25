// Media card: a CD that spins while the track plays, with title, artist and transport buttons.
// Reads everything from AudioService, the same source as the Control Center media tile.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import "../../../core/shell"
import "../../../core/styles"
import "../../sound"

DashCard {
    id: card

    readonly property bool hasArt: AudioService.artUrl !== ""
    readonly property real pad: Dimens.paddingMedium
    readonly property real gap: Dimens.spacingMd
    readonly property real innerW: Math.max(0, width - pad * 2)
    readonly property real innerH: Math.max(0, height - pad * 2)
    readonly property real playSize: Dimens.fontSizeXl * 1.8
    readonly property real textH: Dimens.fontSizeMd * 2.4
    readonly property real minCd: Dimens.fontSizeXxxl * 2.5

    // row = CD left, text and buttons right. stack = CD on top. mini = CD only (tap to play/pause).
    readonly property string mode: innerW >= innerH * 1.5 ? "row"
        : (innerH >= minCd + gap * 2 + textH + playSize ? "stack" : "mini")

    // ---- Blurred, tinted cover background (same recipe as the Control Center media tile) ----
    readonly property int bgDecodeSize: 128
    readonly property real bgBlurMax: 48
    readonly property real bgBrightness: -0.2
    readonly property real bgSaturation: 0.3
    readonly property real scrimOpacity: 0.35
    readonly property bool bgReady: ShellState.dashboardMediaBlurBackground && hasArt && bgImage.status === Image.Ready

    Image {
        id: bgImage
        anchors.fill: parent
        source: ShellState.dashboardMediaBlurBackground ? AudioService.artUrl : ""
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: card.bgDecodeSize
        sourceSize.height: card.bgDecodeSize
        asynchronous: true
        visible: false
    }

    Item {
        anchors.fill: parent
        opacity: card.bgReady ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs); easing.type: Easing.OutCubic }
        }

        MultiEffect {
            id: bgEffect
            anchors.fill: parent
            source: bgImage
            autoPaddingEnabled: false
            blurEnabled: true
            blur: 1.0
            blurMax: card.bgBlurMax
            brightness: card.bgBrightness
            saturation: card.bgSaturation
            visible: false
        }

        Rectangle {
            id: bgMask
            anchors.fill: parent
            radius: card.radius
            visible: false
        }

        OpacityMask {
            anchors.fill: parent
            source: bgEffect
            maskSource: bgMask
        }

        Rectangle {
            anchors.fill: parent
            radius: card.radius
            color: Colors.bg
            opacity: card.scrimOpacity
        }
    }

    Item {
        id: content
        anchors.fill: parent
        anchors.margins: card.pad

        // ---- The CD ----
        Item {
            id: cd

            readonly property real size: card.mode === "row" ? Math.min(content.height, content.width * 0.5)
                : card.mode === "stack" ? Math.min(content.width, content.height - card.textH - card.playSize - card.gap * 2)
                : Math.min(content.width, content.height)

            width: Math.max(0, size)
            height: width
            x: card.mode === "row" ? 0 : (content.width - width) / 2
            y: card.mode === "stack" ? 0 : (content.height - height) / 2

            Item {
                id: disc
                anchors.fill: parent

                Image {
                    id: discArt
                    anchors.fill: parent
                    source: AudioService.artUrl
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: Math.max(1, Math.round(cd.width * 2))
                    sourceSize.height: Math.max(1, Math.round(cd.height * 2))
                    asynchronous: true
                    visible: false
                }

                Rectangle {
                    id: discMask
                    anchors.fill: parent
                    radius: width / 2
                    visible: false
                }

                OpacityMask {
                    anchors.fill: parent
                    source: discArt
                    maskSource: discMask
                    visible: card.hasArt
                }

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Colors.elevatedBg
                    visible: !card.hasArt

                    Text {
                        anchors.centerIn: parent
                        text: "music_note"
                        font.family: Fonts.icon
                        font.pixelSize: Dimens.fontSizeXxxl
                        font.variableAxes: Fonts.iconAxes
                        color: Colors.fgMuted
                    }
                }

                // Disc grooves
                Repeater {
                    model: 3

                    delegate: Rectangle {
                        required property int index
                        anchors.centerIn: parent
                        width: parent.width * (0.9 - index * 0.14)
                        height: width
                        radius: width / 2
                        color: "transparent"
                        border.width: 1
                        border.color: Colors.bg
                        opacity: 0.25
                    }
                }

                // Outer rim
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.width: 2
                    border.color: Colors.border
                }

                // Centre hole
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 0.22
                    height: width
                    radius: width / 2
                    color: Colors.bg
                    border.width: 1
                    border.color: Colors.border

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.4
                        height: width
                        radius: width / 2
                        color: Colors.subBgMica
                    }
                }
            }

            // Spins while playing and keeps its angle when paused. One turn takes the Media page's "Rotation time".
            FrameAnimation {
                running: ShellState.dashboardCdSpin && AudioService.isPlaying && !ShellState.motionReduced && card.visible
                onTriggered: disc.rotation = (disc.rotation + 360 * frameTime / Math.max(1, ShellState.dashboardCdSpinSeconds)) % 360
            }

            MouseArea {
                anchors.fill: parent
                enabled: card.mode === "mini"
                cursorShape: Qt.PointingHandCursor
                onClicked: AudioService.togglePlayPause()
            }
        }

        // ---- Title + artist ----
        Column {
            id: textCol
            visible: card.mode !== "mini"
            spacing: 2
            x: card.mode === "row" ? cd.width + card.gap : 0
            width: card.mode === "row" ? content.width - cd.width - card.gap : content.width
            y: card.mode === "row"
                ? (content.height - (textCol.height + (controls.visible ? card.gap + controls.height : 0))) / 2
                : cd.height + card.gap

            Text {
                width: textCol.width
                text: AudioService.trackTitle !== "" ? AudioService.trackTitle : "Nothing playing"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeMd
                font.bold: true
                color: Colors.fg
                elide: Text.ElideRight
                horizontalAlignment: card.mode === "stack" ? Text.AlignHCenter : Text.AlignLeft
            }

            Text {
                width: textCol.width
                visible: ShellState.dashboardMediaShowArtist && text !== ""
                text: AudioService.trackArtist
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeSm
                color: card.bgReady ? Colors.fg : Colors.fgMuted
                opacity: card.bgReady ? 0.8 : 1.0
                elide: Text.ElideRight
                horizontalAlignment: card.mode === "stack" ? Text.AlignHCenter : Text.AlignLeft
            }
        }

        // ---- Transport buttons ----
        Row {
            id: controls
            visible: card.mode !== "mini" && ShellState.dashboardMediaShowControls
            spacing: card.gap
            x: card.mode === "stack" ? (content.width - width) / 2 : textCol.x
            y: textCol.y + textCol.height + card.gap

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "skip_previous"
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeXl
                font.variableAxes: Fonts.iconAxes
                color: prevMouse.containsMouse ? Colors.accent : Colors.fg

                MouseArea {
                    id: prevMouse
                    anchors.fill: parent
                    anchors.margins: -card.gap / 2
                    hoverEnabled: true
                    onClicked: AudioService.previousTrack()
                }
            }

            Rectangle {
                width: card.playSize
                height: card.playSize
                anchors.verticalCenter: parent.verticalCenter
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
                    onClicked: AudioService.togglePlayPause()
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "skip_next"
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeXl
                font.variableAxes: Fonts.iconAxes
                color: nextMouse.containsMouse ? Colors.accent : Colors.fg

                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    anchors.margins: -card.gap / 2
                    hoverEnabled: true
                    onClicked: AudioService.nextTrack()
                }
            }
        }
    }
}