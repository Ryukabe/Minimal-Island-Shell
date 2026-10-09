// pages/display/DisplaySettings.qml — Displays. One card per connected monitor.
// Real: resolution and refresh rate, scale, and Reduce transparency. Greyed rows are placeholders.
// Scale is applied after a short pause, so dragging the slider doesn't re-scale the screen on every step.
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

            // -1 = not dragging; otherwise the value shown on the slider while a change is pending.
            property real pendingScale: -1

            Layout.fillWidth: true
            spacing: Dimens.spacingSmall

            // Applies the scale 300 ms after the last slider movement.
            Timer {
                id: applyTimer
                interval: 300
                onTriggered: {
                    MonitorSettingsService.setScale(monitorBlock.modelData.name, monitorBlock.pendingScale)
                    settleTimer.restart()
                }
            }

            // Keeps showing the chosen value until the monitor has had time to report the new scale.
            Timer {
                id: settleTimer
                interval: 900
                onTriggered: monitorBlock.pendingScale = -1
            }

            SectionLabel { text: monitorBlock.modelData.description }

            GroupCard {
                InfoRow {
                    label: "Current mode"
                    value: monitorBlock.modelData.width + "×" + monitorBlock.modelData.height
                           + " at " + Math.round(monitorBlock.modelData.refreshRate) + " Hz"
                }

                DropdownRow {
                    label: "Resolution & refresh rate"
                    options: monitorBlock.modelData.availableModes
                    selectedValue: monitorBlock.modelData.width + "x" + monitorBlock.modelData.height
                                   + "@" + Math.round(monitorBlock.modelData.refreshRate)
                    onOptionSelected: (value) => MonitorSettingsService.setMode(monitorBlock.modelData.name, value)
                }

                SliderRow {
                    label: "Scale"
                    description: "Makes everything on this screen larger or smaller"
                    from: 0.5; to: 3.0; stepSize: 0.05
                    value: monitorBlock.pendingScale >= 0 ? monitorBlock.pendingScale : monitorBlock.modelData.scale
                    onMoved: (val) => {
                        monitorBlock.pendingScale = val
                        settleTimer.stop()
                        applyTimer.restart()
                    }
                }

                ToggleRow {
                    label: "Variable refresh rate"
                    description: "Match the refresh rate to what is on screen"
                    placeholder: true
                }

                ToggleRow {
                    label: "Primary display"
                    description: "The main screen for new windows"
                    placeholder: true
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