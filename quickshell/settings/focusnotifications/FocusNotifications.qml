// settings/focusnotifications/FocusNotifications.qml
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"
import "../common"
import "../../components/control-center/subviews"

Item {
    id: root

    SettingsScrollView {
        SettingsSectionLabel { label: "Focus" }

        FocusSubView {
            Layout.fillWidth: true
            showBackButton: false
        }

        SettingsSectionLabel {
            label: "Notifications"
            Layout.topMargin: Dimens.spacingLarge
        }

        SettingsToggleRow {
            label: "Show Notification Previews"
            checked: ShellState.notificationPreviewsEnabled
            showDivider: false
            onToggled: (val) => ShellState.notificationPreviewsEnabled = val
        }
    }
}