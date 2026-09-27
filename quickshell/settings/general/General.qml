// settings/general/General.qml — merge of Clock.qml + System.qml's Startup Applications group
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
    property string newAppCommand: ""

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

        SettingsGroup {
            title: "Startup Applications"
            description: "Manage applications that launch automatically at login"
            icon: "rocket_launch"
            expanded: false

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 36
                radius: Dimens.radiusSmall
                color: Colors.subBgMica
                border.color: Colors.border
                border.width: 1

                TextInput {
                    id: newAppInput
                    anchors.fill: parent
                    anchors.margins: 8
                    color: Colors.fg
                    font.family: Fonts.mono
                    font.pixelSize: Dimens.fontSizeSm
                    onTextChanged: root.newAppCommand = text
                    onAccepted: {
                        if (root.newAppCommand.trim().length > 0) {
                            AutostartService.addApp(root.newAppCommand.trim())
                            text = ""
                        }
                    }
                    Text {
                        visible: parent.text.length === 0
                        text: "Command to launch, e.g. spotify"
                        color: Colors.subtext
                        font: parent.font
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: Dimens.spacingSmall

                Item { Layout.fillWidth: true }

                SettingsButton {
                    primary: true
                    text: "Add"
                    enabled: root.newAppCommand.trim().length > 0
                    onClicked: {
                        AutostartService.addApp(root.newAppCommand.trim())
                        newAppInput.text = ""
                    }
                }
            }

            SettingsSectionLabel { label: "Starting Apps" }

            Repeater {
                model: AutostartService.apps
                delegate: RowLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.bottomMargin: Dimens.spacingSmall

                    Text {
                        text: modelData.command
                        color: Colors.fg
                        font.family: Fonts.mono
                        font.pixelSize: Dimens.fontSizeSm
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    SettingsButton {
                        text: "Remove"
                        onClicked: AutostartService.removeApp(modelData.command)
                    }
                }
            }
        }
    }
}