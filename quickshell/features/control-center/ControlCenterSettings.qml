// pages/controlcenter/ControlCenterSettings.qml — Control Center.
// Edit the tile grid: columns, layout tools, a live preview you can drag and resize,
// the controls that are not placed yet (tap one to add it, or drag it into the preview),
// and the selected tile's size. Drag a tile out of the preview to remove it.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "."
import "../../core/shell"
import "../../core/styles"
import "components"

PageScroll {
    id: root

    readonly property var columnOptions: ["5", "6", "7", "8", "9"]
    readonly property var selectedTile: {
        const idx = ControlCenterLayoutService.indexForId(grid.selectedTileId)
        return idx >= 0 ? ControlCenterLayoutService.layoutModel.get(idx) : null
    }
    readonly property var selectedSizes: root.selectedTile
        ? (ControlCenterLayoutService.allowedSizes[root.selectedTile.type] || []) : []
    readonly property var unplaced: ControlCenterLayoutService.unplacedTypes()

    // ---- Drag a control from "Add a control" into the preview ----
    CatalogDrag {
        id: dnd
        flickable: root.flickable
        viewport: root
        onDropped: (type, pos) => root.handleDrop(type, pos)
    }

    // Where a control dropped at this scene point would land, or null when it is not over the preview.
    // The control is centred on the pointer.
    function planAt(type, scenePoint) {
        const q = previewPanel.mapFromItem(null, scenePoint.x, scenePoint.y)
        if (q.x < 0 || q.y < 0 || q.x > previewPanel.width || q.y > previewPanel.height) return null
        const g = grid.mapFromItem(null, scenePoint.x, scenePoint.y)
        const size = ControlCenterLayoutService.defaultSizeForType(type)
        const col = Math.max(0, Math.min(grid.columns - size.c, Math.round(g.x / grid.stepX - size.c / 2)))
        const row = Math.max(0, Math.min(grid.gridRows - 1, Math.round(g.y / grid.stepY - size.r / 2)))
        return { col: col, row: row, c: size.c, r: size.r }
    }

    readonly property var dropPlan: {
        dnd.tick
        return dnd.active ? root.planAt(dnd.type, dnd.scenePos) : null
    }

    function handleDrop(type, pos) {
        const plan = root.planAt(type, pos)
        if (!plan) return
        // Add it, then place it exactly like moving a tile: whatever is in the way is pushed aside.
        ControlCenterLayoutService.addTile(type)
        ControlCenterLayoutService.moveTile(type, plan.col, plan.row)
        grid.selectedTileId = type
    }

    SectionLabel { text: "Grid" }

    GroupCard {
        SegmentRow {
            label: "Columns"
            options: root.columnOptions
            selectedValue: String(ControlCenterLayoutService.columns)
            onOptionSelected: (name) => ControlCenterLayoutService.setColumns(parseInt(name))
            showDivider: false
        }
    }

    SectionLabel { text: "Layout tools" }

    GroupCard {
        ButtonRow {
            label: "Tidy up"
            description: "Pack every tile into the first free space"
            buttonText: "Tidy"
            onClicked: ControlCenterLayoutService.tidyLayout()
        }

        ButtonRow {
            label: "Undo"
            description: "Step back one change"
            buttonText: "Undo"
            enabled: ControlCenterLayoutService.undoStack.length > 0
            onClicked: ControlCenterLayoutService.undo()
        }

        ButtonRow {
            label: "Reset layout"
            description: "Back to the default tiles"
            buttonText: "Reset"
            showDivider: false
            onClicked: ControlCenterLayoutService.resetToDefault()
        }
    }

    SectionLabel { text: "Preview" }

    // Same size and padding as the real Control Center panel (16 px around the grid).
    Rectangle {
        id: previewPanel

        readonly property real panelPadding: 16

        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: grid.implicitWidth + panelPadding * 2
        Layout.preferredHeight: grid.implicitHeight + panelPadding * 2

        radius: ShellState.islandCornerRadius
        color: Colors.bg
        border.width: 1
        border.color: Colors.border

        ControlGrid {
            id: grid
            x: previewPanel.panelPadding
            y: previewPanel.panelPadding
            width: implicitWidth
            height: implicitHeight
            editMode: true

            // Where a control dragged in from "Add a control" would land.
            Rectangle {
                visible: root.dropPlan !== null
                z: 25
                x: root.dropPlan ? root.dropPlan.col * grid.stepX : 0
                y: root.dropPlan ? root.dropPlan.row * grid.stepY : 0
                width: root.dropPlan ? root.dropPlan.c * grid.cellW + (root.dropPlan.c - 1) * grid.gap : 0
                height: root.dropPlan ? root.dropPlan.r * grid.cellH + (root.dropPlan.r - 1) * grid.gap : 0
                radius: ShellState.islandCornerRadius
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
        text: "Drag a tile to move it and the corner dot to resize it. Drag a tile out of the preview to remove it. With a tile selected, the arrow keys move it and [ and ] change its size."
        color: Colors.subtext
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeXs
    }

    SectionLabel { text: "Add a control" }

    GroupCard {
        InfoRow {
            visible: root.unplaced.length === 0
            label: "Every control is already on the grid"
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

                    readonly property var size: ControlCenterLayoutService.defaultSizeForType(addChip.modelData)

                    typeId: addChip.modelData
                    label: (ControlCenterLayoutService.typeDisplayNames[addChip.modelData] || addChip.modelData)
                           + "  " + addChip.size.c + " × " + addChip.size.r
                    controller: dnd
                    onActivated: ControlCenterLayoutService.addTile(addChip.modelData)
                }
            }
        }
    }

    // Slides open while a tile is selected in the preview.
    Reveal {
        shown: root.selectedTile !== null

        SectionLabel { text: "Selected tile" }

        GroupCard {
            InfoRow {
                label: root.selectedTile
                    ? (ControlCenterLayoutService.typeDisplayNames[root.selectedTile.type] || root.selectedTile.type)
                    : ""
                value: root.selectedTile ? root.selectedTile.colSpan + " × " + root.selectedTile.rowSpan : ""
            }

            Flow {
                Layout.fillWidth: true
                Layout.leftMargin: Dimens.paddingMedium
                Layout.rightMargin: Dimens.paddingMedium
                Layout.topMargin: Dimens.paddingSmall
                Layout.bottomMargin: Dimens.paddingMedium
                spacing: Dimens.spacingSmall

                Repeater {
                    model: root.selectedSizes

                    delegate: Rectangle {
                        id: sizeChip
                        required property var modelData

                        readonly property bool active: root.selectedTile !== null
                            && root.selectedTile.colSpan === sizeChip.modelData.c
                            && root.selectedTile.rowSpan === sizeChip.modelData.r

                        implicitWidth: sizeChipLabel.implicitWidth + Dimens.paddingLarge
                        implicitHeight: 30
                        radius: Dimens.radiusChip
                        color: sizeChip.active ? Colors.accent : Colors.elevatedBg

                        Behavior on color {
                            ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                        }

                        Text {
                            id: sizeChipLabel
                            anchors.centerIn: parent
                            text: sizeChip.modelData.c + " × " + sizeChip.modelData.r
                            color: sizeChip.active ? Colors.mainBgMica : Colors.fg
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeSm
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                ControlCenterLayoutService.pushUndoSnapshot()
                                ControlCenterLayoutService.resizeTile(grid.selectedTileId,
                                                                      sizeChip.modelData.c, sizeChip.modelData.r)
                            }
                        }
                    }
                }
            }

            ButtonRow {
                label: "Remove from the grid"
                description: "You can add it back above"
                buttonText: "Remove"
                showDivider: false
                onClicked: {
                    const id = grid.selectedTileId
                    grid.selectedTileId = ""
                    ControlCenterLayoutService.removeTile(id)
                }
            }
        }
    }
}
