// features/bar/BarSettings.qml — the Bar & Island menu itself: how the island looks.
// Style, the clock items and their order, size and shape sit here. Workspaces, Clock,
// Music visualizer and Behavior open from the list at the bottom.
// Everything here is bound to ShellState or ClockLayoutService.
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../settings/components"
import "."
import "../../core/shell"
import "../../core/styles"

PageScroll {
    id: root

    // Single source of truth stays ShellState.islandNotchMode (bool); this is only its label.
    readonly property string barStyle: ShellState.islandNotchMode ? "Notch" : "Island"
    readonly property var unplaced: ClockLayoutService.unplacedTypes()

    SystemClock {
        id: previewClock
        enabled: root.visible
        precision: ShellState.clockShowSeconds ? SystemClock.Seconds : SystemClock.Minutes
    }

    function chipText(type) {
        switch (type) {
            case "date": return Qt.formatDateTime(previewClock.date, ShellState.clockDateFormat)
            case "time": return Qt.formatDateTime(previewClock.date, ShellState.clockTimeFormat)
            default: return ClockLayoutService.typeDisplayNames[type] || type
        }
    }

    SectionLabel { text: "Style" }

    GroupCard {
        SegmentRow {
            label: "Bar style"
            description: root.barStyle === "Notch"
                ? "Attached to the top edge like a display notch"
                : "A floating island with a gap above it"
            options: ["Island", "Notch"]
            selectedValue: root.barStyle
            onOptionSelected: (name) => ShellState.islandNotchMode = (name === "Notch")
        }

        Reveal {
            shown: root.barStyle === "Island"

            SliderRow {
                label: "Border width"
                description: "Outline around the island"
                from: 0; to: 4; stepSize: 1
                value: ShellState.islandBorderWidth
                unit: " px"
                onMoved: (val) => ShellState.islandBorderWidth = val
            }

            SliderRow {
                label: "Top margin"
                description: "Gap between the screen edge and the island"
                from: 0; to: 40; stepSize: 1
                value: ShellState.islandTopMargin
                unit: " px"
                onMoved: (val) => ShellState.islandTopMargin = val
                showDivider: false
            }
        }

        Reveal {
            shown: root.barStyle === "Notch"

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

    SectionLabel { text: "Layout" }

    GroupCard {
        // One chip per item on the island, in bar order. Drag a chip sideways to move it.
        // An item that is not in this row is off; add it back below.
        Item {
            id: strip
            Layout.fillWidth: true
            implicitHeight: 72

            property string selectedId: ""
            readonly property bool hasSelection: strip.selectedId !== ""
                && ClockLayoutService.indexForId(strip.selectedId) >= 0
            readonly property int count: ClockLayoutService.layoutModel.count
            readonly property real gap: Dimens.spacingSmall
            readonly property real pad: Dimens.paddingMedium
            readonly property real chipHeight: 40
            readonly property real chipMaxWidth: 120
            readonly property real slotWidth: count > 0
                ? Math.min(chipMaxWidth, (width - pad * 2 - gap * (count - 1)) / count)
                : 0

            Keys.onPressed: (event) => {
                if (strip.selectedId === "") return
                if (event.key === Qt.Key_Left) {
                    ClockLayoutService.moveItemBy(strip.selectedId, -1)
                    event.accepted = true
                } else if (event.key === Qt.Key_Right) {
                    ClockLayoutService.moveItemBy(strip.selectedId, 1)
                    event.accepted = true
                }
            }

            Repeater {
                model: ClockLayoutService.layoutModel

                delegate: Rectangle {
                    id: chip
                    required property int index
                    required property string itemId

                    readonly property bool selected: strip.selectedId === chip.itemId
                    readonly property real slotX: strip.pad + chip.index * (strip.slotWidth + strip.gap)
                    property real dragOffset: 0

                    x: chip.slotX + chip.dragOffset
                    y: (strip.height - height) / 2
                    width: strip.slotWidth
                    height: strip.chipHeight
                    radius: Dimens.radiusChip
                    color: chip.selected ? Colors.accent : Colors.elevatedBg
                    opacity: dragHandler.active ? 0.85 : 1.0
                    z: dragHandler.active ? 10 : 0

                    // Only the settle after a drop animates; the drag itself follows the pointer.
                    Behavior on x {
                        enabled: !dragHandler.active
                        NumberAnimation {
                            duration: ShellState.motionDuration(Motion.glideMs)
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on color {
                        ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                    }

                    Text {
                        anchors.fill: parent
                        anchors.margins: Dimens.paddingSmall
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        text: root.chipText(chip.itemId)
                        color: chip.selected ? Colors.mainBgMica : Colors.fg
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeSm
                    }

                    TapHandler {
                        onTapped: {
                            strip.selectedId = chip.itemId
                            strip.forceActiveFocus()
                        }
                    }

                    // target: null + scene coordinates, so the offset is not thrown off
                    // by the chip moving under the pointer (the feedback loop you hit in
                    // the Control Center resize handle).
                    DragHandler {
                        id: dragHandler
                        target: null

                        onCentroidChanged: {
                            if (!active) return
                            const raw = centroid.scenePosition.x - centroid.scenePressPosition.x
                            const lo = strip.pad - chip.slotX
                            const hi = strip.width - strip.pad - chip.width - chip.slotX
                            chip.dragOffset = Math.max(lo, Math.min(hi, raw))
                        }

                        onActiveChanged: {
                            if (active) {
                                strip.selectedId = chip.itemId
                                strip.forceActiveFocus()
                            } else {
                                const step = strip.slotWidth + strip.gap
                                const target = Math.max(0, Math.min(strip.count - 1,
                                    Math.round((chip.x - strip.pad) / step)))
                                if (target !== chip.index) ClockLayoutService.moveItem(chip.index, target)
                                chip.dragOffset = 0
                            }
                        }
                    }
                }
            }
        }
    }

    Text {
        Layout.fillWidth: true
        leftPadding: Dimens.paddingSmall
        wrapMode: Text.WordWrap
        text: "Drag an item to move it. Click one to select it, then use the left and right arrow keys or the buttons below. Some items only appear when they have something to show, like the visualizer while music plays."
        color: Colors.subtext
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeXs
    }

    // Slides open while an item is selected in the row above.
    Reveal {
        shown: strip.hasSelection

        SectionLabel { text: "Selected item" }

        GroupCard {
            InfoRow {
                label: ClockLayoutService.typeDisplayNames[strip.selectedId] || ""
                value: "Position " + (ClockLayoutService.indexForId(strip.selectedId) + 1) + " of " + strip.count
            }

            ButtonRow {
                label: "Move left"
                buttonText: "Left"
                enabled: ClockLayoutService.indexForId(strip.selectedId) > 0
                onClicked: ClockLayoutService.moveItemBy(strip.selectedId, -1)
            }

            ButtonRow {
                label: "Move right"
                buttonText: "Right"
                enabled: ClockLayoutService.indexForId(strip.selectedId) < strip.count - 1
                onClicked: ClockLayoutService.moveItemBy(strip.selectedId, 1)
            }

            ButtonRow {
                label: "Remove from the island"
                description: ClockLayoutService.canRemove(strip.selectedId)
                    ? "You can add it back below"
                    : "Time always stays on the island"
                buttonText: "Remove"
                enabled: ClockLayoutService.canRemove(strip.selectedId)
                showDivider: false
                onClicked: {
                    const id = strip.selectedId
                    strip.selectedId = ""
                    ClockLayoutService.removeItem(id)
                }
            }
        }
    }

    SectionLabel { text: "Add an item" }

    GroupCard {
        InfoRow {
            visible: root.unplaced.length === 0
            label: "Every item is already on the island"
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
                        text: ClockLayoutService.typeDisplayNames[addChip.modelData] || addChip.modelData
                        color: addMouse.containsMouse ? Colors.mainBgMica : Colors.fg
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeSm
                    }

                    MouseArea {
                        id: addMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ClockLayoutService.addItem(addChip.modelData)
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
            enabled: ClockLayoutService.undoStack.length > 0
            onClicked: ClockLayoutService.undo()
        }

        ButtonRow {
            label: "Reset layout"
            description: "Back to the default items and order"
            buttonText: "Reset"
            showDivider: false
            onClicked: ClockLayoutService.resetToDefault()
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
            showDivider: !ShellState.radiusUniversal
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
                showDivider: false
            }
        }
    }

    SectionLabel { text: "Parts of the bar" }

    ViewList {}
}
