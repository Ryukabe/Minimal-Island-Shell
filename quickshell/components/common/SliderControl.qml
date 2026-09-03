import QtQuick
import "../../styles"

Item {
    id: root
    property real from: 0
    property real to: 100
    property real value: 0
    property real stepSize: 1
    signal moved(real value)

    implicitWidth: 200
    implicitHeight: 20

    readonly property real ratio: root.to > root.from
        ? Math.max(0, Math.min(1, (root.value - root.from) / (root.to - root.from)))
        : 0

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: Dimens.radiusFull
        color: Colors.surface
        border.color: Colors.border
        border.width: 1

        Rectangle {
            height: parent.height
            radius: Dimens.radiusFull
            color: Colors.accent
            width: Math.max(height, track.width * root.ratio)
        }
    }

    Rectangle {
        id: handle
        width: 16
        height: 16
        radius: Dimens.radiusFull
        color: Colors.white
        border.color: Colors.accent
        border.width: 2
        anchors.verticalCenter: parent.verticalCenter
        x: track.width * root.ratio - width / 2

        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
        scale: dragArea.pressed ? 1.15 : 1.0
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        preventStealing: true
        onPressed: (mouse) => updateFromX(mouse.x)
        onPositionChanged: (mouse) => { if (pressed) updateFromX(mouse.x) }

        function updateFromX(mx) {
            let r = Math.max(0, Math.min(1, mx / root.width))
            let raw = root.from + r * (root.to - root.from)
            let stepped = Math.round(raw / root.stepSize) * root.stepSize
            stepped = Math.max(root.from, Math.min(root.to, stepped))
            if (stepped !== root.value) {
                root.value = stepped
                root.moved(stepped)
            }
        }
    }
}