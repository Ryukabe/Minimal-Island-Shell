// features/bar/VisualizerSettings.qml — Bar & Island > Music visualizer. Looks only.
// Whether it sits in the clock is set on the Bar & Island page (Layout).
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "../../core/shell"
import "../../core/styles"
import "components" as Bar

PageScroll {
    id: root

    readonly property var colorLabels: ["Accent", "Text", "Muted"]

    SectionLabel { text: "Look" }

    GroupCard {
        // Always animating here. On the bar it only moves while audio is playing.
        Item {
            Layout.fillWidth: true
            implicitHeight: 64

            Bar.ClockVisualizer {
                anchors.centerIn: parent
                running: root.visible
            }
        }

        SliderRow {
            label: "Bars"
            from: 2; to: 8; stepSize: 1
            value: ShellState.clockVisualizerBars
            onMoved: (val) => ShellState.clockVisualizerBars = val
        }

        SliderRow {
            label: "Bar width"
            from: 2; to: 6; stepSize: 1
            value: ShellState.clockVisualizerBarWidth
            unit: " px"
            onMoved: (val) => ShellState.clockVisualizerBarWidth = val
        }

        SliderRow {
            label: "Gap"
            description: "Space between the bars"
            from: 1; to: 8; stepSize: 1
            value: ShellState.clockVisualizerGap
            unit: " px"
            onMoved: (val) => ShellState.clockVisualizerGap = val
        }

        SliderRow {
            label: "Height"
            description: "How tall the bars reach"
            from: 6; to: 20; stepSize: 1
            value: ShellState.clockVisualizerMaxHeight
            unit: " px"
            onMoved: (val) => ShellState.clockVisualizerMaxHeight = val
        }

        SliderRow {
            label: "Speed"
            description: "Looping animation only. It does not follow the music"
            from: 50; to: 200; stepSize: 10
            value: ShellState.clockVisualizerSpeedPercent
            unit: " %"
            onMoved: (val) => ShellState.clockVisualizerSpeedPercent = val
        }

        SegmentRow {
            label: "Color"
            options: root.colorLabels
            selectedValue: ShellState.clockVisualizerColor
            onOptionSelected: (name) => ShellState.clockVisualizerColor = name
            showDivider: false
        }
    }

    Text {
        Layout.fillWidth: true
        leftPadding: Dimens.paddingSmall
        wrapMode: Text.WordWrap
        text: "To show or hide the visualizer on the island, add or remove it in the Layout section of Bar & Island."
        color: Colors.subtext
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeXs
    }
}
