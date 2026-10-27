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
            description: "On: every corner follows the island radius. Off: set each kind of component yourself"
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

    SectionLabel { text: "Shadow" }

    GroupCard {
        ToggleRow {
            label: "Enable shadow"
            description: "Soft shadow around the island"
            checked: Colors.islandShadowEnabled
            onToggled: (val) => Colors.islandShadowEnabled = val
        }

        ColorRow {
            label: "Shadow color"
            value: Colors.shadowColor
            enabled: Colors.islandShadowEnabled
            opacity: Colors.islandShadowEnabled ? 1.0 : 0.4
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
