// features/dashboard/DashboardSettings.qml — Dashboard: panel size, grid, which components show,
// and a live preview where components are moved and resized. Per-component options live on their own pages.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "."
import "../../core/shell"
import "../../core/styles"

PageScroll {
    id: root

    readonly property var columnOptions: ["8", "10", "12", "14", "16"]
    readonly property var rowOptions: ["4", "5", "6", "7", "8"]
    readonly property var selectedTile: DashboardLayoutService.tileInfo(grid.selectedTileId)

    function toggleType(type) {
        if (DashboardLayoutService.hasType(type)) {
            if (grid.selectedTileId === type) grid.selectedTileId = ""
            DashboardLayoutService.removeTile(type)
        } else {
            DashboardLayoutService.addTile(type)
        }
    }

    SectionLabel { text: "Panel size" }

    GroupCard {
        SliderRow {
            label: "Width"
            description: "Width of the Dashboard panel"
            from: 480
            to: 1400
            stepSize: 10
            value: ShellState.statusPanelWidth
            unit: "px"
            onMoved: (v) => ShellState.statusPanelWidth = v
        }

        SliderRow {
            label: "Height"
            description: "Height of the Dashboard panel"
            from: 300
            to: 900
            stepSize: 10
            value: ShellState.statusPanelHeight
            unit: "px"
            onMoved: (v) => ShellState.statusPanelHeight = v
        }
    }

    SectionLabel { text: "Grid" }

    GroupCard {
        SegmentRow {
            label: "Columns"
            options: root.columnOptions
            selectedValue: String(DashboardLayoutService.columns)
            onOptionSelected: (name) => DashboardLayoutService.setGrid(parseInt(name), DashboardLayoutService.rows)
        }

        SegmentRow {
            label: "Rows"
            options: root.rowOptions
            selectedValue: String(DashboardLayoutService.rows)
            onOptionSelected: (name) => DashboardLayoutService.setGrid(DashboardLayoutService.columns, parseInt(name))
            showDivider: false
        }
    }

    SectionLabel { text: "Components" }

    GroupCard {
        ToggleRow {
            label: "Quick note"
            description: "A Markdown note you can write in"
            checked: DashboardLayoutService.hasType("quicknote")
            onToggled: root.toggleType("quicknote")
        }

        ToggleRow {
            label: "Media"
            description: "Spinning CD with playback buttons"
            checked: DashboardLayoutService.hasType("media")
            onToggled: root.toggleType("media")
        }

        ToggleRow {
            label: "System stats"
            description: "CPU, GPU, memory, network, battery, temperature"
            checked: DashboardLayoutService.hasType("stats")
            onToggled: root.toggleType("stats")
        }

        ToggleRow {
            label: "Calendar"
            description: "Month view"
            checked: DashboardLayoutService.hasType("calendar")
            onToggled: root.toggleType("calendar")
        }
    }

    SectionLabel { text: "Layout tools" }

    GroupCard {
        ButtonRow {
            label: "Undo"
            description: "Step back one change"
            buttonText: "Undo"
            enabled: DashboardLayoutService.undoStack.length > 0
            onClicked: DashboardLayoutService.undo()
        }

        ButtonRow {
            label: "Reset layout"
            description: "Back to the default components and a 12 × 6 grid"
            buttonText: "Reset"
            showDivider: false
            onClicked: DashboardLayoutService.resetToDefault()
        }
    }

    SectionLabel { text: "Layout" }

    // Same proportions as the real panel (scaled down to fit).
    Rectangle {
        id: previewPanel

        readonly property real pad: Dimens.paddingMedium
        readonly property real panelW: Math.max(200, Math.min(root.width - Dimens.paddingLarge * 2, ShellState.statusPanelWidth))

        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: panelW
        Layout.preferredHeight: panelW * ShellState.statusPanelHeight / ShellState.statusPanelWidth

        radius: Dimens.radiusIsland
        color: Colors.mainBgMica
        border.width: 1
        border.color: Colors.border

        DashboardGrid {
            id: grid
            anchors.fill: parent
            anchors.margins: previewPanel.pad
            editMode: true
        }
    }

    Text {
        Layout.fillWidth: true
        leftPadding: Dimens.paddingSmall
        wrapMode: Text.WordWrap
        text: "Click a component to select it. Drag it to move it and use the four corner dots to resize it. With one selected, the arrow keys move it and Shift + arrows resize it."
        color: Colors.subtext
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeXs
    }

    Reveal {
        shown: root.selectedTile !== null

        SectionLabel { text: "Selected component" }

        GroupCard {
            InfoRow {
                label: root.selectedTile
                    ? (DashboardLayoutService.typeDisplayNames[root.selectedTile.type] || root.selectedTile.type) : ""
                value: root.selectedTile ? root.selectedTile.colSpan + " × " + root.selectedTile.rowSpan : ""
            }

            ButtonRow {
                label: "Remove from the Dashboard"
                description: "You can add it back under Components"
                buttonText: "Remove"
                showDivider: false
                onClicked: {
                    const id = grid.selectedTileId
                    grid.selectedTileId = ""
                    DashboardLayoutService.removeTile(id)
                }
            }
        }
    }
}