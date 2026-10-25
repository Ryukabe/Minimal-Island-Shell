// features/theme/CornersSettings.qml — Appearance > Corners. How round things are: the island,
// settings cards, controls and small chips. Everything here is bound to ShellState.
import QtQuick
import QtQuick.Layouts
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
}
