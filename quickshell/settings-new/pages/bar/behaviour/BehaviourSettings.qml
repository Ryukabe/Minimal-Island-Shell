// pages/bar/behaviour/BehaviourSettings.qml — Bar & Island > Behaviour.
// UI only for now: these live on the page so the controls work while the settings are being built.
// When wiring, add matching ShellState properties (barPersistent, barShowOnHover, barDragThreshold,
// barScrollWorkspaces, barScrollVolume, barScrollBrightness) and bind them here.
import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../../services"
import "../../../../styles"

PageScroll {
    id: root

    property bool persistent: true
    property bool showOnHover: true
    property int dragThreshold: 20
    property bool scrollWorkspaces: true
    property bool scrollVolume: true
    property bool scrollBrightness: true

    SectionLabel { text: "Visibility" }

    GroupCard {
        ToggleRow {
            label: "Always visible"
            description: "Keep the island on screen at all times"
            checked: root.persistent
            onToggled: (val) => root.persistent = val
        }

        ToggleRow {
            label: "Show on hover"
            description: "Reveal the island when the pointer reaches the screen edge"
            checked: root.showOnHover
            enabled: !root.persistent
            onToggled: (val) => root.showOnHover = val
        }

        SliderRow {
            label: "Drag threshold"
            description: "Pixels dragged from the edge before the island reveals"
            from: 0; to: 100; stepSize: 5
            value: root.dragThreshold
            unit: " px"
            enabled: !root.persistent
            onMoved: (val) => root.dragThreshold = val
            showDivider: false
        }
    }

    SectionLabel { text: "Scroll actions" }

    GroupCard {
        ToggleRow {
            label: "Switch workspaces"
            description: "Scroll over the workspace indicator to change workspace"
            checked: root.scrollWorkspaces
            onToggled: (val) => root.scrollWorkspaces = val
        }

        ToggleRow {
            label: "Adjust volume"
            description: "Scroll on the top half of the island to change volume"
            checked: root.scrollVolume
            onToggled: (val) => root.scrollVolume = val
        }

        ToggleRow {
            label: "Adjust brightness"
            description: "Scroll on the bottom half of the island to change brightness"
            checked: root.scrollBrightness
            onToggled: (val) => root.scrollBrightness = val
            showDivider: false
        }
    }
}