// features/theme/OpacitySettings.qml — Appearance > Surfaces. Corner radius, mica transparency and
// the island's drop shadow. Radius values live on ShellState. Opacity and shadow values are 0-1
// numbers on Colors, shown here as percentages so the sliders need no decimals.
import QtQuick
import "../settings/components"
import "../../core/shell"
import "../../core/styles"

PageScroll {
    id: root

    SectionLabel { text: "Radius" }

    GroupCard {
        ToggleRow {
            label: "Universal radius"
            description: "On: every corner follows the island radius, windows included. Off: set each kind of component yourself"
            checked: ShellState.radiusUniversal
            onToggled: (val) => ShellState.radiusUniversal = val
        }

        SliderRow {
            label: "Island radius"
            description: ShellState.radiusUniversal
                ? "Everything else follows this"
                : "Corners of the island itself"
            from: 0; to: 30; stepSize: 1
            value: ShellState.islandCornerRadius
            unit: " px"
            onMoved: (val) => ShellState.islandCornerRadius = val
            showDivider: !ShellState.radiusUniversal
        }

        Reveal {
            shown: !ShellState.radiusUniversal

            SliderRow {
                label: "Card radius"
                description: "Settings cards, page title and sidebar items"
                from: 0; to: 30; stepSize: 1
                value: ShellState.customRadiusCard
                unit: " px"
                onMoved: (val) => ShellState.customRadiusCard = val
            }

            SliderRow {
                label: "Control radius"
                description: "Rows, buttons, inputs and the search box"
                from: 0; to: 30; stepSize: 1
                value: ShellState.customRadiusControl
                unit: " px"
                onMoved: (val) => ShellState.customRadiusControl = val
            }

            SliderRow {
                label: "Chip radius"
                description: "Small tags and pickers"
                from: 0; to: 20; stepSize: 1
                value: ShellState.customRadiusChip
                unit: " px"
                onMoved: (val) => ShellState.customRadiusChip = val
            }

            SliderRow {
                label: "Window radius"
                description: "Corners of application windows (Hyprland)"
                from: 0; to: 30; stepSize: 1
                value: ShellState.customRadiusWindow
                unit: " px"
                onMoved: (val) => ShellState.customRadiusWindow = val
                showDivider: false
            }
        }
    }

    SectionLabel { text: "Opacity" }

    GroupCard {
        SliderRow {
            label: "Background "
            description: "Window and panel backgrounds"
            from: 0; to: 100; stepSize: 1
            value: Math.round(Colors.micaAlpha * 100)
            unit: " %"
            onMoved: (val) => Colors.micaAlpha = val / 100
        }

        SliderRow {
            label: "Foreground"
            description: "Cards and raised surfaces"
            from: 0; to: 100; stepSize: 1
            value: Math.round(Colors.micaBeta * 100)
            unit: " %"
            onMoved: (val) => Colors.micaBeta = val / 100
            showDivider: false
        }
    }

     SectionLabel { text: "Blur" }

    GroupCard {
        ToggleRow {
            label: "Universal blur"
            description: "On: one switch for windows and the island. Off: switch each one yourself"
            checked: ShellState.blurUniversal
            onToggled: (val) => ShellState.blurUniversal = val
        }

        Reveal {
            shown: ShellState.blurUniversal

            ToggleRow {
                label: "Blur"
                description: "Frosted glass behind windows and the island. Only shows through see-through surfaces"
                checked: ShellState.blurEnabled
                onToggled: (val) => ShellState.blurEnabled = val
            }
        }

        Reveal {
            shown: !ShellState.blurUniversal

            ToggleRow {
                label: "Window blur"
                description: "Blur behind application windows"
                checked: ShellState.customBlurWindows
                onToggled: (val) => ShellState.customBlurWindows = val
            }

            ToggleRow {
                label: "Island blur"
                description: "Blur behind the island and its panels"
                checked: ShellState.customBlurIsland
                onToggled: (val) => ShellState.customBlurIsland = val
            }
        }

        SliderRow {
            label: "Island cutoff"
            description: "The island is not blurred where it is more see-through than this. Keep it below Main opacity"
            from: 0; to: 100; stepSize: 5
            value: Math.round(ShellState.blurIslandCutoff * 100)
            unit: " %"
            enabled: ShellState.blurIslandActive
            onMoved: (val) => ShellState.blurIslandCutoff = val / 100
            showDivider: false
        }
    }

    SectionLabel { text: "Blur strength" }

    GroupCard {
        SliderRow {
            label: "Size"
            description: "How far the blur spreads. Shared by windows and the island"
            from: 1; to: 30; stepSize: 1
            value: ShellState.blurSize
            unit: ""
            enabled: ShellState.blurAnyActive
            onMoved: (val) => ShellState.blurSize = val
        }

        SliderRow {
            label: "Passes"
            description: "More passes look smoother but cost more GPU"
            from: 1; to: 10; stepSize: 1
            value: ShellState.blurPasses
            unit: ""
            enabled: ShellState.blurAnyActive
            onMoved: (val) => ShellState.blurPasses = val
            showDivider: false
        }
    }

    SectionLabel { text: "Blur look" }

    GroupCard {
        SliderRow {
            label: "Noise"
            description: "Fine grain over the blur, hides banding"
            from: 0; to: 50; stepSize: 1
            value: Math.round(ShellState.blurNoise * 100)
            unit: " %"
            enabled: ShellState.blurAnyActive
            onMoved: (val) => ShellState.blurNoise = val / 100
        }

        SliderRow {
            label: "Contrast"
            description: "100% leaves the blurred colors alone"
            from: 0; to: 200; stepSize: 1
            value: Math.round(ShellState.blurContrast * 100)
            unit: " %"
            enabled: ShellState.blurAnyActive
            onMoved: (val) => ShellState.blurContrast = val / 100
        }

        SliderRow {
            label: "Brightness"
            description: "Below 100% darkens what is behind the glass"
            from: 0; to: 200; stepSize: 1
            value: Math.round(ShellState.blurBrightness * 100)
            unit: " %"
            enabled: ShellState.blurAnyActive
            onMoved: (val) => ShellState.blurBrightness = val / 100
        }

        SliderRow {
            label: "Vibrancy"
            description: "Boosts the colors that show through"
            from: 0; to: 100; stepSize: 1
            value: Math.round(ShellState.blurVibrancy * 100)
            unit: " %"
            enabled: ShellState.blurAnyActive
            onMoved: (val) => ShellState.blurVibrancy = val / 100
        }

        SliderRow {
            label: "Vibrancy darkness"
            description: "How much the vibrancy boost favors dark colors"
            from: 0; to: 100; stepSize: 1
            value: Math.round(ShellState.blurVibrancyDarkness * 100)
            unit: " %"
            enabled: ShellState.blurAnyActive
            onMoved: (val) => ShellState.blurVibrancyDarkness = val / 100
            showDivider: false
        }
    }

    SectionLabel { text: "Blur behavior" }

    GroupCard {
        ToggleRow {
            label: "Ignore opacity"
            description: "Keep blurring behind windows that are already see-through"
            checked: ShellState.blurIgnoreOpacity
            onToggled: (val) => ShellState.blurIgnoreOpacity = val
        }

        ToggleRow {
            label: "X-ray"
            description: "Floating windows ignore the windows below them in their blur. Cheaper to draw"
            checked: ShellState.blurXray
            onToggled: (val) => ShellState.blurXray = val
        }

        ToggleRow {
            label: "Optimizations"
            description: "Extra blur speed-ups. Turn off only if you see artifacts"
            checked: ShellState.blurOptimizations
            onToggled: (val) => ShellState.blurOptimizations = val
        }

        ToggleRow {
            label: "Blur popups"
            description: "Menus and tooltips from applications"
            checked: ShellState.blurPopups
            onToggled: (val) => ShellState.blurPopups = val
        }
    }

    SectionLabel { text: "Shadow" }

    GroupCard {
        ToggleRow {
            label: "Enable shadow"
            description: "Soft shadow around the island. Its color is also used for window shadows"
            checked: Colors.islandShadowEnabled
            onToggled: (val) => Colors.islandShadowEnabled = val
        }

        ColorRow {
            label: "Shadow color"
            value: Colors.shadowColor
            enabled: Colors.islandShadowEnabled || ShellState.windowShadowEnabled
            opacity: (Colors.islandShadowEnabled || ShellState.windowShadowEnabled) ? 1.0 : 0.4
            onCommitted: (hex) => Colors.shadowColor = hex
        }

        SliderRow {
            label: "Shadow softness"
            from: 0; to: 100; stepSize: 1
            value: Math.round(Colors.shadowBlur * 100)
            unit: " %"
            enabled: Colors.islandShadowEnabled
            onMoved: (val) => Colors.shadowBlur = val / 100
        }

        SliderRow {
            label: "Shadow spread"
            description: "How far the shadow reaches past the island"
            from: 0; to: 100; stepSize: 5
            value: Math.round((Colors.shadowScale - 1) * 100)
            unit: " %"
            enabled: Colors.islandShadowEnabled
            onMoved: (val) => Colors.shadowScale = 1 + val / 100
            showDivider: false
        }
    }
}
