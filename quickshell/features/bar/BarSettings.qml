// features/bar/BarSettings.qml — the Bar & Island menu itself: how the island looks.
// Style, the clock items and their order, and size sit here. Workspaces, Clock,
// Music visualizer and Behavior open from the list at the bottom.
// Everything here is bound to ShellState or ClockLayoutService.
pragma ComponentBehavior: Bound

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

    // ---- Drag a catalogue chip into the row (tap still adds it at the end) ----
    CatalogDrag {
        id: dnd
        flickable: root.flickable
        viewport: root
        onDropped: (type, pos) => root.handleDrop(type, pos)
    }

    // Where a dragged chip would be inserted (0 = first), or -1 when the pointer is not over the row.
    function dropIndexAt(scenePoint) {
        const p = strip.mapFromItem(null, scenePoint.x, scenePoint.y)
        if (p.x < -12 || p.x > strip.width + 12 || p.y < -12 || p.y > strip.height + 12) return -1
        const step = strip.slotWidth + strip.gap
        if (step <= 0) return 0
        return Math.max(0, Math.min(strip.count, Math.ceil((p.x - strip.pad - strip.slotWidth / 2) / step)))
    }

    readonly property int dropIndex: {
        dnd.tick
        return dnd.active ? root.dropIndexAt(dnd.scenePos) : -1
    }

    function handleDrop(type, pos) {
        const idx = root.dropIndexAt(pos)
        if (idx < 0) return
        ClockLayoutService.addItemAt(type, idx)
        strip.selectedId = type
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
                label: "Notch side radius"
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
            readonly property int count: ClockLayoutService.layoutModel.count
            readonly property real gap: Dimens.spacingSmall
            readonly property real pad: Dimens.paddingMedium
            readonly property real chipHeight: 40
            readonly property real chipMaxWidth: 120
            readonly property real slotWidth: count > 0
                ? Math.min(chipMaxWidth, (width - pad * 2 - gap * (count - 1)) / count)
                : 0

            // True when a scene point is well outside the row: letting go there removes the item.
            function isOutside(scenePoint) {
                const p = strip.mapFromItem(null, scenePoint.x, scenePoint.y)
                return p.x < -28 || p.x > strip.width + 28 || p.y < -28 || p.y > strip.height + 28
            }

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

            // Where a chip dragged in from "Add an item" would land.
            Rectangle {
                visible: root.dropIndex >= 0
                z: 5
                width: 3
                radius: 1.5
                height: strip.chipHeight + 8
                color: Colors.accent
                x: strip.pad + root.dropIndex * (strip.slotWidth + strip.gap) - strip.gap / 2 - width / 2
                y: (strip.height - height) / 2
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
                    property real dragOffsetY: 0
                    // True while dragged away from the row: letting go removes it.
                    property bool dragOutside: false

                    x: chip.slotX + chip.dragOffset
                    y: (strip.height - height) / 2 + chip.dragOffsetY
                    width: strip.slotWidth
                    height: strip.chipHeight
                    radius: Dimens.radiusChip
                    color: chip.selected ? Colors.accent : Colors.elevatedBg
                    opacity: dragHandler.active ? (chip.dragOutside ? 0.35 : 0.85) : 1.0
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
                            chip.dragOffsetY = centroid.scenePosition.y - centroid.scenePressPosition.y
                            // Time stays on the island, so it never counts as "about to be removed".
                            chip.dragOutside = ClockLayoutService.canRemove(chip.itemId)
                                && strip.isOutside(centroid.scenePosition)
                        }

                        onActiveChanged: {
                            if (active) {
                                strip.selectedId = chip.itemId
                                strip.forceActiveFocus()
                            } else if (chip.dragOutside) {
                                const removedId = chip.itemId
                                chip.dragOutside = false
                                chip.dragOffset = 0
                                chip.dragOffsetY = 0
                                if (strip.selectedId === removedId) strip.selectedId = ""
                                // Deferred: removing the item destroys this chip while its handler is still running.
                                Qt.callLater(function () { ClockLayoutService.removeItem(removedId) })
                            } else {
                                const step = strip.slotWidth + strip.gap
                                const target = Math.max(0, Math.min(strip.count - 1,
                                    Math.round((chip.x - strip.pad) / step)))
                                if (target !== chip.index) ClockLayoutService.moveItem(chip.index, target)
                                chip.dragOffset = 0
                                chip.dragOffsetY = 0
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
        text: "Drag an item to move it, or drag it away from the row to remove it. Drag one from Add an item into the row, or just tap it, to add it. Some items only appear when they have something to show, like the visualizer while music plays."
        color: Colors.subtext
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeXs
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

                delegate: CatalogChip {
                    required property string modelData
                    typeId: modelData
                    label: ClockLayoutService.typeDisplayNames[modelData] || modelData
                    controller: dnd
                    onActivated: ClockLayoutService.addItem(modelData)
                }
            }
        }
    }

    SectionLabel { text: "Layout tools" }

    GroupCard {
        /*ButtonRow {
            label: "Undo"
            description: "Step back one change"
            buttonText: "Undo"
            enabled: ClockLayoutService.undoStack.length > 0
            onClicked: ClockLayoutService.undo()
        }*/

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

    SectionLabel { text: "Parts of the bar" }

    ViewList {}
}
