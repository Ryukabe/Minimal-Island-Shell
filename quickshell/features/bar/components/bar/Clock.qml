import QtQuick
import QtQuick.Layouts
import Quickshell
import "../.."
import "../../../lockscreen"
import "../../../recording"
import "../../../sound"
import "../../../timer"
import "../../../../core/state"
import "../../../../core/styles"

Item {
    id: root

    implicitWidth: Math.max(140, layout.implicitWidth + 32)
    implicitHeight: Math.max(36, layout.implicitHeight + 8)

    // Only ticks every second while the user has "Show Seconds" on.
    SystemClock {
        id: clock
        precision: ShellState.clockShowSeconds ? SystemClock.Seconds : SystemClock.Minutes
    }

    // Wall time at the picked location (system time when none is picked).
    readonly property var shownDate: LocationService.localize(clock.date)

    // Dots fade out on their own; their slot stays in the row until the fade ends.
    readonly property bool recordingActive: RecordingService.enabled && ShellState.clockShowRecordingIndicator
    property bool recordingFading: false

    onRecordingActiveChanged: {
        if (recordingActive) {
            recordingFading = false
            recordingFadeTimer.stop()
        } else {
            recordingFading = true
            recordingFadeTimer.restart()
        }
    }

    Timer {
        id: recordingFadeTimer
        interval: Motion.fadeMs + 40
        repeat: false
        onTriggered: root.recordingFading = false
    }

    readonly property bool privacyActive: ShellState.clockShowPrivacyIndicator && PrivacyService.active
    property bool privacyFading: false

    onPrivacyActiveChanged: {
        if (privacyActive) {
            privacyFading = false
            privacyFadeTimer.stop()
        } else {
            privacyFading = true
            privacyFadeTimer.restart()
        }
    }

    Timer {
        id: privacyFadeTimer
        interval: Motion.fadeMs + 40
        repeat: false
        onTriggered: root.privacyFading = false
    }

    // Whether an item takes up space right now. Hidden items leave no gap.
    function itemShown(type) {
        switch (type) {
            case "workspaces": return ShellState.clockShowWorkspaces
            case "visualizer": return ShellState.clockShowVisualizer && AudioService.isPlaying
            case "date": return ShellState.clockDateStyle > 0
            case "time": return true
            case "timer": return ShellState.clockShowTimerIcon && (TimerService.secondsRemaining > 0 || TimerService.running)
            case "privacy": return root.privacyActive || root.privacyFading
            case "recording": return root.recordingActive || root.recordingFading
            default: return false
        }
    }

    function componentFor(type) {
        switch (type) {
            case "workspaces": return workspacesItem
            case "visualizer": return visualizerItem
            case "date": return dateItem
            case "time": return timeItem
            case "timer": return timerItem
            case "privacy": return privacyItem
            case "recording": return recordingItem
            default: return null
        }
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 14

        // Order comes from ClockLayoutService (Settings > Bar & Island > Clock).
        Repeater {
            model: ClockLayoutService.layoutModel

            delegate: Loader {
                id: slot
                required property string itemId

                Layout.alignment: Qt.AlignVCenter
                visible: root.itemShown(slot.itemId)
                sourceComponent: root.componentFor(slot.itemId)
            }
        }
    }

    // ---------------- item types ----------------

    Component {
        id: workspacesItem
        Workspaces {}
    }

    // Looks: Settings > Bar & Island > Clock > Visualizer.
    Component {
        id: visualizerItem

        ClockVisualizer {
            running: ShellState.clockShowVisualizer && AudioService.isPlaying
        }
    }

    Component {
        id: dateItem

        Text {
            text: Qt.formatDateTime(root.shownDate, ShellState.clockDateFormat)
            color: Colors.fgMuted
            font {
                family: Fonts.display
                pixelSize: Dimens.fontSizeBase
                weight: 500
            }
        }
    }

    Component {
        id: timeItem

        Text {
            text: Qt.formatDateTime(root.shownDate, ShellState.clockTimeFormat)
            color: Colors.fg
            font {
                family: Fonts.display
                pixelSize: Dimens.fontSizeBase
                weight: 700
            }
        }
    }

    // Click toggles the global timer page.
    Component {
        id: timerItem

        Text {
            text: "timer"
            font.family: Fonts.icon
            font.pixelSize: Dimens.fontSizeMd
            color: TimerService.running || TimerService.secondsRemaining > 0 ? Colors.accent : Colors.fgMuted

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: ShellState.togglePage("timertoast")
            }
        }
    }

    // Camera = green, microphone = yellow (the theme has no orange). Camera wins over mic.
    Component {
        id: privacyItem

        PrivacyIndicator {
            active: root.privacyActive
            dotSize: 6
            dotColor: PrivacyService.lastColor
        }
    }

    // Follows Clock settings > Recording indicator (clock)
    Component {
        id: recordingItem

        RecordingIndicator {
            active: root.recordingActive
            dotSize: 6
            dotColor: Colors.red
        }
    }
}