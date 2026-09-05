// settings/system/System.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../styles"
import "../common"

Item {
    id: root
    property string powerProfile: "balanced"

    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors.rightMargin: 6
        clip: true
        contentWidth: availableWidth
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Item {
            width: scrollView.availableWidth
            implicitHeight: contentCol.implicitHeight + Dimens.paddingLarge

            ColumnLayout {
                id: contentCol
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(parent.width - Dimens.paddingMedium * 2, 640)
                spacing: 12

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
                    noteText: UpdateService.shellJustUpdated ? "Updated — restart the shell (pkill qs && qs) to apply." : ""
                    onCheckRequested: UpdateService.checkShellUpdate()
                    onActionRequested: UpdateService.runShellUpdate()
                }

                Button {
                    Layout.fillWidth: true
                    Layout.topMargin: Dimens.spacingLarge
                    text: "Reload Shell State"
                }
            }
        }
    }
}