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

    property var palette: ({})
    property bool loaded: false

    FileView {
        id: cardThemeFile
        path: ThemeService.themeJsonPath(card.themeName)

        onLoaded: {
            try {
                card.palette = JSON.parse(text());
                card.loaded = true;
            } catch (e) {
                card.palette = ({});
                card.loaded = false;
            }
        }
        onLoadFailed: error => {
            card.palette = ({});
            card.loaded = false;
        }
    }

    function pick(key, fallback) {
        return (card.loaded && card.palette[key] !== undefined) ? card.palette[key] : fallback;
    }

    readonly property color previewBg: pick("background", Colors.bgSurface)
    readonly property color previewAccent: pick("accent", Colors.accent)
    readonly property color previewFg: pick("foreground", Colors.fg)

    implicitWidth: 145
    implicitHeight: 125

    z: card.isRaised ? 3 : 1

    transform: Translate {
        y: card.isRaised ? -4 : 0
        Behavior on y {
            NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
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

            scale: card.isHovered ? 1.02 : 1.0
            Behavior on scale {
                NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
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
                ColorAnimation { duration: 140 }
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