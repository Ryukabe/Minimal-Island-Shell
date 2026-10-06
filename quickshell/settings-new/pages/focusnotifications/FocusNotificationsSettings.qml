// pages/focusnotifications/FocusNotificationsSettings.qml — Focus & Notifications.
// Real: the Focus subview and notification previews. The rest comes from Caelestia and has no backend yet.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"
import "../../../components/control-center/subviews"

PageScroll {
    id: root

    SectionLabel { text: "Focus" }

    FocusSubView {
        Layout.fillWidth: true
        showBackButton: false
    }

    SectionLabel {
        text: "Notifications"
        Layout.topMargin: Dimens.spacingLarge
    }

    GroupCard {
        ToggleRow {
            label: "Show notification previews"
            checked: ShellState.notificationPreviewsEnabled
            onToggled: (val) => ShellState.notificationPreviewsEnabled = val
        }

        ToggleRow {
            label: "Show over fullscreen apps"
            placeholder: true
        }

        ToggleRow {
            label: "Expire automatically"
            description: "Dismiss notifications after their timeout"
            placeholder: true
        }

        ToggleRow {
            label: "Open expanded"
            description: "Show notifications expanded by default"
            placeholder: true
        }

        SliderRow {
            label: "Default timeout"
            from: 1000; to: 15000; stepSize: 500
            value: 5000
            unit: " ms"
            placeholder: true
        }

        SliderRow {
            label: "Group preview count"
            description: "Notifications shown per group before collapsing"
            from: 1; to: 8; stepSize: 1
            value: 3
            placeholder: true
            showDivider: false
        }
    }

    SectionLabel { text: "Toasts" }

    GroupCard {
        ToggleRow {
            label: "Show over fullscreen apps"
            placeholder: true
        }

        SliderRow {
            label: "Visible toasts"
            description: "Maximum shown at once"
            from: 1; to: 8; stepSize: 1
            value: 4
            placeholder: true
            showDivider: false
        }
    }

    SectionLabel { text: "Toast events" }

    GroupCard {
        ToggleRow { label: "Charging changes"; placeholder: true }
        ToggleRow { label: "Game mode changes"; placeholder: true }
        ToggleRow { label: "Do not disturb changes"; placeholder: true }
        ToggleRow { label: "Audio output changes"; placeholder: true }
        ToggleRow { label: "Audio input changes"; placeholder: true; showDivider: false }
    }
}