// settings/focusnotifications/FocusNotifications.qml — was System.qml's "Notifications & Peace Mode" group
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"
import "../common"

Item {
    id: root

    SettingsScrollView {
        SettingsGroup {
            title: "Notifications & Peace Mode"
            description: "Alert preferences, Do Not Disturb, and preview visibility"
            icon: "notifications"
            expanded: true

            SettingsToggleRow {
                label: "Peace Mode (Do Not Disturb)"
                checked: ShellState.focusModeEnabled
                showDivider: true
                onToggled: ShellState.toggleFocusMode()
            }

            SettingsToggleRow {
                label: "Show Notification Previews"
                checked: ShellState.notificationPreviewsEnabled
                showDivider: false
                onToggled: (val) => ShellState.notificationPreviewsEnabled = val
            }
        }
    }
}