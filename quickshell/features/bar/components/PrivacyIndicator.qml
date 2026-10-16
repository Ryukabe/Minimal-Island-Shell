// features/bar/components/PrivacyIndicator.qml — steady colored dot (mic / camera). Fades in and out.
import QtQuick
import "../../../core/shell"
import "../../../core/styles"

Item {
    id: root

    property bool active: false
    property int dotSize: 6
    property color dotColor: "transparent"

    implicitWidth: dotSize
    implicitHeight: dotSize
    width: dotSize
    height: dotSize
    opacity: active ? 1.0 : 0.0
    visible: active || opacity > 0.01

    Behavior on opacity {
        NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.dotColor

        Behavior on color {
            ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
        }
    }
}