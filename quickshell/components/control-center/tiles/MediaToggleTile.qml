// components/control-center/tiles/MediaToggleTile.qml
import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import "../../../styles"
import "../../../services"

Rectangle {
    id: tile

    radius: ShellState.islandCornerRadius
    color: Colors.subBgMica
    border.width: 0          // border is drawn by the overlay at the bottom so the blur can't cover it
    clip: true

    readonly property bool hasArt: AudioService.artUrl !== ""

    // ---- Background art tuning ----
    readonly property int bgDecodeSize: 128     // decode small: it gets blurred anyway
    readonly property real bgBlurMax: 48
    readonly property real bgBrightness: -0.2   // darkens the art itself (-1..1)
    readonly property real bgSaturation: 0.3    // pushes the art's color up so the tint reads as color, not gray
    readonly property real scrimOpacity: 0.35   // theme-colored overlay; higher = darker/more readable
    readonly property bool bgReady: hasArt && bgImage.status === Image.Ready

    Behavior on color { ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) } }

    // ---- Sizing inputs: everything else derives from these + the tile's real size ----
    readonly property real pad: Dimens.paddingMd
    readonly property real gap: Dimens.spacingMd
    readonly property real innerW: Math.max(0, width - pad * 2)
    readonly property real innerH: Math.max(0, height - pad * 2)
    readonly property real playSize: Dimens.fontSizeXl * 1.6
    readonly property real maxArt: 64
    readonly property real minTextW: Dimens.fontSizeSm * 8
    readonly property real transportFullW: Dimens.fontSizeXl * 2 + playSize + gap * 2
    readonly property real textH: titleText.implicitHeight + artistText.implicitHeight + textCol.spacing

    readonly property real rowArt: Math.min(innerH, maxArt)
    readonly property bool fitsRow: innerW >= rowArt + gap + minTextW + gap + transportFullW
    readonly property bool fitsStack: innerH >= textH + gap + playSize
    readonly property string mode: fitsRow ? "row" : (fitsStack ? "stack" : "mini")

    readonly property real artSize: Math.max(0,
        mode === "stack" ? Math.min(innerH - playSize - gap, innerW * 0.35)
        : mode === "row" ? rowArt
        : innerH)

    // ---- Blurred, tinted album-art background ----
    // Source image: hidden, only feeds the blur effect below.
    Image {
        id: bgImage
        anchors.fill: parent
        source: AudioService.artUrl
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: tile.bgDecodeSize
        sourceSize.height: tile.bgDecodeSize
        asynchronous: true
        visible: false
    }

    Item {
        id: bgLayer
        anchors.fill: parent
        opacity: tile.bgReady ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: ShellState.motionDuration(Motion.fadeMs)
                easing.type: Easing.OutCubic
            }
        }

        // Blur + color grade. Hidden: it only feeds the rounded mask below.
        MultiEffect {
            id: bgEffect
            anchors.fill: parent
            source: bgImage
            autoPaddingEnabled: false
            blurEnabled: true
            blur: 1.0
            blurMax: tile.bgBlurMax
            brightness: tile.bgBrightness
            saturation: tile.bgSaturation
            visible: false
        }

        // Rounded-corner mask shape (same radius as the tile and the border overlay)
        Rectangle {
            id: bgMask
            anchors.fill: parent
            radius: tile.radius
            visible: false
        }

        OpacityMask {
            anchors.fill: parent
            source: bgEffect
            maskSource: bgMask
        }

        // Light tint in the theme color, so text stays readable in dark and light modes
        Rectangle {
            anchors.fill: parent
            radius: tile.radius
            color: Colors.bg
            opacity: tile.scrimOpacity
        }
    }

    Item {
        id: content
        anchors.fill: parent
        anchors.margins: tile.pad

        // ---- Album art ----
        Rectangle {
            id: art
            width: tile.artSize
            height: tile.artSize
            x: 0
            y: tile.mode === "stack" ? 0 : (content.height - height) / 2
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

        // ---- Title + artist ----
        Column {
            id: textCol
            spacing: 2
            x: tile.artSize + tile.gap
            y: tile.mode === "stack" ? (tile.artSize - height) / 2 : (content.height - height) / 2
            width: Math.max(0, tile.mode === "stack"
                ? tile.innerW - tile.artSize - tile.gap
                : tile.innerW - tile.artSize - tile.gap * 2 - transport.width)

            Text {
                id: titleText
                width: textCol.width
                text: AudioService.trackTitle
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeSm
                font.bold: true
                color: Colors.fg
                elide: Text.ElideRight
            }

            Text {
                id: artistText
                width: textCol.width
                text: AudioService.trackArtist
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXSm
                // Muted text is too faint on top of the art, so use the main text color, slightly dimmed.
                color: tile.bgReady ? Colors.fg : Colors.fgMuted
                opacity: tile.bgReady ? 0.8 : 1.0
                elide: Text.ElideRight
            }
        }

        // ---- Transport controls ----
        Row {
            id: transport
            spacing: tile.gap
            x: tile.mode === "stack" ? (content.width - width) / 2 : content.width - width
            y: tile.mode === "stack" ? content.height - height : (content.height - height) / 2

            Text {
                visible: tile.mode !== "mini"
                anchors.verticalCenter: parent.verticalCenter
                text: "skip_previous"
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeXl
                font.variableAxes: Fonts.iconAxes
                color: prevMouse.containsMouse ? Colors.accent : Colors.fg

                MouseArea {
                    id: prevMouse
                    anchors.fill: parent
                    anchors.margins: -tile.gap / 2
                    hoverEnabled: true
                    onClicked: AudioService.previousTrack()
                }
            }

            Rectangle {
                width: tile.playSize
                height: tile.playSize
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
                    hoverEnabled: true
                    onClicked: AudioService.togglePlayPause()
                }
            }

            Text {
                visible: tile.mode !== "mini"
                anchors.verticalCenter: parent.verticalCenter
                text: "skip_next"
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeXl
                font.variableAxes: Fonts.iconAxes
                color: nextMouse.containsMouse ? Colors.accent : Colors.fg

                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    anchors.margins: -tile.gap / 2
                    hoverEnabled: true
                    onClicked: AudioService.nextTrack()
                }
            }
        }
    }

    // ---- Border overlay (always above the blur) ----
    Rectangle {
        anchors.fill: parent
        radius: tile.radius
        color: "transparent"
        border.width: 1
        border.color: Colors.border
        z: 10
    }
}