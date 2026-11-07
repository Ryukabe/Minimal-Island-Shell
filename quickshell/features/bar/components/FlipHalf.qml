// features/bar/components/FlipHalf.qml — the top or bottom half of one flip-clock character.
// The whole character is drawn at full height and only half of it shows, so two halves together make the digit.
import QtQuick

Item {
    id: root

    property string glyph: ""
    property bool lowerHalf: false
    property real cardWidth: 12
    property real cardHeight: 20
    property color textColor: "white"
    property string fontFamily: ""
    property real pixelSize: 15
    property int fontWeight: 700
    // 0..1: a dark veil that makes a half look like it is turning away from the light.
    property real shade: 0

    width: root.cardWidth
    height: root.cardHeight / 2
    y: root.lowerHalf ? root.cardHeight / 2 : 0
    clip: true

    Text {
        y: root.lowerHalf ? -root.cardHeight / 2 : 0
        width: root.cardWidth
        height: root.cardHeight
        text: root.glyph
        color: root.textColor
        font.family: root.fontFamily
        font.pixelSize: root.pixelSize
        font.weight: root.fontWeight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: root.shade * 0.45
        visible: root.shade > 0
    }
}