// features/hoverpanel/HoverPanelSettings.qml — Bar > Hover panel.
// When it opens, how long it stays, and which blocks it shows. Everything here is bound to ShellState.
import QtQuick
import "../settings/components"
import "../../core/shell"

PageScroll {
    id: root

    SectionLabel { text: "Opening" }

    GroupCard {
        ToggleRow {
            label: "Hover panel"
            description: "Rest the pointer on the island and a panel opens. Tapping the island still opens the Dashboard"
            checked: ShellState.hoverPanelEnabled
            onToggled: (val) => ShellState.hoverPanelEnabled = val
        }

        SliderRow {
            label: "Hover delay"
            description: "How long to rest the pointer before the panel opens"
            from: 500; to: 5000; stepSize: 100
            value: ShellState.hoverPanelDelayMs
            unit: " ms"
            enabled: ShellState.hoverPanelEnabled
            onMoved: (val) => ShellState.hoverPanelDelayMs = val
        }

        SliderRow {
            label: "Close delay"
            description: "How long after the pointer leaves before the panel closes"
            from: 100; to: 2000; stepSize: 50
            value: ShellState.hoverPanelCloseDelayMs
            unit: " ms"
            enabled: ShellState.hoverPanelEnabled
            onMoved: (val) => ShellState.hoverPanelCloseDelayMs = val
        }

        ToggleRow {
            label: "Show progress hint"
            description: "A thin line grows along the island while you wait for the panel"
            checked: ShellState.hoverPanelShowHint
            enabled: ShellState.hoverPanelEnabled
            onToggled: (val) => ShellState.hoverPanelShowHint = val
            showDivider: false
        }
    }

    SectionLabel { text: "Panel" }

    GroupCard {
        SliderRow {
            label: "Width"
            from: 320; to: 700; stepSize: 10
            value: ShellState.hoverPanelWidth
            unit: " px"
            enabled: ShellState.hoverPanelEnabled
            onMoved: (val) => ShellState.hoverPanelWidth = val
            showDivider: false
        }
    }

    SectionLabel { text: "Show" }

    GroupCard {
        ToggleRow {
            label: "Date and time"
            description: "The time and the full date"
            checked: ShellState.hoverPanelShowDate
            enabled: ShellState.hoverPanelEnabled
            onToggled: (val) => ShellState.hoverPanelShowDate = val
        }

        ToggleRow {
            label: "Volume and brightness"
            description: "Levels with minus and plus buttons. Scroll over a line to change it too"
            checked: ShellState.hoverPanelShowLevels
            enabled: ShellState.hoverPanelEnabled
            onToggled: (val) => ShellState.hoverPanelShowLevels = val
        }

        ToggleRow {
            label: "Notifications"
            description: "How many there are and the latest one. Tap to open the notification center"
            checked: ShellState.hoverPanelShowNotifications
            enabled: ShellState.hoverPanelEnabled
            onToggled: (val) => ShellState.hoverPanelShowNotifications = val
        }

        ToggleRow {
            label: "Timer"
            description: "The time left, only while a timer is running"
            checked: ShellState.hoverPanelShowTimer
            enabled: ShellState.hoverPanelEnabled
            onToggled: (val) => ShellState.hoverPanelShowTimer = val
        }

        ToggleRow {
            label: "Quick actions"
            description: "Buttons for the Control Center, notifications, Dashboard, Launcher, Settings and Power"
            checked: ShellState.hoverPanelShowActions
            enabled: ShellState.hoverPanelEnabled
            onToggled: (val) => ShellState.hoverPanelShowActions = val
            showDivider: false
        }
    }
}