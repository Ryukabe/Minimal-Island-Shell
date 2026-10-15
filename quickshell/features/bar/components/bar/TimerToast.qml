// features/bar/components/bar/TimerToast.qml
import QtQuick
import QtQuick.Layouts
import "../../../../core/styles"
import "../../../recording"
import "../../../timer"
import "../../../../core/state"

Item {
    id: root

    readonly property bool paused: !TimerService.running && TimerService.secondsRemaining > 0

    // Grows with the content; never narrower than the old fixed toast.
    implicitWidth: Math.max(ShellState.islandCompactWidth + 5,
                            contentRow.implicitWidth + Dimens.paddingLarge * 2)
    implicitHeight: ShellState.islandCompactHeight

    // One small square icon button, used for all four controls.
    component ToastButton: Rectangle {
        id: btn

        property string glyph: ""
        property color glyphColor: Colors.fg

        signal clicked()

        width: 24
        height: 24
        radius: ShellState.islandCornerRadius
        color: btnMouse.containsMouse && btn.enabled ? Colors.elevatedBg : Colors.subBgMica
        opacity: btn.enabled ? 1.0 : 0.4

        Behavior on color {
            ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
        }
        Behavior on opacity {
            NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
        }

        Text {
            anchors.centerIn: parent
            text: btn.glyph
            font.family: Fonts.icon
            font.pixelSize: Dimens.fontSizeMd
            font.variableAxes: Fonts.iconAxes
            color: btn.glyphColor
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: btn.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 12

        RowLayout {
            spacing: 8

            Text {
                text: "timer"
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeMd
                font.variableAxes: Fonts.iconAxes
                color: root.paused ? Colors.fgMuted : Colors.accent
            }

            Text {
                text: TimerService.secondsRemaining > 0 ? TimerService.formatTime(TimerService.secondsRemaining) : "Timer"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
                font.bold: true
                // Muted while paused, so a stopped clock is obvious at a glance.
                color: root.paused ? Colors.fgMuted : Colors.fg
            }
        }

        RowLayout {
            spacing: 6

            ToastButton {
                glyph: "replay_5"
                onClicked: TimerService.adjust(-300)
            }

            ToastButton {
                glyph: "forward_5"
                onClicked: TimerService.adjust(300)
            }

            ToastButton {
                glyph: TimerService.running ? "pause" : "play_arrow"
                glyphColor: Colors.accent
                enabled: TimerService.secondsRemaining > 0
                onClicked: TimerService.togglePause()
            }

            ToastButton {
                glyph: "restart_alt"
                enabled: TimerService.initialSeconds > 0
                onClicked: TimerService.restart()
            }
        }

        // Recording Indicator — follows Clock settings > Recording indicator (timer toast)
        RecordingIndicator {
            active: RecordingService.enabled && ShellState.timerToastShowRecordingIndicator
            dotSize: 6
            dotColor: Colors.red
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        cursorShape: Qt.PointingHandCursor
        onClicked: ShellState.togglePage("clock")
    }
}