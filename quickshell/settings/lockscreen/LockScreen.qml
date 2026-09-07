// settings/lockscreen/LockScreen.qml
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"
import "../common"

Item {
    id: root

    SettingsScrollView {
        anchors.fill: parent

        SettingsHeader {
            icon: "lock"
            title: "Lock Screen"
            subtitle: "Security and background appearance while locked."
        }

        SettingsSectionLabel { label: "Clock" }

        SettingsToggleRow {
            label: "24-Hour Clock"
            checked: LockScreenSettings.clockFormat24h
            showDivider: false
            onToggled: (val) => LockScreenSettings.clockFormat24h = val
        }

        SettingsToggleRow {
            label: "Show Date"
            checked: LockScreenSettings.showDate
            showDivider: false
            onToggled: (val) => LockScreenSettings.showDate = val
        }

        SettingsSectionLabel { label: "Identity" }

        SettingsToggleRow {
            label: "Show Username"
            checked: LockScreenSettings.showUsername
            showDivider: false
            onToggled: (val) => LockScreenSettings.showUsername = val
        }

        SettingsSectionLabel { label: "Password Field" }

        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: Dimens.spacingMedium

            Text {
                text: "Placeholder Text"
                color: Colors.fg
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
                Layout.fillWidth: true
            }

            Rectangle {
                implicitWidth: Math.max(100, placeholderInput.implicitWidth + 24)
                implicitHeight: 28
                radius: Dimens.radiusSmall
                color: placeholderInput.activeFocus
                    ? Qt.rgba(1, 1, 1, 0.08)
                    : (placeholderMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(1, 1, 1, 0.03))
                border.color: placeholderInput.activeFocus ? Colors.accent : Qt.rgba(1, 1, 1, 0.12)
                border.width: 1

                MouseArea {
                    id: placeholderMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: placeholderInput.forceActiveFocus()
                }

                TextInput {
                    id: placeholderInput
                    anchors.centerIn: parent
                    text: LockScreenSettings.passwordPlaceholder
                    color: activeFocus ? Colors.fg : Colors.subtext
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeBase
                    selectByMouse: true
                    onEditingFinished: LockScreenSettings.passwordPlaceholder = text
                }
            }
        }

        SettingsToggleRow {
            label: "Use Accent Color for Errors"
            checked: LockScreenSettings.errorUsesAccent
            showDivider: false
            onToggled: (val) => LockScreenSettings.errorUsesAccent = val
        }

        SettingsSectionLabel { label: "Background" }

        SettingsToggleRow {
            label: "Frosted Glass Background Blur"
            checked: LockScreenSettings.frostedBlurEnabled
            showDivider: false
            onToggled: (val) => LockScreenSettings.frostedBlurEnabled = val
        }

        SettingsSliderRow {
            label: "Blur Strength"
            from: 0
            to: 64
            stepSize: 1
            value: LockScreenSettings.frostedBlurRadius
            enabled: LockScreenSettings.frostedBlurEnabled
            opacity: enabled ? 1.0 : 0.4
            onMoved: (val) => LockScreenSettings.frostedBlurRadius = val
        }

        SettingsSliderRow {
            label: "Wallpaper Dim Intensity"
            from: 0
            to: 0.8
            stepSize: 0.01
            decimals: 2
            value: LockScreenSettings.wallpaperDimOpacity
            onMoved: (val) => LockScreenSettings.wallpaperDimOpacity = val
        }

        SettingsSectionLabel { label: "Nav Actions" }

        SettingsToggleRow {
            label: "Show HYPRLAND Action"
            checked: LockScreenSettings.showHyprlandAction
            showDivider: false
            onToggled: (val) => LockScreenSettings.showHyprlandAction = val
        }

        SettingsToggleRow {
            label: "Show REBOOT Action"
            checked: LockScreenSettings.showRebootAction
            showDivider: false
            onToggled: (val) => LockScreenSettings.showRebootAction = val
        }

        SettingsToggleRow {
            label: "Show POWER Action"
            checked: LockScreenSettings.showPowerAction
            showDivider: false
            onToggled: (val) => LockScreenSettings.showPowerAction = val
        }
    }
}