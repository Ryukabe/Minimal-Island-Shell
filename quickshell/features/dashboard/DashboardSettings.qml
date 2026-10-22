// features/dashboard/DashboardSettings.qml — Dashboard: grid columns, the components you can add,
// and a live preview where components are moved and resized. The panel sizes itself from the
// components (no width / height sliders). Per-component options live on their own pages.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "."
import "../../core/shell"
import "../../core/styles"

PageScroll {
    id: root

    readonly property var columnOptions: ["8", "10", "12", "14", "16"]
    readonly property var selectedTile: DashboardLayoutService.tileInfo(grid.selectedTileId)
    readonly property var unplaced: DashboardLayoutService.unplacedTypes()

    SectionLabel { text: "Grid" }

    GroupCard {
        SegmentRow {
            label: "Columns"
            options: root.columnOptions
            selectedValue: String(DashboardLayoutService.columns)
            onOptionSelected: (name) => DashboardLayoutService.setColumns(parseInt(name))
            showDivider: false
        }
    }

    SectionLabel { text: "Components" }

    // Components that are not on the Dashboard. Tap one to add it; remove one with the
    // button under "Selected component" below.
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

                delegate: Rectangle {
                    id: addChip
                    required property string modelData

                    readonly property var size: DashboardLayoutService.defaultSizeForType(addChip.modelData)

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
                        text: (DashboardLayoutService.typeDisplayNames[addChip.modelData] || addChip.modelData)
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
                        onClicked: DashboardLayoutService.addTile(addChip.modelData)
                    }
                }
            }
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
            description: "Back to the default components and a 12-column grid"
            buttonText: "Reset"
            showDivider: false
            onClicked: DashboardLayoutService.resetToDefault()
        }
    }

    SectionLabel { text: "Layout" }

    // Same size and padding as the real Dashboard panel, so the preview and the panel always match.
    Rectangle {
        id: previewPanel

        readonly property real pad: Dimens.paddingMedium

        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: grid.implicitWidth + pad * 2
        Layout.preferredHeight: grid.implicitHeight + pad * 2

        radius: Dimens.radiusIsland
        color: Colors.mainBgMica
        border.width: 1
        border.color: Colors.border

        DashboardGrid {
            id: grid
            x: previewPanel.pad
            y: previewPanel.pad
            width: implicitWidth
            height: implicitHeight
            editMode: true
        }
    }

    Text {
        Layout.fillWidth: true
        leftPadding: Dimens.paddingSmall
        wrapMode: Text.WordWrap
        text: "Click a component to select it. Drag it to move it and use the four corner dots to resize it. With one selected, the arrow keys move it and Shift + arrows resize it. Components in the way are pushed aside, and the Dashboard grows or shrinks to fit."
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