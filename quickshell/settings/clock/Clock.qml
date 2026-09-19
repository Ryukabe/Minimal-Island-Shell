// settings/clock/Clock.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../services"
import "../../styles"
import "../common"

Item {
    id: root

    readonly property var dateLabels: ["Off", "Short", "Long"]
    readonly property var ampmLabels: ["AM", "am"]

    // Preview only ticks while this page is actually visible.
    SystemClock {
        id: previewClock
        enabled: root.visible
        precision: ShellState.clockShowSeconds ? SystemClock.Seconds : SystemClock.Minutes
    }

    SettingsScrollView {

        SettingsGroup {
            title: "Preview"
            description: "Uses the same format as the bar clock"
            icon: "visibility"
            expanded: true

            Item {
                Layout.fillWidth: true
                implicitHeight: 56

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

        SettingsGroup {
            title: "Time"
            description: "Hour format, seconds, and AM/PM style"
            icon: "schedule"
            expanded: true

            SettingsToggleRow {
                label: "Use 24-Hour Clock Format"
                checked: ShellState.clockUse24Hour
                onToggled: (val) => ShellState.clockUse24Hour = val
            }

            SettingsToggleRow {
                label: "Show Seconds"
                checked: ShellState.clockShowSeconds
                onToggled: (val) => ShellState.clockShowSeconds = val
            }

            SettingsToggleRow {
                label: "Leading Zero on Hour"
                checked: ShellState.clockLeadingZero
                showDivider: !ShellState.clockUse24Hour
                onToggled: (val) => ShellState.clockLeadingZero = val
            }

            SettingsSegmentedRow {
                visible: !ShellState.clockUse24Hour
                label: "AM/PM Style"
                options: root.ampmLabels
                selectedValue: ShellState.clockLowercaseAmPm ? "am" : "AM"
                onOptionSelected: (value) => ShellState.clockLowercaseAmPm = (value === "am")
            }
        }

        SettingsGroup {
            title: "Date"
            description: "Show the date next to the time"
            icon: "calendar_month"
            expanded: true

            SettingsSegmentedRow {
                label: "Show Date"
                options: root.dateLabels
                selectedValue: root.dateLabels[ShellState.clockDateStyle]
                onOptionSelected: (value) => ShellState.clockDateStyle = root.dateLabels.indexOf(value)
            }
        }

        SettingsGroup {
            title: "Bar Extras"
            description: "Indicators beside the time"
            icon: "tune"
            expanded: true

            SettingsToggleRow {
                label: "Music Visualizer"
                checked: ShellState.clockShowVisualizer
                onToggled: (val) => ShellState.clockShowVisualizer = val
            }

            SettingsToggleRow {
                label: "Timer Icon"
                checked: ShellState.clockShowTimerIcon
                onToggled: (val) => ShellState.clockShowTimerIcon = val
            }

            SettingsToggleRow {
                label: "Recording Indicator (Clock)"
                checked: ShellState.clockShowRecordingIndicator
                onToggled: (val) => ShellState.clockShowRecordingIndicator = val
            }

            SettingsToggleRow {
                label: "Recording Indicator (Timer Toast)"
                checked: ShellState.timerToastShowRecordingIndicator
                showDivider: false
                onToggled: (val) => ShellState.timerToastShowRecordingIndicator = val
            }
        }
    }
}