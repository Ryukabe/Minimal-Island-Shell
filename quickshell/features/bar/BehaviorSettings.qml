// features/bar/BehaviorSettings.qml — Bar & Island > Behavior. When the island shows,
// how it reacts to the pointer, and what scrolling on it does.
// Everything here is bound to ShellState.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "../../core/shell"
import "../../core/styles"

PageScroll {
    id: root

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
}
