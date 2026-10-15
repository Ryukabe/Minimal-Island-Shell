// pages/display/DisplaySettings.qml — Displays. One card per connected monitor.
// Real: resolution and refresh rate, scale, and Reduce transparency. Greyed rows are placeholders.
// Scale is applied after a short pause, so dragging the slider doesn't re-scale the screen on every step.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "."
import "../hyprland"
import "../../core/styles"

PageScroll {
    id: root

    Component.onCompleted: LayoutSettingsService.refresh()

Repeater {
    model: MonitorSettingsService.monitors

    delegate: ColumnLayout {
        id: monitorBlock
        required property var modelData

        // availableModes entries look like "1366x768@60"
        readonly property string currentRes: modelData.width + "x" + modelData.height
        readonly property int currentHz: Math.round(modelData.refreshRate)

        readonly property var resolutions: {
            const seen = []
            for (const m of modelData.availableModes) {
                const r = m.split("@")[0]
                if (seen.indexOf(r) < 0) seen.push(r)
            }
            return seen
        }

        // Only the refresh rates the current resolution supports
        readonly property var refreshRates: {
            const out = []
            for (const m of modelData.availableModes) {
                const parts = m.split("@")
                if (parts[0] === currentRes && out.indexOf(parts[1]) < 0) out.push(parts[1])
            }
            return out
        }

        readonly property var scalePresets: ["1", "1.25", "1.5", "2"]

        Layout.fillWidth: true
        spacing: Dimens.spacingSmall

        SectionLabel { text: monitorBlock.modelData.description }

        GroupCard {
            DropdownRow {
                label: "Resolution"
                options: monitorBlock.resolutions
                selectedValue: monitorBlock.currentRes
                onOptionSelected: (res) => {
                    // Keep the current refresh rate if the new resolution supports it, else take the first listed
                    const modes = monitorBlock.modelData.availableModes
                    const want = res + "@" + monitorBlock.currentHz
                    const pick = modes.indexOf(want) >= 0
                        ? want
                        : modes.find(m => m.startsWith(res + "@"))
                    MonitorSettingsService.setMode(monitorBlock.modelData.name, pick)
                }
            }

            DropdownRow {
                label: "Refresh rate"
                options: monitorBlock.refreshRates
                selectedValue: String(monitorBlock.currentHz)
                onOptionSelected: (hz) =>
                    MonitorSettingsService.setMode(monitorBlock.modelData.name,
                                                   monitorBlock.currentRes + "@" + hz)
            }

            DropdownRow {
                label: "Scale"
                description: "Makes everything on this screen larger or smaller"
                options: monitorBlock.scalePresets
                // Hyprland reports float noise (1.2000000476...), so round before comparing
                selectedValue: String(Math.round(monitorBlock.modelData.scale * 100) / 100)
                onOptionSelected: (val) =>
                    MonitorSettingsService.setScale(monitorBlock.modelData.name, parseFloat(val))
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
            
            GroupCard {
                DropdownRow {
                    label: "Tiling layout"
                    options: LayoutSettingsService.layouts
                    selectedValue: LayoutSettingsService.current
                    onOptionSelected: (value) => LayoutSettingsService.setLayout(value)
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