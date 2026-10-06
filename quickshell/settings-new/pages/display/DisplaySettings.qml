// pages/display/DisplaySettings.qml — Displays. Real: MonitorSettingsService and Colors.reduceTransparency.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    Repeater {
        model: MonitorSettingsService.monitors

        delegate: ColumnLayout {
            id: monitorBlock
            required property var modelData

            Layout.fillWidth: true
            spacing: Dimens.spacingSmall

            SectionLabel { text: monitorBlock.modelData.description }

            GroupCard {
                DropdownRow {
                    label: "Resolution & refresh rate"
                    options: monitorBlock.modelData.availableModes
                    selectedValue: monitorBlock.modelData.width + "x" + monitorBlock.modelData.height
                                   + "@" + Math.round(monitorBlock.modelData.refreshRate)
                    onOptionSelected: (value) => MonitorSettingsService.setMode(monitorBlock.modelData.name, value)
                }

                SliderRow {
                    label: "Scale"
                    from: 0.5; to: 3.0; stepSize: 0.05
                    value: monitorBlock.modelData.scale
                    onMoved: (val) => MonitorSettingsService.setScale(monitorBlock.modelData.name, val)
                    showDivider: false
                }
            }
        }
    }

    SectionLabel { text: "Transparency" }

    GroupCard {
        ToggleRow {
            label: "Reduce transparency"
            description: "Turns off blur and mica behind the shell"
            checked: Colors.reduceTransparency
            onToggled: (val) => {
                Colors.reduceTransparency = val
                HyprlandDecorationService.setBlurEnabled(!val)
            }
            showDivider: false
        }
    }
}