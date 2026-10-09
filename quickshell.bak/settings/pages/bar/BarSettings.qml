// pages/bar/BarSettings.qml — the Bar & Island menu itself. Its own options sit here;
// Workspaces and Clock open from the list at the bottom.
// Real: everything bound to ShellState. Greyed rows are placeholders until the island supports them.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"

PageScroll {
    id: root

    SectionLabel { text: "Shape" }

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
        }

        SliderRow {
            label: "Border width"
            description: "Not used while notch mode is on"
            from: 0; to: 4; stepSize: 1
            value: ShellState.islandBorderWidth
            unit: " px"
            enabled: !ShellState.islandNotchMode
            onMoved: (val) => ShellState.islandBorderWidth = val
        }

        SliderRow {
            label: "Top margin"
            description: "Gap between the screen edge and the island"
            from: 0; to: 40; stepSize: 1
            value: ShellState.islandTopMargin
            unit: " px"
            enabled: !ShellState.islandNotchMode
            onMoved: (val) => ShellState.islandTopMargin = val
            showDivider: false
        }
    }

    SectionLabel { text: "Notch" }

    GroupCard {
        ToggleRow {
            label: "Notch mode"
            description: "Attaches the island to the top edge like a display notch"
            checked: ShellState.islandNotchMode
            onToggled: (val) => ShellState.islandNotchMode = val
            showDivider: ShellState.islandNotchMode
        }

        Reveal {
            shown: ShellState.islandNotchMode

            SliderRow {
                label: "Notch flare"
                description: "How far the notch curves out into the screen edge"
                from: 0; to: 40; stepSize: 1
                value: ShellState.islandNotchFlare
                unit: " px"
                onMoved: (val) => ShellState.islandNotchFlare = val
                showDivider: false
            }
        }
    }

    SectionLabel { text: "Size" }

    GroupCard {
        SliderRow {
            label: "Bar height"
            from: 24; to: 60; stepSize: 1
            value: ShellState.islandCompactHeight
            unit: " px"
            onMoved: (val) => ShellState.islandCompactHeight = val
        }

        SliderRow {
            label: "Collapsed width"
            from: 80; to: 300; stepSize: 1
            value: ShellState.islandCompactWidth
            unit: " px"
            onMoved: (val) => ShellState.islandCompactWidth = val
        }

        SliderRow {
            label: "Expanded height floor"
            description: "Smallest height the island has while a panel is open"
            from: 60; to: 400; stepSize: 1
            value: ShellState.islandExpandedHeight
            unit: " px"
            onMoved: (val) => ShellState.islandExpandedHeight = val
        }

        SliderRow {
            label: "Minimum expanded width"
            from: 300; to: 900; stepSize: 1
            value: ShellState.islandMinExpandedWidth
            unit: " px"
            onMoved: (val) => ShellState.islandMinExpandedWidth = val
            showDivider: false
        }
    }

    SectionLabel { text: "Interaction" }

    GroupCard {
        SliderRow {
            label: "Lift on hover"
            description: "Scale of the island while the pointer is over it. 1 is no lift"
            from: 1.0; to: 1.1; stepSize: 0.005
            value: ShellState.islandHoverScale
            onMoved: (val) => ShellState.islandHoverScale = val
        }

        ToggleRow {
            label: "Click outside to dismiss"
            description: "Closes an open panel when you click anywhere else"
            checked: ShellState.islandClickOutsideDismiss
            onToggled: (val) => ShellState.islandClickOutsideDismiss = val
            showDivider: false
        }
    }

    SectionLabel { text: "Visibility" }

    GroupCard {
        ToggleRow {
            label: "Always visible"
            description: "Keep the island on screen at all times"
            checked: true
            placeholder: true
        }

        ToggleRow {
            label: "Show on hover"
            description: "Reveal the island when the pointer reaches the screen edge"
            checked: true
            placeholder: true
        }

        SliderRow {
            label: "Drag threshold"
            description: "Pixels dragged from the edge before the island reveals"
            from: 0; to: 100; stepSize: 5
            value: 20
            unit: " px"
            placeholder: true
            showDivider: false
        }
    }

    SectionLabel { text: "Scroll gestures" }

    GroupCard {
        ToggleRow {
            label: "Switch workspaces"
            description: "Scroll over the workspace indicator"
            checked: true
            placeholder: true
        }

        ToggleRow {
            label: "Adjust volume"
            description: "Scroll on the top half of the island"
            checked: true
            placeholder: true
        }

        ToggleRow {
            label: "Adjust brightness"
            description: "Scroll on the bottom half of the island"
            checked: true
            placeholder: true
            showDivider: false
        }
    }

    SectionLabel { text: "Parts of the bar" }

    ViewList {}
}