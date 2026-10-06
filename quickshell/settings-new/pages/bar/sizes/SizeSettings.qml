// pages/bar/sizes/SizeSettings.qml — Bar & Island > Sizes.
// Every control binds straight to ShellState. The `|| default` fallbacks are carried over from the
// old Bar.qml; they only show a sensible slider position before a value has been saved.
import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../../services"
import "../../../../styles"

PageScroll {
    id: root

    SectionLabel { text: "Island" }

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

    SectionLabel { text: "App launcher" }

    GroupCard {
        SliderRow {
            label: "Width"
            from: 300; to: 800; stepSize: 10
            value: ShellState.launcherWidth || 420
            unit: " px"
            onMoved: (val) => ShellState.launcherWidth = val
        }

        SliderRow {
            label: "Visible rows"
            from: 3; to: 12; stepSize: 1
            value: ShellState.launcherMaxRows || 7
            unit: " rows"
            onMoved: (val) => ShellState.launcherMaxRows = val
            showDivider: false
        }
    }

    SectionLabel { text: "Clipboard" }

    GroupCard {
        SliderRow {
            label: "Width"
            from: 300; to: 800; stepSize: 10
            value: ShellState.clipboardWidth || 420
            unit: " px"
            onMoved: (val) => ShellState.clipboardWidth = val
        }

        SliderRow {
            label: "Visible rows"
            from: 3; to: 12; stepSize: 1
            value: ShellState.clipboardMaxRows || 6
            unit: " rows"
            onMoved: (val) => ShellState.clipboardMaxRows = val
            showDivider: false
        }
    }

    SectionLabel { text: "Control Center" }

    GroupCard {
        SliderRow {
            label: "Width"
            from: 400; to: 900; stepSize: 10
            value: ShellState.controlCenterWidth || 580
            unit: " px"
            onMoved: (val) => ShellState.controlCenterWidth = val
        }

        SliderRow {
            label: "Height"
            from: 300; to: 700; stepSize: 10
            value: ShellState.controlCenterHeight || 400
            unit: " px"
            onMoved: (val) => ShellState.controlCenterHeight = val
            showDivider: false
        }
    }

    SectionLabel { text: "Notification center" }

    GroupCard {
        SliderRow {
            label: "Width"
            from: 280; to: 600; stepSize: 10
            value: ShellState.notificationCenterWidth || 360
            unit: " px"
            onMoved: (val) => ShellState.notificationCenterWidth = val
        }

        SliderRow {
            label: "Maximum height"
            from: 250; to: 800; stepSize: 10
            value: ShellState.notificationCenterMaxHeight || 480
            unit: " px"
            onMoved: (val) => ShellState.notificationCenterMaxHeight = val
            showDivider: false
        }
    }

    SectionLabel { text: "Power menu" }

    GroupCard {
        SliderRow {
            label: "Width"
            from: 250; to: 600; stepSize: 10
            value: ShellState.powerMenuWidth || 320
            unit: " px"
            onMoved: (val) => ShellState.powerMenuWidth = val
        }

        SliderRow {
            label: "Height"
            from: 60; to: 120; stepSize: 2
            value: ShellState.powerMenuHeight || 76
            unit: " px"
            onMoved: (val) => ShellState.powerMenuHeight = val
            showDivider: false
        }
    }

    SectionLabel { text: "Status panel" }

    GroupCard {
        SliderRow {
            label: "Width"
            from: 400; to: 800; stepSize: 10
            value: ShellState.statusPanelWidth || 520
            unit: " px"
            onMoved: (val) => ShellState.statusPanelWidth = val
        }

        SliderRow {
            label: "Height"
            from: 140; to: 300; stepSize: 5
            value: ShellState.statusPanelHeight || 172
            unit: " px"
            onMoved: (val) => ShellState.statusPanelHeight = val
            showDivider: false
        }
    }

    SectionLabel { text: "Timer" }

    GroupCard {
        SliderRow {
            label: "Width"
            from: 240; to: 500; stepSize: 10
            value: ShellState.timerWidth || 320
            unit: " px"
            onMoved: (val) => ShellState.timerWidth = val
        }

        SliderRow {
            label: "Height"
            from: 140; to: 300; stepSize: 5
            value: ShellState.timerHeight || 180
            unit: " px"
            onMoved: (val) => ShellState.timerHeight = val
            showDivider: false
        }
    }
}