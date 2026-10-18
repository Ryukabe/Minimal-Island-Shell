// features/display/DisplaySettings.qml — Displays. One card per connected monitor.
// Real: resolution and refresh rate, scale, brightness, night light, shades and Reduce transparency.
// Greyed rows are placeholders.
// Scale is applied after a short pause, so dragging the slider doesn't re-scale the screen on every step.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "."
import "../hyprland"
import "../../core/styles"

PageScroll {
    id: root

    // "Off" first, then every shader found in ~/.config/hypr/shaders, with display names.
    readonly property var shadeOptions: ["Off"].concat(
        HyprshadeService.shades.map(s => HyprshadeService.prettyName(s)))

    Component.onCompleted: {
        LayoutSettingsService.refresh()
        HyprshadeService.refresh()
    }

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

    // Brightness is not per monitor: brightnessctl drives the laptop backlight, so it sits outside the cards.
    SectionLabel { text: "Brightness" }

    GroupCard {
        SliderRow {
            label: "Screen brightness"
            description: "Backlight level"
            from: 1; to: 100; stepSize: 1
            value: BrightnessService.percent
            unit: " %"
            onMoved: (val) => BrightnessService.setPercent(val)
        }

        SliderRow {
            label: "Brightness step"
            description: "How much brightness changes per key press or scroll"
            from: 1; to: 20; stepSize: 1
            value: ShellState.brightnessStep
            unit: " %"
            onMoved: (val) => ShellState.brightnessStep = val
            showDivider: false
        }
    }

    SectionLabel { text: "Night light" }

    GroupCard {
        ToggleRow {
            label: "Night light"
            description: "Warms the screen colours"
            checked: NightLightService.enabled
            onToggled: (val) => { if (val !== NightLightService.enabled) NightLightService.toggle() }
        }

        SliderRow {
            label: "Temperature"
            description: "Lower is warmer. Changes live while night light is on"
            from: NightLightService.minTemperature
            to: NightLightService.maxTemperature
            stepSize: NightLightService.temperatureStep
            value: NightLightService.temperature
            unit: " K"
            onMoved: (val) => NightLightService.setTemperature(val)
            showDivider: false
        }
    }

    SectionLabel { text: "Shades" }

    GroupCard {
        DropdownRow {
            label: "Shade"
            description: "Colour filter over the whole screen. Add .glsl files to ~/.config/hypr/shaders for more"
            options: root.shadeOptions
            selectedValue: HyprshadeService.enabled ? HyprshadeService.prettyName(HyprshadeService.current) : "Off"
            onOptionSelected: (value) => {
                const i = root.shadeOptions.indexOf(value)
                if (i <= 0) HyprshadeService.turnOff()
                else HyprshadeService.select(HyprshadeService.shades[i - 1])
            }
            showDivider: false
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