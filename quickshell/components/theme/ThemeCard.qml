// components/theme/ThemeCard.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../services"
import "../../styles"

Item {
    id: card
    required property string themeName
    property bool isApplied: false
    property bool isSelected: false
    property bool isHovered: false
    signal clicked()

    readonly property bool isRaised: isSelected || isHovered

    // Visual amplitude — how far each state pushes, not how fast.
    // Selection reads as more pronounced than a passing hover.
    readonly property real liftY: isSelected ? -6 : (isHovered ? -4 : 0)
    readonly property real boxScale: isSelected ? 1.035 : (isHovered ? 1.02 : 1.0)

    property var palette: ({})
    property bool loaded: false

    FileView {
        id: cardThemeFile
        path: ThemeService.themeJsonPath(card.themeName)

        onLoaded: {
            try {
                // Call text() as a function to fetch the file contents string
                let rawContent = cardThemeFile.text();
                card.palette = JSON.parse(rawContent);
                card.loaded = true;
            } catch (e) {
                console.warn("ThemeCard: Failed to parse JSON for", card.themeName, e);
                card.palette = ({});
                card.loaded = false;
            }
        }
        onLoadFailed: error => {
            console.error("ThemeCard: Failed to load file for", card.themeName, error);
            card.palette = ({});
            card.loaded = false;
        }
    }

    function pick(key, fallback) {
        if (!card.loaded) return fallback;

        // Check inside the "dark" scheme object first to match your quickshell.json structure
        if (card.palette.dark && card.palette.dark[key] !== undefined) {
            return card.palette.dark[key];
        }
        // Fallback check for flat JSON structures
        if (card.palette[key] !== undefined) {
            return card.palette[key];
        }

        return fallback;
    }

readonly property color previewBg: pick("background", Colors.subBg || "#1e1e1e")
readonly property color previewAccent: pick("accent", Colors.accent || "#007acc")
readonly property color previewFg: pick("foreground", Colors.fg || "#ffffff")

    implicitWidth: 145
    implicitHeight: 125

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

        // Theme Palette Preview Box
        Rectangle {
            id: previewBox
            Layout.fillWidth: true
            Layout.preferredHeight: 90
            radius: Dimens.radiusSmall
            color: card.previewBg

            border.width: card.isApplied ? 2 : (card.isSelected ? 1.5 : 0)
            border.color: card.isApplied ? card.previewAccent : Qt.rgba(1, 1, 1, 0.4)

            scale: card.boxScale
            Behavior on scale {
                animation: {
                    var tier = card.isSelected ? (ShellState.motionSpringEnabled && !ShellState.motionReduced ? selectScaleSpring : selectScaleEase)
                                                : (ShellState.motionSpringEnabled && !ShellState.motionReduced ? hoverScaleSpring : hoverScaleEase)
                    return tier
                }
            }

            // Internal Accent Line / Mock Color Bars
            RowLayout {
                anchors.centerIn: parent
                spacing: 6

                Rectangle {
                    width: 14
                    height: 28
                    radius: 4
                    color: card.previewAccent
                }
                Rectangle {
                    width: 14
                    height: 28
                    radius: 4
                    color: card.previewFg
                }
                Rectangle {
                    width: 14
                    height: 28
                    radius: 4
                    color: Qt.rgba(card.previewFg.r, card.previewFg.g, card.previewFg.b, 0.3)
                }
            }

            // Active Checkmark Badge
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 6
                width: 20
                height: 20
                radius: 10
                color: card.previewAccent
                visible: card.isApplied

                Text {
                    anchors.centerIn: parent
                    text: "check"
                    font.family: Fonts.icon
                    font.pixelSize: 13
                    font.variableAxes: Fonts.iconAxes
                    font.features: { "liga": 1 }
                    color: card.previewBg
                }
            }
        }

        // Clean Label Below Preview
        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: card.themeName
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