// pages/bar/clock/ClockSettings.qml — Bar & Island > Clock. Every control binds to ShellState.
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../components"
import "../../../../services"
import "../../../../styles"

PageScroll {
    id: root

    readonly property var dateLabels: ["Off", "Short", "Long"]
    readonly property var ampmLabels: ["AM", "am"]

    SystemClock {
        id: previewClock
        enabled: root.visible
        precision: ShellState.clockShowSeconds ? SystemClock.Seconds : SystemClock.Minutes
    }

    SectionLabel { text: "Preview" }

    GroupCard {
        Item {
            Layout.fillWidth: true
            implicitHeight: 64

            Row {
                anchors.centerIn: parent
                spacing: 14

                Text {
                    visible: ShellState.clockDateStyle > 0
                    text: Qt.formatDateTime(previewClock.date, ShellState.clockDateFormat)
                    color: Colors.fgMuted
                    font.family: Fonts.display
                    font.pixelSize: Dimens.fontSizeXl
                    font.weight: 500
                }

                Text {
                    text: Qt.formatDateTime(previewClock.date, ShellState.clockTimeFormat)
                    color: Colors.fg
                    font.family: Fonts.display
                    font.pixelSize: Dimens.fontSizeXl
                    font.weight: 700
                }
            }
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
}