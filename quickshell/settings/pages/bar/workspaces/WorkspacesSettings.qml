// pages/bar/workspaces/WorkspacesSettings.qml — Bar > Workspaces.
// Indicators and Look are live (ShellState.workspace*). The Windows and Monitors
// sections below are still UI-only: the bar does not read them yet.
import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../../services"
import "../../../../core/styles"
import "../../../../core/state"

PageScroll {
    id: root

    // UI-only for now (no backend in the bar yet)
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
            value: ShellState.workspaceShownCount
            onMoved: (val) => ShellState.workspaceShownCount = val
        }

        ToggleRow {
            label: "Active indicator"
            description: "Stretch the workspace you are on into a capsule"
            checked: ShellState.workspaceActiveIndicator
            onToggled: (val) => ShellState.workspaceActiveIndicator = val
        }

        ToggleRow {
            label: "Accent color"
            description: "Color the active capsule with the accent instead of plain text color"
            checked: ShellState.workspaceUseAccent
            enabled: ShellState.workspaceActiveIndicator
            onToggled: (val) => ShellState.workspaceUseAccent = val
        }

        ToggleRow {
            label: "Active trail"
            description: "The workspace you leave shrinks slowly, leaving a short trail"
            checked: ShellState.workspaceActiveTrail
            enabled: ShellState.workspaceActiveIndicator
            onToggled: (val) => ShellState.workspaceActiveTrail = val
        }

        ToggleRow {
            label: "Occupied background"
            description: "Tint workspaces that have windows open"
            checked: ShellState.workspaceOccupiedBackground
            onToggled: (val) => ShellState.workspaceOccupiedBackground = val
            showDivider: false
        }
    }

    SectionLabel { text: "Look" }

    GroupCard {
        SegmentRow {
            label: "Switch animation"
            options: ["Glide", "Bounce"]
            selectedValue: ShellState.workspaceBounce ? "Bounce" : "Glide"
            onOptionSelected: (name) => ShellState.workspaceBounce = (name === "Bounce")
        }

        SliderRow {
            label: "Dot size"
            from: 4; to: 10; stepSize: 1
            unit: "px"
            value: ShellState.workspaceDotSize
            onMoved: (val) => ShellState.workspaceDotSize = val
        }

        SliderRow {
            label: "Active width"
            description: "Length of the active capsule"
            from: 12; to: 40; stepSize: 2
            unit: "px"
            value: ShellState.workspaceActiveWidth
            onMoved: (val) => ShellState.workspaceActiveWidth = val
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