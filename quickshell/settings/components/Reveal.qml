// components/Reveal.qml — wraps rows that only show under a condition. Slides open and fades in when
// `shown` turns true, and slides shut when it turns false. Put any rows inside it:
//   Reveal { shown: ShellState.islandNotchMode; SliderRow { ... } }
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"

Item {
    id: root

    default property alias content: column.data
    property bool shown: true

    Layout.fillWidth: true
    Layout.preferredHeight: root.shown ? column.implicitHeight : 0
    clip: true
    opacity: root.shown ? 1 : 0
    enabled: root.shown
    visible: root.shown || root.height > 0.5

    Behavior on Layout.preferredHeight {
        NumberAnimation {
            duration: ShellState.motionDuration(Motion.fadeMs)
            easing.type: Easing.OutCubic
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
    }

    ColumnLayout {
        id: column
        width: parent.width
        spacing: 0
    }
}