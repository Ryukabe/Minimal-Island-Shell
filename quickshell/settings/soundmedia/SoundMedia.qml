// settings/soundmedia/SoundMedia.qml — replaces Media.qml; adds a real Volume group via VolumeService
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"
import "../common"

Item {
    id: root
    property bool showVisualizer: true   // carried over as-is — not wired to anything real, see note

    SettingsScrollView {
        SettingsGroup {
            title: "Volume"
            description: "System output volume"
            icon: "volume_up"
            expanded: true

            SettingsSliderRow {
                label: "Output Volume"
                from: 0; to: 100; stepSize: 1
                value: VolumeService.percent
                unit: "%"
                showDivider: false
                onMoved: (val) => VolumeService.setPercent(val)
            }
        }

        SettingsGroup {
            title: "Media Preferences"
            description: "Audio visualizer and player behavior in the island"
            icon: "graphic_eq"
            expanded: true

            SettingsToggleRow {
                label: "Show Audio Visualizer in Island"
                checked: root.showVisualizer
                showDivider: false
                onToggled: (val) => root.showVisualizer = val
            }
        }
    }
}