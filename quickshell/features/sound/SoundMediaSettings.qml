// features/sound/SoundMediaSettings.qml — Sound & Media.
// Volume and its limits, the output device, the island visualizer, lyrics and the preferred player.
import QtQuick
import "../settings/components"
import "../settings/core"
import "../bar"
import "."
import "../../core/shell"

PageScroll {
    id: root

    // Every ShellState key in the Sound & Media menu (used by the Reset row at the bottom).
    readonly property var resetKeys: ["volumeStep", "volumeMax", "volumeShowPopup", "lyricsBackend", "defaultPlayer"]

    // The visualizer is on the island exactly when it is in the clock layout (Bar > Layout).
    readonly property bool visualizerOn: ClockLayoutService.indexForId("visualizer") >= 0

    function _openOutputPicker() {
        SettingsPicker.open({
            title: "Output device",
            searchHint: "Search devices...",
            items: VolumeService.outputSinks.map(n => ({ value: String(n.id), label: VolumeService.sinkLabel(n) })),
            selectedValue: VolumeService.sink ? String(VolumeService.sink.id) : "",
            initialQuery: "",
            onPick: function (id) {
                const node = VolumeService.outputSinks.find(n => String(n.id) === id)
                if (node) VolumeService.setDefaultSink(node)
            }
        })
    }

    SectionLabel { text: "Output" }

    GroupCard {
        SliderRow {
            label: "Output volume"
            from: 0; to: ShellState.volumeMax; stepSize: 1
            value: VolumeService.percent
            unit: " %"
            onMoved: (val) => VolumeService.setPercent(val)
        }

        ButtonRow {
            label: "Output device"
            description: VolumeService.sink ? VolumeService.sinkLabel(VolumeService.sink) : "No output found"
            buttonText: "Choose"
            enabled: VolumeService.outputSinks.length > 0
            showDivider: false
            onClicked: root._openOutputPicker()
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
            description: "Upper limit for output volume. Above 100 % can sound distorted"
            from: 50; to: 150; stepSize: 5
            value: ShellState.volumeMax
            unit: " %"
            onMoved: (val) => ShellState.volumeMax = val
        }

        ToggleRow {
            label: "Volume popup"
            description: "Show the level in the island when you change the volume with keys or scrolling"
            checked: ShellState.volumeShowPopup
            onToggled: (val) => ShellState.volumeShowPopup = val
            showDivider: false
        }
    }

    SectionLabel { text: "Media" }

    GroupCard {
        ToggleRow {
            label: "Audio visualizer"
            description: "Show the music visualizer beside the clock in the island. Bar > Layout shows the same switch"
            checked: root.visualizerOn
            onToggled: (val) => {
                if (val) ClockLayoutService.addItemAt("visualizer", ClockLayoutService.layoutModel.count)
                else ClockLayoutService.removeItem("visualizer")
            }
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

    SectionLabel { text: "Reset" }

    GroupCard {
        ResetRow {
            menuName: "Sound & Media"
            keys: root.resetKeys
        }
    }
}