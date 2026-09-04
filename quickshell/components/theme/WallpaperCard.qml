// components/theme/WallpaperCard.qml
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
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

    implicitWidth: 145
    implicitHeight: 125
    property real radius: Dimens.radiusSmall

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

        // Image Preview Container
        Rectangle {
            id: previewBox
            Layout.fillWidth: true
            Layout.preferredHeight: 90
            radius: card.radius
            color: Colors.subBg
            border.width: card.isApplied ? 2 : (card.isSelected ? 1.5 : 0)
            border.color: card.isApplied ? (Colors.accent) : Qt.rgba(1, 1, 1, 0.4)

            scale: card.isHovered ? 1.02 : 1.0
            Behavior on scale {
                NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
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