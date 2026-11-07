// features/notifications/FocusNotificationsSettings.qml — the Focus & Notifications menu.
// Alerts and Toasts open from the list at the bottom.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "."
import "../../core/shell"
import "../../core/styles"
import "../control-center/components/subviews"

PageScroll {
    id: root

    // Every ShellState key in Focus & Notifications, sub-pages included (used by the Reset row).
    // Focus itself is not reset: it is something you switch on and off, not a setting.
    readonly property var resetKeys: [
        "notificationPopupStyle", "notificationSnoozeMinutes",
        "notificationPreviewsEnabled", "notificationCenterWidth", "notificationCenterMaxHeight",
        "notificationAutoHide", "notificationTimeoutMs", "notificationRespectAppTimeout",
        "notificationCriticalBypassFocus", "notificationCriticalSticky",
        "notificationGroupExpanded", "notificationGroupPreviewCount",
        "notificationHistoryLimit", "notificationMutedApps",
        "notificationSoundMode", "notificationSoundFile",
        "notificationToastMaxWidth", "eventToastMs", "appToastMs", "notificationOverFullscreen",
        "appToastEnabled", "eventToastCharging", "eventToastDnd",
        "eventToastAudioOutput", "eventToastAudioInput", "timerToastShowRecordingIndicator"
    ]

    SectionLabel { text: "Focus" }

    FocusSubView {
        Layout.fillWidth: true
        showBackButton: false
    }

    SectionLabel {
        text: "Notification popups"
        Layout.topMargin: Dimens.spacingLarge
    }

    GroupCard {
        NotificationStylePicker {
            showDivider: ShellState.notificationPopupStyle === "Interactive"
        }

        Reveal {
            shown: ShellState.notificationPopupStyle === "Interactive"

            SliderRow {
                label: "Snooze length"
                description: "How long the Snooze button hides a notification before it pops up again"
                from: 1; to: 60; stepSize: 1
                value: ShellState.notificationSnoozeMinutes
                unit: " min"
                onMoved: (val) => ShellState.notificationSnoozeMinutes = val
                showDivider: false
            }
        }
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
            description: "Also the width of Detailed and Interactive popups"
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
        }

        ButtonRow {
            label: "Clear all notifications"
            description: NotificationService.count === 0
                ? "The notification center is already empty"
                : NotificationService.count + " in the notification center"
            buttonText: "Clear"
            enabled: NotificationService.count > 0
            showDivider: false
            onClicked: NotificationService.clearAll()
        }
    }

    SectionLabel { text: "More notification settings" }

    ViewList {}

    SectionLabel { text: "Reset" }

    GroupCard {
        ResetRow {
            menuName: "Focus & Notifications"
            keys: root.resetKeys
        }
    }
}