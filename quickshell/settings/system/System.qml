// settings/system/System.qml
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../common"

Item {
    id: root
    property string powerProfile: "balanced"

    SettingsScrollView {
        SettingsHeader {
            icon: "settings"
            title: "System"
            subtitle: "Hardware status, power management, and updates."
        }

        SettingsSectionLabel { label: "About" }

        SettingsRow { label: "Device Name"; value: SystemInfoService.hostname; showChevron: false }
        SettingsRow { label: "Operating System"; value: SystemInfoService.osName; showChevron: false }
        SettingsRow { label: "Kernel"; value: SystemInfoService.kernel; showChevron: false }
        SettingsRow { label: "Uptime"; value: SystemInfoService.uptime; showChevron: false }
        SettingsRow { label: "Memory"; value: SystemInfoService.memoryUsed; showChevron: false }
        SettingsRow { label: "Storage"; value: SystemInfoService.diskUsed; showChevron: false; showDivider: false }

        SettingsSectionLabel { label: "Power" }

        SettingsRow {
            label: "Active Power Profile"
            value: root.powerProfile.toUpperCase()
            showChevron: false
            showDivider: false
        }

        SettingsSectionLabel { label: "Updates" }

        SettingsUpdateCard {
            icon: "system_update"
            title: "System Packages"
            statusText: !UpdateService.systemChecked ? "Not checked yet"
                : UpdateService.systemUpdateCount === 0 ? "Up to date"
                : UpdateService.systemUpdateCount + " package(s) can be updated"
            checking: UpdateService.systemChecking
            actionEnabled: UpdateService.systemChecked && UpdateService.systemUpdateCount > 0
            actionText: "Update Now"
            lastCheckedText: UpdateService.formatTime(UpdateService.systemLastChecked)
            lastUpdatedText: UpdateService.formatTime(UpdateService.systemLastUpdated)
            noteText: UpdateService.systemJustUpdated ? "Update ran — some packages may need a reboot to fully apply." : ""
            onCheckRequested: UpdateService.checkSystemUpdates()
            onActionRequested: UpdateService.runSystemUpdate()
        }

        SettingsUpdateCard {
            icon: "auto_awesome"
            title: "Minimal-Island-Shell"
            statusText: !UpdateService.shellChecked ? "Not checked yet"
                : !UpdateService.shellUpdateAvailable ? "Up to date"
                : UpdateService.shellCommitsBehind + " commit(s) behind"
            checking: UpdateService.shellChecking
            actionEnabled: UpdateService.shellChecked && UpdateService.shellUpdateAvailable
            actionText: "Update Shell"
            busy: UpdateService.shellUpdating
            lastCheckedText: UpdateService.formatTime(UpdateService.shellLastChecked)
            lastUpdatedText: UpdateService.formatTime(UpdateService.shellLastUpdated)
            noteText: UpdateService.shellJustUpdated ? "Updated — restart the shell (pkill qs && qs) to apply." : ""
            onCheckRequested: UpdateService.checkShellUpdate()
            onActionRequested: UpdateService.runShellUpdate()
        }

        SettingsButton {
            primary: true
            Layout.fillWidth: true
            Layout.topMargin: Dimens.spacingLarge
            text: "Reload Shell State"
        }
    }
}