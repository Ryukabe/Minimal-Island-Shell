// pages/dashboard/DashboardSettings.qml — Dashboard.
// UI only for now: the dashboard module does not exist yet. When it does, add dashboard* properties
// to ShellState and bind them here.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    property bool tabOverview: true
    property bool tabMedia: true
    property bool tabPerformance: true
    property bool tabWeather: true

    property bool widgetBattery: false
    property bool widgetGpu: true
    property bool widgetCpu: true
    property bool widgetMemory: true
    property bool widgetStorage: true
    property bool widgetNetwork: false

    property bool showOnHover: true
    property int dragThreshold: 50

    SectionLabel { text: "Tabs" }

    GroupCard {
        ToggleRow {
            label: "Overview"
            checked: root.tabOverview
            onToggled: (val) => root.tabOverview = val
        }

        ToggleRow {
            label: "Media"
            checked: root.tabMedia
            onToggled: (val) => root.tabMedia = val
        }

        ToggleRow {
            label: "Performance"
            checked: root.tabPerformance
            onToggled: (val) => root.tabPerformance = val
        }

        ToggleRow {
            label: "Weather"
            checked: root.tabWeather
            onToggled: (val) => root.tabWeather = val
            showDivider: false
        }
    }

    SectionLabel { text: "Performance widgets" }

    GroupCard {
        ToggleRow {
            label: "Battery"
            checked: root.widgetBattery
            enabled: root.tabPerformance
            onToggled: (val) => root.widgetBattery = val
        }

        ToggleRow {
            label: "GPU"
            checked: root.widgetGpu
            enabled: root.tabPerformance
            onToggled: (val) => root.widgetGpu = val
        }

        ToggleRow {
            label: "CPU"
            checked: root.widgetCpu
            enabled: root.tabPerformance
            onToggled: (val) => root.widgetCpu = val
        }

        ToggleRow {
            label: "Memory"
            checked: root.widgetMemory
            enabled: root.tabPerformance
            onToggled: (val) => root.widgetMemory = val
        }

        ToggleRow {
            label: "Storage"
            checked: root.widgetStorage
            enabled: root.tabPerformance
            onToggled: (val) => root.widgetStorage = val
        }

        ToggleRow {
            label: "Network"
            checked: root.widgetNetwork
            enabled: root.tabPerformance
            onToggled: (val) => root.widgetNetwork = val
            showDivider: false
        }
    }

    SectionLabel { text: "Opening" }

    GroupCard {
        ToggleRow {
            label: "Open on hover"
            description: "Reveal the dashboard when the pointer reaches the screen edge"
            checked: root.showOnHover
            onToggled: (val) => root.showOnHover = val
        }

        SliderRow {
            label: "Drag threshold"
            description: "Pixels dragged before the dashboard opens"
            from: 0; to: 150; stepSize: 5
            value: root.dragThreshold
            unit: " px"
            onMoved: (val) => root.dragThreshold = val
            showDivider: false
        }
    }
}