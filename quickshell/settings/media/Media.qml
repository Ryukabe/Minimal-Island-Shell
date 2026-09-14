// settings/media/Media.qml
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../common"

Item {
    id: root
    property bool showVisualizer: true

    SettingsScrollView {
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