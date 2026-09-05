// settings/bar/Bar.qml
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"
import "../common"

Item {
    id: root

    SettingsScrollView {
        SettingsHeader {
            icon: "dock_to_bottom"
            title: "Bar & Island"
            subtitle: "Shape and size of the island, the notch, and the Game Mode bar."
        }

        SettingsSectionLabel { label: "Behavior" }

        SettingsSliderRow {
            label: "Top margin"
            from: 0; to: 40; stepSize: 1
            value: ShellState.islandTopMargin
            unit: " px"
            enabled: !ShellState.islandNotchMode
            opacity: ShellState.islandNotchMode ? 0.4 : 1.0
            onMoved: (val) => ShellState.islandTopMargin = val
        }

        SettingsSliderRow {
            label: "Corner radius"
            from: 0; to: 30; stepSize: 1
            value: ShellState.islandCornerRadius
            unit: " px"
            onMoved: (val) => ShellState.islandCornerRadius = val
        }

        SettingsSliderRow {
            label: "Border width"
            from: 0; to: 4; stepSize: 1
            value: ShellState.islandBorderWidth
            unit: " px"
            enabled: !ShellState.islandNotchMode
            opacity: ShellState.islandNotchMode ? 0.4 : 1.0
            onMoved: (val) => ShellState.islandBorderWidth = val
        }

        SettingsToggleRow {
            label: "Click outside to dismiss"
            checked: ShellState.islandClickOutsideDismiss
            onToggled: (val) => ShellState.islandClickOutsideDismiss = val
        }

        SettingsSectionLabel { label: "Notch" }

        SettingsToggleRow {
            label: "Notch mode"
            checked: ShellState.islandNotchMode
            onToggled: (val) => ShellState.islandNotchMode = val
        }

        SettingsSliderRow {
            label: "Notch flare"
            from: 0; to: 40; stepSize: 1
            value: ShellState.islandNotchFlare
            unit: " px"
            visible: ShellState.islandNotchMode
            onMoved: (val) => ShellState.islandNotchFlare = val
        }

        SettingsSectionLabel { label: "Sizing" }

        SettingsSliderRow {
            label: "Bar height"
            from: 24; to: 60; stepSize: 1
            value: ShellState.islandCompactHeight
            unit: " px"
            onMoved: (val) => ShellState.islandCompactHeight = val
        }

        SettingsSliderRow {
            label: "Collapsed width"
            from: 80; to: 300; stepSize: 1
            value: ShellState.islandCompactWidth
            unit: " px"
            onMoved: (val) => ShellState.islandCompactWidth = val
        }

        SettingsSliderRow {
            label: "Expanded height"
            from: 60; to: 400; stepSize: 1
            value: ShellState.islandExpandedHeight
            unit: " px"
            onMoved: (val) => ShellState.islandExpandedHeight = val
        }

        SettingsSliderRow {
            label: "Minimum expanded width"
            from: 300; to: 900; stepSize: 1
            value: ShellState.islandMinExpandedWidth
            unit: " px"
            onMoved: (val) => ShellState.islandMinExpandedWidth = val
        }
    }
}