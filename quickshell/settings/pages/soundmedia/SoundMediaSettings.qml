// pages/soundmedia/SoundMediaSettings.qml — Sound & Media.
// Output volume and the visualizer toggle are live. Volume step, maximum volume, lyrics source and
// preferred player are saved on ShellState; VolumeService and the media module read them from there.
// Position update rate is a greyed placeholder until the media module reads it.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

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
            value: ShellState.volumeStep
            unit: " %"
            onMoved: (val) => ShellState.volumeStep = val
        }

        SliderRow {
            label: "Maximum volume"
            description: "Upper limit for output volume"
            from: 50; to: 150; stepSize: 5
            value: ShellState.volumeMax
            unit: " %"
            onMoved: (val) => ShellState.volumeMax = val
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
        }

        SliderRow {
            label: "Media position"
            description: "How often the progress bar moves"
            from: 100; to: 2000; stepSize: 100
            value: 500
            unit: " ms"
            placeholder: true
        }

        DropdownRow {
            label: "Lyrics source"
            options: ["Auto", "LRCLIB", "Local files"]
            selectedValue: ShellState.lyricsBackend
            onOptionSelected: (value) => ShellState.lyricsBackend = value
        }

        DropdownRow {
            label: "Preferred player"
            options: ["Spotify", "Firefox", "mpv", "Any"]
            selectedValue: ShellState.defaultPlayer
            onOptionSelected: (value) => ShellState.defaultPlayer = value
            showDivider: false
        }
    }
}