// pages/controlcenter/ControlCenterSettings.qml — Control Center.
// Edit the tile grid: columns, layout tools, a live preview you can drag and resize,
// the selected tile's size, and the controls that are not placed yet.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"
import "../../../components/control-center"

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
        }
    }

    Text {
        Layout.fillWidth: true
        leftPadding: Dimens.paddingSmall
        wrapMode: Text.WordWrap
        text: "Drag a tile to move it and the corner dot to resize it. With a tile selected, the arrow keys move it and [ and ] change its size."
        color: Colors.subtext
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeXs
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
                description: "You can add it back below"
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

                delegate: Rectangle {
                    id: addChip
                    required property string modelData

                    readonly property var size: ControlCenterLayoutService.defaultSizeForType(addChip.modelData)

                    implicitWidth: addChipLabel.implicitWidth + Dimens.paddingLarge
                    implicitHeight: 34
                    radius: Dimens.radiusChip
                    color: addMouse.containsMouse ? Colors.accent : Colors.elevatedBg

                    Behavior on color {
                        ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
                    }

                    Text {
                        id: addChipLabel
                        anchors.centerIn: parent
                        text: (ControlCenterLayoutService.typeDisplayNames[addChip.modelData] || addChip.modelData)
                              + "  " + addChip.size.c + " × " + addChip.size.r
                        color: addMouse.containsMouse ? Colors.mainBgMica : Colors.fg
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeSm
                    }

                    MouseArea {
                        id: addMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ControlCenterLayoutService.addTile(addChip.modelData)
                    }
                }
            }
        }
    }
}