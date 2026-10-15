// components/bar/ClockVisualizer.qml — the bar's music bars. Looks come from
// ShellState.clockVisualizer*. The motion is a looping animation, not real audio data.
import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../core/styles"
import "../../core/state"

RowLayout {
    id: root

    // The bar passes "audio is playing"; the settings preview keeps it true.
    property bool running: true

    // The original bars were designed at a max height of 10; everything scales from that.
    readonly property real heightScale: ShellState.clockVisualizerMaxHeight / 10
    readonly property real speedFactor: 100 / Math.max(1, ShellState.clockVisualizerSpeedPercent)

    readonly property color barColor: ShellState.clockVisualizerColor === "Text" ? Colors.fg
        : ShellState.clockVisualizerColor === "Muted" ? Colors.fgMuted
        : Colors.accent

    function lowHeight(i) {
        return Math.max(2, Math.round((3 + ((i % 3) * 2)) * root.heightScale))
    }

    function highHeight(i) {
        return Math.max(3, Math.round((10 - ((i % 2) * 3)) * root.heightScale))
    }

    spacing: ShellState.clockVisualizerGap

    Repeater {
        model: ShellState.clockVisualizerBars

        Item {
            id: bar
            required property int index

            implicitWidth: ShellState.clockVisualizerBarWidth
            implicitHeight: ShellState.clockVisualizerMaxHeight

            Rectangle {
                width: bar.implicitWidth
                height: root.highHeight(bar.index)
                color: root.barColor
                radius: ShellState.islandCornerRadius
                anchors.bottom: parent.bottom

                SequentialAnimation on height {
                    running: root.running
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: root.lowHeight(bar.index)
                        duration: Math.round((420 + (bar.index * 110)) * root.speedFactor)
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        to: root.highHeight(bar.index)
                        duration: Math.round((480 + (bar.index * 90)) * root.speedFactor)
                        easing.type: Easing.InOutSine
                    }
                }
            }
        }
    }
}