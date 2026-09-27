// settings/displays/Displays.qml — was System.qml's "Display & Resolution" group
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"
import "../common"

Item {
    id: root

    SettingsScrollView {
        SettingsGroup {
            title: "Display & Resolution"
            description: "Monitor settings, refresh rates, resolution, and transparency"
            icon: "desktop_windows"
            expanded: true

            Repeater {
                model: MonitorSettingsService.monitors
                delegate: ColumnLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: Dimens.spacingSmall

                    SettingsSectionLabel { label: parent.modelData.description }

                    SettingsDropdownRow {
                        id: resolutionDropdown
                        label: "Resolution & Refresh Rate"
                        options: parent.modelData.availableModes
                        selectedValue: parent.modelData.width + "x" + parent.modelData.height + "@" + Math.round(parent.modelData.refreshRate)
                        onToggled: resolutionDropdown.isOpen = !resolutionDropdown.isOpen
                        onOptionSelected: (value) => {
                            MonitorSettingsService.setMode(parent.modelData.name, value)
                            resolutionDropdown.isOpen = false
                        }
                    }

                    SettingsSliderRow {
                        label: "Scale"
                        from: 0.5; to: 3.0; stepSize: 0.05
                        value: parent.modelData.scale
                        decimals: 2
                        onMoved: (val) => MonitorSettingsService.setScale(parent.modelData.name, val)
                    }
                }
            }

            SettingsToggleRow {
                label: "Reduce Transparency"
                checked: Colors.reduceTransparency
                showDivider: false
                onToggled: (val) => {
                    Colors.reduceTransparency = val
                    HyprlandDecorationService.setBlurEnabled(!val)
                }
            }
        }
    }
}