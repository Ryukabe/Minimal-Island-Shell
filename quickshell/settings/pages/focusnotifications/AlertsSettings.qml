// pages/focusnotifications/AlertsSettings.qml — Focus & Notifications > Alerts.
// Everything here is bound to ShellState and read by NotificationService / NotificationCenter.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    SectionLabel { text: "Lifetime" }

    GroupCard {
        ToggleRow {
            label: "Hide popups automatically"
            description: "Off: a popup stays on the island until you click it"
            checked: ShellState.notificationAutoHide
            onToggled: (val) => ShellState.notificationAutoHide = val
            showDivider: ShellState.notificationAutoHide
        }

        Reveal {
            shown: ShellState.notificationAutoHide

            SliderRow {
                label: "Timeout"
                description: "How long a popup stays before it hides"
                from: 1000; to: 15000; stepSize: 500
                value: ShellState.notificationTimeoutMs
                unit: " ms"
                onMoved: (val) => ShellState.notificationTimeoutMs = val
            }

            ToggleRow {
                label: "Respect the app's own timeout"
                description: "Use the time the app asks for. Apps that don't ask use the timeout above"
                checked: ShellState.notificationRespectAppTimeout
                onToggled: (val) => ShellState.notificationRespectAppTimeout = val
                showDivider: false
            }
        }
    }

    SectionLabel { text: "Critical notifications" }

    GroupCard {
        ToggleRow {
            label: "Break through Focus"
            description: "Show critical popups even while Focus is on"
            checked: ShellState.notificationCriticalBypassFocus
            onToggled: (val) => ShellState.notificationCriticalBypassFocus = val
        }

        ToggleRow {
            label: "Stay until dismissed"
            description: "Critical popups wait for a click instead of hiding"
            checked: ShellState.notificationCriticalSticky
            onToggled: (val) => ShellState.notificationCriticalSticky = val
            showDivider: false
        }
    }

    SectionLabel { text: "Layout" }

    GroupCard {
        ToggleRow {
            label: "Open expanded"
            description: "The notification center shows every notification of an app by default"
            checked: ShellState.notificationGroupExpanded
            onToggled: (val) => ShellState.notificationGroupExpanded = val
        }

        SliderRow {
            label: "Group preview count"
            description: ShellState.notificationGroupExpanded
                ? "Not used while Open expanded is on"
                : "Notifications shown per app before the group collapses"
            from: 1; to: 8; stepSize: 1
            value: ShellState.notificationGroupPreviewCount
            enabled: !ShellState.notificationGroupExpanded
            onMoved: (val) => ShellState.notificationGroupPreviewCount = val
            showDivider: false
        }
    }

    SectionLabel { text: "History" }

    GroupCard {
        SliderRow {
            label: "Keep at most"
            description: "The oldest notifications are removed from the center when a new one arrives"
            from: 10; to: 200; stepSize: 10
            value: ShellState.notificationHistoryLimit
            unit: " items"
            onMoved: (val) => ShellState.notificationHistoryLimit = val
            showDivider: false
        }
    }

    SectionLabel { text: "Muted apps" }

    GroupCard {
        InfoRow {
            visible: NotificationService.appNames.length === 0
            label: "No apps yet"
            value: "Apps show up here after they send a notification"
        }

        Repeater {
            model: NotificationService.appNames

            ToggleRow {
                required property string modelData
                required property int index

                label: modelData
                description: index === 0 ? "Muted apps show no popup but stay in the notification center" : ""
                checked: NotificationService.isMuted(modelData)
                onToggled: (val) => NotificationService.setMuted(modelData, val)
                showDivider: index < NotificationService.appNames.length - 1
            }
        }
    }
}