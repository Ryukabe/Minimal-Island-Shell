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

    readonly property bool useSpring: ShellState.motionSpringEnabled && !ShellState.motionReduced

    property real liftYSpring: card.liftY
    property real liftYEase: card.liftY
    property real boxScaleSpring: card.boxScale
    property real boxScaleEase: card.boxScale

    implicitWidth: 145
    implicitHeight: 125
    property real radius: ShellState.islandCornerRadius

    z: card.isRaised ? 3 : 1

    // ---- lift (translate y): one fixed-type Behavior per motion mode ----
    Behavior on liftYSpring {
        enabled: card.useSpring
        SpringAnimation {
            spring: card.isSelected ? Motion.selectSpring : Motion.hoverSpring
            damping: card.isSelected ? Motion.selectDamping : Motion.hoverDamping
            mass: card.isSelected ? Motion.selectMass : Motion.hoverMass
            epsilon: Motion.epsilon
        }
    }
    Behavior on liftYEase {
        enabled: !card.useSpring
        NumberAnimation {
            duration: ShellState.motionDuration(card.isSelected ? Motion.selectMs : Motion.hoverMs)
            easing.type: Easing.OutCubic
        }
    }

    // ---- scale: one fixed-type Behavior per motion mode ----
    Behavior on boxScaleSpring {
        enabled: card.useSpring
        SpringAnimation {
            spring: card.isSelected ? Motion.selectSpring : Motion.hoverSpring
            damping: card.isSelected ? Motion.selectDamping : Motion.hoverDamping
            mass: card.isSelected ? Motion.selectMass : Motion.hoverMass
            epsilon: Motion.epsilon
        }
    }
    Behavior on boxScaleEase {
        enabled: !card.useSpring
        NumberAnimation {
            duration: ShellState.motionDuration(card.isSelected ? Motion.selectMs : Motion.hoverMs)
            easing.type: Easing.OutCubic
        }
    }

    transform: Translate {
        y: card.useSpring ? card.liftYSpring : card.liftYEase
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

            scale: card.useSpring ? card.boxScaleSpring : card.boxScaleEase

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
                radius: ShellState.islandCornerRadius
                color: Colors.accent
                visible: card.isApplied

                Text {
                    anchors.centerIn: parent
                    text: "check"
                    font.family: Fonts.icon
                    font.pixelSize: Dimens.fontSizeBase
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