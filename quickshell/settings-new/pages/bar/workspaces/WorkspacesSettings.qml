// pages/bar/workspaces/WorkspacesSettings.qml — Bar & Island > Workspaces.
// UI only for now. When wiring, add workspace* properties to ShellState and bind them here.
import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../../services"
import "../../../../styles"

PageScroll {
    id: root

    property int shownCount: 6
    property bool activeIndicator: true
    property bool activeTrail: false
    property bool occupiedBackground: false
    property bool showWindows: true
    property bool windowsOnSpecial: true
    property int maxWindowIcons: 5
    property bool perMonitor: true

    SectionLabel { text: "Indicators" }

    GroupCard {
        SliderRow {
            label: "Workspaces shown"
            description: "How many workspaces the indicator displays"
            from: 1; to: 10; stepSize: 1
            value: root.shownCount
            onMoved: (val) => root.shownCount = val
        }

        ToggleRow {
            label: "Active indicator"
            description: "Highlight the workspace you are on"
            checked: root.activeIndicator
            onToggled: (val) => root.activeIndicator = val
        }

        ToggleRow {
            label: "Active trail"
            description: "Leave a short trail when moving between workspaces"
            checked: root.activeTrail
            enabled: root.activeIndicator
            onToggled: (val) => root.activeTrail = val
        }

        ToggleRow {
            label: "Occupied background"
            description: "Tint workspaces that have windows open"
            checked: root.occupiedBackground
            onToggled: (val) => root.occupiedBackground = val
            showDivider: false
        }
    }

    SectionLabel { text: "Windows" }

    GroupCard {
        ToggleRow {
            label: "Show windows"
            description: "Show icons of open windows on each workspace"
            checked: root.showWindows
            onToggled: (val) => root.showWindows = val
        }

        ToggleRow {
            label: "Windows on special workspaces"
            checked: root.windowsOnSpecial
            enabled: root.showWindows
            onToggled: (val) => root.windowsOnSpecial = val
        }

        SliderRow {
            label: "Maximum window icons"
            description: "Per workspace, before the rest are collapsed"
            from: 1; to: 10; stepSize: 1
            value: root.maxWindowIcons
            enabled: root.showWindows
            onMoved: (val) => root.maxWindowIcons = val
            showDivider: false
        }
    }

    SectionLabel { text: "Monitors" }

    GroupCard {
        ToggleRow {
            label: "Per-monitor workspaces"
            description: "Show each monitor's workspaces independently"
            checked: root.perMonitor
            onToggled: (val) => root.perMonitor = val
            showDivider: false
        }
    }
}