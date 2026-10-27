// features/dashboard/DashboardSettings.qml — Dashboard: panel size, grid, which components show,
// and a live preview where components are moved and resized. Per-component options live on their own pages.
// Components that are not on the grid sit under "Add a component": tap one to add it, or drag it into the
// preview. Drag a component out of the preview to remove it.
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
    // Types that are not on the grid right now (hasType() re-evaluates on every layout change).
    readonly property var unplaced: DashboardLayoutService.manageableTypes.filter(t => !DashboardLayoutService.hasType(t))

    // Set when an add had nowhere to go, so the page can say why nothing happened.
    property string noRoomFor: ""

    // ---- Drag a component from "Add a component" into the preview ----
    CatalogDrag {
        id: dnd
        flickable: root.flickable
        viewport: root
        onDropped: (type, pos) => root.handleDrop(type, pos)
    }

    // The size a new component is tried at first (the same one addTile starts with).
    function newSize(type) {
        const d = DashboardLayoutService.defaultLayout.find(e => e.type === type
            && e.colSpan <= DashboardLayoutService.columns && e.rowSpan <= DashboardLayoutService.rows)
        const m = DashboardLayoutService.minFor(type)
        return d ? { c: d.colSpan, r: d.rowSpan } : { c: m.c, r: m.r }
    }

    // Where a component dropped at this scene point would land, or null when it is not over the preview.
    // The component is centred on the pointer.
    function planAt(type, scenePoint) {
        const q = previewPanel.mapFromItem(null, scenePoint.x, scenePoint.y)
        if (q.x < 0 || q.y < 0 || q.x > previewPanel.width || q.y > previewPanel.height) return null
        const g = grid.mapFromItem(null, scenePoint.x, scenePoint.y)
        const size = root.newSize(type)
        const col = Math.max(0, Math.min(grid.columns - size.c, Math.round(g.x / grid.stepX - size.c / 2)))
        const row = Math.max(0, Math.min(grid.rows - size.r, Math.round(g.y / grid.stepY - size.r / 2)))
        return { col: col, row: row, c: size.c, r: size.r }
    }

    readonly property var dropPlan: {
        dnd.tick
        return dnd.active ? root.planAt(dnd.type, dnd.scenePos) : null
    }

    function addByTap(type) {
        root.noRoomFor = DashboardLayoutService.addTile(type) ? "" : type
    }

    function handleDrop(type, pos) {
        const plan = root.planAt(type, pos)
        if (!plan) return
        // Add it, then place it exactly like moving a component: a taken spot goes to the nearest free one.
        if (!DashboardLayoutService.addTile(type)) {
            root.noRoomFor = type
            return
        }
        DashboardLayoutService.moveTile(type, plan.col, plan.row)
        grid.selectedTileId = type
        root.noRoomFor = ""
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

            // Where a component dragged in from "Add a component" would land.
            Rectangle {
                visible: root.dropPlan !== null
                z: 25
                x: root.dropPlan ? root.dropPlan.col * grid.stepX : 0
                y: root.dropPlan ? root.dropPlan.row * grid.stepY : 0
                width: root.dropPlan ? root.dropPlan.c * grid.stepX - grid.gap : 0
                height: root.dropPlan ? root.dropPlan.r * grid.stepY - grid.gap : 0
                radius: Dimens.radiusCard
                color: "transparent"
                border.width: 2
                border.color: Colors.accent

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Colors.accent
                    opacity: 0.14
                }
            }
        }
    }

    Text {
        Layout.fillWidth: true
        leftPadding: Dimens.paddingSmall
        wrapMode: Text.WordWrap
        text: "Click a component to select it. Drag it to move it and use the four corner dots to resize it. Drag it out of the preview to remove it. With one selected, the arrow keys move it and Shift + arrows resize it."
        color: Colors.subtext
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeXs
    }

    SectionLabel { text: "Add a component" }

    GroupCard {
        InfoRow {
            visible: root.unplaced.length === 0
            label: "Every component is already on the Dashboard"
            showDivider: false
        }

        Flow {
            visible: root.unplaced.length > 0
            Layout.fillWidth: true
            Layout.margins: Dimens.paddingMedium
            spacing: Dimens.spacingSmall

            Repeater {
                model: root.unplaced

                delegate: CatalogChip {
                    id: addChip
                    required property string modelData

                    typeId: addChip.modelData
                    label: DashboardLayoutService.typeDisplayNames[addChip.modelData] || addChip.modelData
                    controller: dnd
                    onActivated: root.addByTap(addChip.modelData)
                }
            }
        }
    }

    Text {
        visible: root.noRoomFor !== ""
        Layout.fillWidth: true
        leftPadding: Dimens.paddingSmall
        wrapMode: Text.WordWrap
        text: (DashboardLayoutService.typeDisplayNames[root.noRoomFor] || root.noRoomFor)
              + " has no room. Make the grid bigger or remove something first."
        color: Colors.yellow
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
                description: "You can add it back above"
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
