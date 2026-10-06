// pages/bar/island/IslandSettings.qml — Bar & Island > Island.
// Every control binds straight to ShellState; SettingsStore persists it.
import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../../services"
import "../../../../styles"

PageScroll {
    id: root

    SectionLabel { text: "Shape" }

    GroupCard {
        SliderRow {
            label: "Corner radius"
            description: "Every other radius in the shell is derived from this one"
            from: 0; to: 30; stepSize: 1
            value: ShellState.islandCornerRadius
            unit: " px"
            onMoved: (val) => ShellState.islandCornerRadius = val
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

        SliderRow {
            visible: ShellState.islandNotchMode
            label: "Notch flare"
            description: "How far the notch curves out into the screen edge"
            from: 0; to: 40; stepSize: 1
            value: ShellState.islandNotchFlare
            unit: " px"
            onMoved: (val) => ShellState.islandNotchFlare = val
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
}