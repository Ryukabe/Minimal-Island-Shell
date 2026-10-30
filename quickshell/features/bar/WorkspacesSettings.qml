// pages/bar/workspaces/WorkspacesSettings.qml — Bar > Workspaces.
// Every row here is live (ShellState.workspace*).
import QtQuick
import "../settings/components"
import "../../core/shell"

PageScroll {
    id: root

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
            description: "Tint empty-looking dots of workspaces that have windows (dots only; icon pills have no fill)"
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
            description: "Workspaces with windows show their app icons in a bordered pill instead of a dot"
            checked: ShellState.workspaceShowWindows
            onToggled: (val) => ShellState.workspaceShowWindows = val
        }

        ToggleRow {
            label: "Windows on special workspaces"
            description: "Add one extra pill for windows on special workspaces"
            checked: ShellState.workspaceWindowsOnSpecial
            enabled: ShellState.workspaceShowWindows
            onToggled: (val) => ShellState.workspaceWindowsOnSpecial = val
        }

        SliderRow {
            label: "Maximum window icons"
            description: "Per workspace, before the rest collapse into +N"
            from: 1; to: 10; stepSize: 1
            value: ShellState.workspaceMaxWindowIcons
            enabled: ShellState.workspaceShowWindows
            onMoved: (val) => ShellState.workspaceMaxWindowIcons = val
            showDivider: false
        }
    }

    SectionLabel { text: "Monitors" }

    GroupCard {
        ToggleRow {
            label: "Per-monitor workspaces"
            description: "Only show this monitor's workspaces and windows"
            checked: ShellState.workspacePerMonitor
            onToggled: (val) => ShellState.workspacePerMonitor = val
            showDivider: false
        }
    }
}