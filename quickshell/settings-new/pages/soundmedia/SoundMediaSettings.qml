// pages/soundmedia/SoundMediaSettings.qml — Sound & Media.
// Output volume and the visualizer are real. Volume step and max volume are UI only for now:
// when wiring, add ShellState.volumeStep / volumeMax and make VolumeService respect them.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    property int volumeStep: 5
    property int maxVolume: 100

    SectionLabel { text: "Output" }

    GroupCard {
        SliderRow {
            label: "Output volume"
            from: 0; to: 100; stepSize: 1
            value: VolumeService.percent
            unit: " %"
            onMoved: (val) => VolumeService.setPercent(val)
            showDivider: false
        }
    }

    SectionLabel { text: "Volume keys and scrolling" }

    GroupCard {
        SliderRow {
            label: "Volume step"
            description: "How much volume changes per key press or scroll"
            from: 1; to: 20; stepSize: 1
            value: root.volumeStep
            unit: " %"
            onMoved: (val) => root.volumeStep = val
        }

        SliderRow {
            label: "Maximum volume"
            description: "Upper limit for output volume"
            from: 50; to: 150; stepSize: 5
            value: root.maxVolume
            unit: " %"
            onMoved: (val) => root.maxVolume = val
            showDivider: false
        }
    }

    SectionLabel { text: "Media" }

    GroupCard {
        ToggleRow {
            label: "Audio visualizer"
            description: "Show the music visualizer beside the clock in the island"
            checked: ShellState.clockShowVisualizer
            onToggled: (val) => ShellState.clockShowVisualizer = val
            showDivider: false
        }
    }
}