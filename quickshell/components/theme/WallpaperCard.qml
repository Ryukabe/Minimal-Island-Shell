// components/theme/WallpaperCard.qml
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../services"
import "../../styles"

Item {
    id: card
    required property string wallpaperPath
    required property string wallpaperName
    property bool isApplied: false
    property bool isSelected: false
    property bool isHovered: false
    signal clicked()

    readonly property bool isRaised: isSelected || isHovered

    // Visual amplitude — how far each state pushes, not how fast.
    readonly property real liftY: isSelected ? -6 : (isHovered ? -4 : 0)
    readonly property real boxScale: isSelected ? 1.035 : (isHovered ? 1.02 : 1.0)

    implicitWidth: 145
    implicitHeight: 125
    property real radius: Dimens.radiusSmall

    z: card.isRaised ? 3 : 1

    // ---- hover-tier lift/scale: light, low-bounce ----
    SpringAnimation {
        id: hoverLiftSpring
        spring: Motion.hoverSpring
        damping: Motion.hoverDamping
        mass: Motion.hoverMass
        epsilon: Motion.epsilon
    }
    NumberAnimation {
        id: hoverLiftEase
        duration: ShellState.motionDuration(Motion.hoverMs)
        easing.type: Easing.OutCubic
    }
    SpringAnimation {
        id: hoverScaleSpring
        spring: Motion.hoverSpring
        damping: Motion.hoverDamping
        mass: Motion.hoverMass
        epsilon: Motion.epsilon
    }
    NumberAnimation {
        id: hoverScaleEase
        duration: ShellState.motionDuration(Motion.hoverMs)
        easing.type: Easing.OutCubic
    }

    // ---- select-tier lift/scale: heavier, more travel/bounce ----
    SpringAnimation {
        id: selectLiftSpring
        spring: Motion.selectSpring
        damping: Motion.selectDamping
        mass: Motion.selectMass
        epsilon: Motion.epsilon
    }
    NumberAnimation {
        id: selectLiftEase
        duration: ShellState.motionDuration(Motion.selectMs)
        easing.type: Easing.OutCubic
    }
    SpringAnimation {
        id: selectScaleSpring
        spring: Motion.selectSpring
        damping: Motion.selectDamping
        mass: Motion.selectMass
        epsilon: Motion.epsilon
    }
    NumberAnimation {
        id: selectScaleEase
        duration: ShellState.motionDuration(Motion.selectMs)
        easing.type: Easing.OutCubic
    }

    transform: Translate {
        y: card.liftY
        Behavior on y {
            animation: {
                var tier = card.isSelected ? (ShellState.motionSpringEnabled && !ShellState.motionReduced ? selectLiftSpring : selectLiftEase)
                                            : (ShellState.motionSpringEnabled && !ShellState.motionReduced ? hoverLiftSpring : hoverLiftEase)
                return tier
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        // Image Preview Container
        Rectangle {
            id: previewBox
            Layout.fillWidth: true
            Layout.preferredHeight: 90
            radius: card.radius
            color: Colors.subBgMica
            border.width: card.isApplied ? 2 : (card.isSelected ? 1.5 : 0)
            border.color: card.isApplied ? (Colors.accent) : Qt.rgba(1, 1, 1, 0.4)

            scale: card.boxScale
            Behavior on scale {
                animation: {
                    var tier = card.isSelected ? (ShellState.motionSpringEnabled && !ShellState.motionReduced ? selectScaleSpring : selectScaleEase)
                                                : (ShellState.motionSpringEnabled && !ShellState.motionReduced ? hoverScaleSpring : hoverScaleEase)
                    return tier
                }
            }

            // Wallpaper Image
            Image {
                id: wallpaperImage
                anchors.fill: parent
                source: "file://" + card.wallpaperPath
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize.width: 290
                sourceSize.height: 180
                visible: false
            }

            Rectangle {
                id: maskRect
                anchors.fill: parent
                radius: card.radius
                visible: false
            }

            OpacityMask {
                anchors.fill: wallpaperImage
                source: wallpaperImage
                maskSource: maskRect
            }

            // Active Applied Indicator Badge
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 6
                width: 20
                height: 20
                radius: 10
                color: Colors.accent
                visible: card.isApplied

                Text {
                    anchors.centerIn: parent
                    text: "check"
                    font.family: Fonts.icon
                    font.pixelSize: 13
                    font.variableAxes: Fonts.iconAxes
                    color: "#FFFFFF"
                }
            }
        }

        // Clean Label Below Image
        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: card.wallpaperName.replace(/\.[^/.]+$/, "") // Strip extension
            color: card.isRaised ? Colors.fg : Colors.fgMuted
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeSm - 1
            font.bold: card.isRaised
            elide: Text.ElideRight
            maximumLineCount: 1

            Behavior on color {
                ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: card.isHovered = true
        onExited: card.isHovered = false
        onClicked: card.clicked()
    }
}