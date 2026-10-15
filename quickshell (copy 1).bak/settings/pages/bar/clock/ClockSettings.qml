// pages/bar/clock/ClockSettings.qml — Bar & Island > Clock. Every control binds to ShellState
// or ClockLayoutService (item order).
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../components"
import "../../../../services"
import "../../../../styles"
import "../../../../components/bar" as Bar

PageScroll {
    id: root

    readonly property var dateLabels: ["Off", "Short", "Long"]
    readonly property var ampmLabels: ["AM", "am"]
    readonly property var colorLabels: ["Accent", "Text", "Muted"]

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

    SectionLabel { text: "Layout" }

    GroupCard {
        // One chip per clock item, in bar order. Drag a chip sideways to move it.
        // Dimmed chips are switched off below, so they do not show on the bar.
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

                    readonly property bool shownOnBar: ClockLayoutService.isEnabled(chip.itemId)
                    readonly property bool selected: strip.selectedId === chip.itemId
                    readonly property real slotX: strip.pad + chip.index * (strip.slotWidth + strip.gap)
                    property real dragOffset: 0

                    x: chip.slotX + chip.dragOffset
                    y: (strip.height - height) / 2
                    width: strip.slotWidth
                    height: strip.chipHeight
                    radius: Dimens.radiusChip
                    color: chip.selected ? Colors.accent : Colors.elevatedBg
                    opacity: dragHandler.active ? 0.85 : (chip.shownOnBar ? 1.0 : 0.45)
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
        text: "Drag an item to move it. Click one to select it, then use the left and right arrow keys or the buttons below. Dimmed items are switched off further down."
        color: Colors.subtext
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeXs
    }

    Reveal {
        shown: strip.selectedId !== ""

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
                showDivider: false
                onClicked: ClockLayoutService.moveItemBy(strip.selectedId, 1)
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
            label: "Reset order"
            description: "Back to the default order"
            buttonText: "Reset"
            showDivider: false
            onClicked: ClockLayoutService.resetToDefault()
        }
    }

    SectionLabel { text: "Time" }

    GroupCard {
        ToggleRow {
            label: "24-hour clock"
            checked: ShellState.clockUse24Hour
            onToggled: (val) => ShellState.clockUse24Hour = val
        }

        ToggleRow {
            label: "Show seconds"
            checked: ShellState.clockShowSeconds
            onToggled: (val) => ShellState.clockShowSeconds = val
        }

        ToggleRow {
            label: "Leading zero on hour"
            checked: ShellState.clockLeadingZero
            onToggled: (val) => ShellState.clockLeadingZero = val
            showDivider: !ShellState.clockUse24Hour
        }

        SegmentRow {
            visible: !ShellState.clockUse24Hour
            label: "AM/PM style"
            options: root.ampmLabels
            selectedValue: ShellState.clockLowercaseAmPm ? "am" : "AM"
            onOptionSelected: (name) => ShellState.clockLowercaseAmPm = (name === "am")
            showDivider: false
        }
    }

    SectionLabel { text: "Date" }

    GroupCard {
        SegmentRow {
            label: "Show date"
            options: root.dateLabels
            selectedValue: root.dateLabels[ShellState.clockDateStyle]
            onOptionSelected: (name) => ShellState.clockDateStyle = root.dateLabels.indexOf(name)
            showDivider: false
        }
    }

    SectionLabel { text: "Bar indicators" }

    GroupCard {
        ToggleRow {
            label: "Workspaces"
            checked: ShellState.clockShowWorkspaces
            onToggled: (val) => ShellState.clockShowWorkspaces = val
        }

        ToggleRow {
            label: "Music visualizer"
            checked: ShellState.clockShowVisualizer
            onToggled: (val) => ShellState.clockShowVisualizer = val
        }

        ToggleRow {
            label: "Timer icon"
            checked: ShellState.clockShowTimerIcon
            onToggled: (val) => ShellState.clockShowTimerIcon = val
        }

        ToggleRow {
            label: "Mic and camera indicator"
            description: "Green dot for camera, yellow for microphone"
            checked: ShellState.clockShowPrivacyIndicator
            onToggled: (val) => ShellState.clockShowPrivacyIndicator = val
        }

        ToggleRow {
            label: "Recording indicator (clock)"
            checked: ShellState.clockShowRecordingIndicator
            onToggled: (val) => ShellState.clockShowRecordingIndicator = val
        }

        ToggleRow {
            label: "Recording indicator (timer toast)"
            checked: ShellState.timerToastShowRecordingIndicator
            onToggled: (val) => ShellState.timerToastShowRecordingIndicator = val
            showDivider: false
        }
    }

    SectionLabel { text: "Visualizer" }

    GroupCard {
        // Always animating here. On the bar it only shows while audio is playing.
        Item {
            Layout.fillWidth: true
            implicitHeight: 64

            Bar.ClockVisualizer {
                anchors.centerIn: parent
                running: root.visible
            }
        }

        SliderRow {
            label: "Bars"
            from: 2; to: 8; stepSize: 1
            value: ShellState.clockVisualizerBars
            onMoved: (val) => ShellState.clockVisualizerBars = val
        }

        SliderRow {
            label: "Bar width"
            from: 2; to: 6; stepSize: 1
            value: ShellState.clockVisualizerBarWidth
            unit: " px"
            onMoved: (val) => ShellState.clockVisualizerBarWidth = val
        }

        SliderRow {
            label: "Gap"
            description: "Space between the bars"
            from: 1; to: 8; stepSize: 1
            value: ShellState.clockVisualizerGap
            unit: " px"
            onMoved: (val) => ShellState.clockVisualizerGap = val
        }

        SliderRow {
            label: "Height"
            description: "How tall the bars reach"
            from: 6; to: 20; stepSize: 1
            value: ShellState.clockVisualizerMaxHeight
            unit: " px"
            onMoved: (val) => ShellState.clockVisualizerMaxHeight = val
        }

        SliderRow {
            label: "Speed"
            description: "Looping animation only. It does not follow the music"
            from: 50; to: 200; stepSize: 10
            value: ShellState.clockVisualizerSpeedPercent
            unit: " %"
            onMoved: (val) => ShellState.clockVisualizerSpeedPercent = val
        }

        SegmentRow {
            label: "Color"
            options: root.colorLabels
            selectedValue: ShellState.clockVisualizerColor
            onOptionSelected: (name) => ShellState.clockVisualizerColor = name
            showDivider: false
        }
    }
}