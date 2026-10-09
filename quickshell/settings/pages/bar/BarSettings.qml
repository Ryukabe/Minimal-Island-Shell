// pages/bar/BarSettings.qml — the Bar & Island menu itself. Its own options sit here;
// Workspaces and Clock open from the list at the bottom.
// Everything here is bound to ShellState.
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
            description: "Off: the island slides away while it is idle and windows get the space back"
            checked: ShellState.islandAlwaysVisible
            onToggled: (val) => ShellState.islandAlwaysVisible = val
            showDivider: !ShellState.islandAlwaysVisible
        }

        Reveal {
            shown: !ShellState.islandAlwaysVisible

            ToggleRow {
                label: "Show on hover"
                description: "Reveal the island when the pointer reaches the top edge. Off: it only appears for panels, toasts and shortcuts"
                checked: ShellState.islandRevealOnHover
                onToggled: (val) => ShellState.islandRevealOnHover = val
            }

            SliderRow {
                label: "Reveal zone"
                description: "Height of the edge strip that reveals the island"
                from: 1; to: 40; stepSize: 1
                value: ShellState.islandRevealZone
                unit: " px"
                enabled: ShellState.islandRevealOnHover
                onMoved: (val) => ShellState.islandRevealZone = val
            }

            SliderRow {
                label: "Hide delay"
                description: "How long the island waits after the pointer leaves before it slides away"
                from: 200; to: 3000; stepSize: 100
                value: ShellState.islandHideDelayMs
                unit: " ms"
                onMoved: (val) => ShellState.islandHideDelayMs = val
                showDivider: false
            }
        }
    }

    SectionLabel { text: "Scroll gestures" }

    GroupCard {
        ToggleRow {
            label: "Adjust volume"
            description: "Scroll on the top half of the island"
            checked: ShellState.islandScrollVolume
            onToggled: (val) => ShellState.islandScrollVolume = val
        }

        ToggleRow {
            label: "Adjust brightness"
            description: "Scroll on the bottom half of the island"
            checked: ShellState.islandScrollBrightness
            onToggled: (val) => ShellState.islandScrollBrightness = val
            showDivider: false
        }
    }

    SectionLabel { text: "Parts of the bar" }

    ViewList {}
}