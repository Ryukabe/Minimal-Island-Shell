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
            subtitle: "Shape, size, and individual module dimensions."
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

        SettingsSectionLabel { label: "Global Bar Sizing" }

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
            label: "Expanded height floor"
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

        // ================= MODULE SECTIONS =================

        SettingsSectionLabel { label: "App Launcher" }

        SettingsSliderRow {
            label: "Launcher width"
            from: 300; to: 800; stepSize: 10
            value: ShellState.launcherWidth || 420
            unit: " px"
            onMoved: (val) => ShellState.launcherWidth = val
        }

        SettingsSliderRow {
            label: "Max visible rows"
            from: 3; to: 12; stepSize: 1
            value: ShellState.launcherMaxRows || 7
            unit: " rows"
            onMoved: (val) => ShellState.launcherMaxRows = val
        }

        SettingsSectionLabel { label: "Clipboard" }

        SettingsSliderRow {
            label: "Clipboard width"
            from: 300; to: 800; stepSize: 10
            value: ShellState.clipboardWidth || 420
            unit: " px"
            onMoved: (val) => ShellState.clipboardWidth = val
        }

        SettingsSliderRow {
            label: "Max visible rows"
            from: 3; to: 12; stepSize: 1
            value: ShellState.clipboardMaxRows || 6
            unit: " rows"
            onMoved: (val) => ShellState.clipboardMaxRows = val
        }

        SettingsSectionLabel { label: "Control Center" }

        SettingsSliderRow {
            label: "Control center width"
            from: 400; to: 900; stepSize: 10
            value: ShellState.controlCenterWidth || 580
            unit: " px"
            onMoved: (val) => ShellState.controlCenterWidth = val
        }

        SettingsSliderRow {
            label: "Control center height"
            from: 300; to: 700; stepSize: 10
            value: ShellState.controlCenterHeight || 400
            unit: " px"
            onMoved: (val) => ShellState.controlCenterHeight = val
        }

        SettingsSectionLabel { label: "Notification Center" }

        SettingsSliderRow {
            label: "Notification center width"
            from: 280; to: 600; stepSize: 10
            value: ShellState.notificationCenterWidth || 360
            unit: " px"
            onMoved: (val) => ShellState.notificationCenterWidth = val
        }

        SettingsSliderRow {
            label: "Max height"
            from: 250; to: 800; stepSize: 10
            value: ShellState.notificationCenterMaxHeight || 480
            unit: " px"
            onMoved: (val) => ShellState.notificationCenterMaxHeight = val
        }

        SettingsSectionLabel { label: "Power Menu" }

        SettingsSliderRow {
            label: "Power menu width"
            from: 250; to: 600; stepSize: 10
            value: ShellState.powerMenuWidth || 320
            unit: " px"
            onMoved: (val) => ShellState.powerMenuWidth = val
        }

        SettingsSliderRow {
            label: "Power menu height"
            from: 60; to: 120; stepSize: 2
            value: ShellState.powerMenuHeight || 76
            unit: " px"
            onMoved: (val) => ShellState.powerMenuHeight = val
        }

        SettingsSectionLabel { label: "Status Panel" }

        SettingsSliderRow {
            label: "Status panel width"
            from: 400; to: 800; stepSize: 10
            value: ShellState.statusPanelWidth || 520
            unit: " px"
            onMoved: (val) => ShellState.statusPanelWidth = val
        }

        SettingsSliderRow {
            label: "Status panel height"
            from: 140; to: 300; stepSize: 5
            value: ShellState.statusPanelHeight || 172
            unit: " px"
            onMoved: (val) => ShellState.statusPanelHeight = val
        }

        SettingsSectionLabel { label: "Timer Module" }

        SettingsSliderRow {
            label: "Timer width"
            from: 240; to: 500; stepSize: 10
            value: ShellState.timerWidth || 320
            unit: " px"
            onMoved: (val) => ShellState.timerWidth = val
        }

        SettingsSliderRow {
            label: "Timer height"
            from: 140; to: 300; stepSize: 5
            value: ShellState.timerHeight || 180
            unit: " px"
            onMoved: (val) => ShellState.timerHeight = val
        }
    }
}