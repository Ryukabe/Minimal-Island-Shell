// components/theme/AnimationCard.qml — carousel card for a Hyprland animation
// preset. No image preview (animations aren't a static visual), so this
// leans on elevatedBg for guaranteed contrast against the page (subBgMica
// was too close to the page's own background on some themes), plus a
// hover-lighten state and an isApplied checkmark, same pattern as
// Theme/Wallpaper cards.
import QtQuick
import "../../styles"

Rectangle {
    id: root

    property string presetName: ""
    property bool isApplied: false
    property bool isSelected: false

    signal clicked()

    implicitWidth: 130
    implicitHeight: 90
    radius: Dimens.radiusMedium

    color: root.isSelected
        ? Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.16)
        : (mouseArea.containsMouse ? Qt.lighter(Colors.elevatedBg, 1.15) : Colors.elevatedBg)

    border.width: root.isSelected ? 2 : 1
    border.color: root.isSelected ? Colors.accent : Qt.rgba(1, 1, 1, 0.14)

    Behavior on color { ColorAnimation { duration: 120 } }

    transform: Translate { y: mouseArea.containsMouse ? -3 : 0 }
    Behavior on transform { }

    Text {
        anchors.centerIn: parent
        text: root.presetName.length > 0
            ? root.presetName.charAt(0).toUpperCase() + root.presetName.slice(1)
            : ""
        color: Colors.fg
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeBase
        font.weight: Font.Medium
    }

    Text {
        visible: root.isApplied
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 6
        text: "check_circle"
        color: Colors.accent
        font.family: Fonts.icon
        font.variableAxes: Fonts.iconAxes
        font.pixelSize: Dimens.fontSizeMd
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}