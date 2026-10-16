// pages/dashboard/DashboardSettings.qml — Dashboard (the status panel).
// Every control reads from and writes to ShellState (persisted by SettingsStore).
import QtQuick
import QtQuick.Layouts
import "components"
import "../../core/shell"
import "../../core/styles"

PageScroll {
    id: root

    // At least one tab must stay on, or the dashboard would be empty.
    readonly property int tabCount:
        (ShellState.dashboardTabOverview ? 1 : 0) +
        (ShellState.dashboardTabMedia ? 1 : 0) +
        (ShellState.dashboardTabPerformance ? 1 : 0) +
        (ShellState.dashboardTabWeather ? 1 : 0)

    SectionLabel { text: "Size" }

    GroupCard {
        SliderRow {
            label: "Width"
            from: 400; to: 800; stepSize: 10
            value: ShellState.statusPanelWidth
            unit: " px"
            onMoved: (val) => ShellState.statusPanelWidth = val
        }

        SliderRow {
            label: "Height"
            from: 140; to: 300; stepSize: 5
            value: ShellState.statusPanelHeight
            unit: " px"
            onMoved: (val) => ShellState.statusPanelHeight = val
            showDivider: false
        }
    }

    SectionLabel { text: "Tabs" }

    GroupCard {
        ToggleRow {
            label: "Overview"
            checked: ShellState.dashboardTabOverview
            enabled: !checked || root.tabCount > 1
            onToggled: (val) => ShellState.dashboardTabOverview = val
        }

        ToggleRow {
            label: "Media"
            checked: ShellState.dashboardTabMedia
            enabled: !checked || root.tabCount > 1
            onToggled: (val) => ShellState.dashboardTabMedia = val
        }

        ToggleRow {
            label: "Performance"
            checked: ShellState.dashboardTabPerformance
            enabled: !checked || root.tabCount > 1
            onToggled: (val) => ShellState.dashboardTabPerformance = val
        }

        ToggleRow {
            label: "Weather"
            checked: ShellState.dashboardTabWeather
            enabled: !checked || root.tabCount > 1
            onToggled: (val) => ShellState.dashboardTabWeather = val
            showDivider: false
        }
    }

    SectionLabel { text: "Performance widgets" }

    GroupCard {
        ToggleRow {
            label: "Battery"
            checked: ShellState.dashboardWidgetBattery
            enabled: ShellState.dashboardTabPerformance
            onToggled: (val) => ShellState.dashboardWidgetBattery = val
        }

        ToggleRow {
            label: "GPU"
            checked: ShellState.dashboardWidgetGpu
            enabled: ShellState.dashboardTabPerformance
            onToggled: (val) => ShellState.dashboardWidgetGpu = val
        }

        ToggleRow {
            label: "CPU"
            checked: ShellState.dashboardWidgetCpu
            enabled: ShellState.dashboardTabPerformance
            onToggled: (val) => ShellState.dashboardWidgetCpu = val
        }

        ToggleRow {
            label: "Memory"
            checked: ShellState.dashboardWidgetMemory
            enabled: ShellState.dashboardTabPerformance
            onToggled: (val) => ShellState.dashboardWidgetMemory = val
        }

        ToggleRow {
            label: "Storage"
            checked: ShellState.dashboardWidgetStorage
            enabled: ShellState.dashboardTabPerformance
            onToggled: (val) => ShellState.dashboardWidgetStorage = val
        }

        ToggleRow {
            label: "Network"
            checked: ShellState.dashboardWidgetNetwork
            enabled: ShellState.dashboardTabPerformance
            onToggled: (val) => ShellState.dashboardWidgetNetwork = val
            showDivider: false
        }
    }

    SectionLabel { text: "Opening" }

    GroupCard {
        ToggleRow {
            label: "Open on hover"
            description: "Reveal the dashboard when the pointer reaches the screen edge"
            checked: ShellState.dashboardShowOnHover
            onToggled: (val) => ShellState.dashboardShowOnHover = val
        }

        SliderRow {
            label: "Drag threshold"
            description: "Pixels dragged before the dashboard opens"
            from: 0; to: 150; stepSize: 5
            value: ShellState.dashboardDragThreshold
            unit: " px"
            onMoved: (val) => ShellState.dashboardDragThreshold = Math.round(val)
            showDivider: false
        }
    }

    SectionLabel { text: "Refresh" }

    GroupCard {
        SliderRow {
            label: "System stats"
            description: "CPU, memory and GPU readings"
            from: 1; to: 10; stepSize: 1
            value: ShellState.dashboardStatsIntervalSec
            unit: " s"
            onMoved: (val) => ShellState.dashboardStatsIntervalSec = val
            showDivider: false
        }
    }
}