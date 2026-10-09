// pages/focusnotifications/FocusNotificationsSettings.qml — the Focus & Notifications menu.
// Alerts and Toasts open from the list at the bottom.
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
        text: "Notification center"
        Layout.topMargin: Dimens.spacingLarge
    }

    GroupCard {
        ToggleRow {
            label: "Show previews"
            description: "Show the message text in notifications"
            checked: ShellState.notificationPreviewsEnabled
            onToggled: (val) => ShellState.notificationPreviewsEnabled = val
        }

        SliderRow {
            label: "Width"
            from: 280; to: 600; stepSize: 10
            value: ShellState.notificationCenterWidth
            unit: " px"
            onMoved: (val) => ShellState.notificationCenterWidth = val
        }

        SliderRow {
            label: "Maximum height"
            from: 250; to: 800; stepSize: 10
            value: ShellState.notificationCenterMaxHeight
            unit: " px"
            onMoved: (val) => ShellState.notificationCenterMaxHeight = val
            showDivider: false
        }
    }

    SectionLabel { text: "More notification settings" }

    ViewList {}
}