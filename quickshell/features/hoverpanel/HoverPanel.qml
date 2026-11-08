// features/hoverpanel/HoverPanel.qml — the panel that opens when you rest the pointer on the island.
// Each block is a module that can be turned off in Settings > Bar > Hover panel.
// It sizes itself from its content, so the island grows around it.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../display"
import "../lockscreen"
import "../notifications"
import "../sound"
import "../timer"
import "../../core/shell"
import "../../core/styles"

Item {
    id: root

    readonly property int padding: 14

    implicitWidth: ShellState.hoverPanelWidth
    implicitHeight: column.implicitHeight + root.padding * 2

    // Ticks every second, but only while the panel is on screen.
    SystemClock {
        id: clock
        enabled: root.visible
        precision: SystemClock.Seconds
    }

    // Wall time at the picked location (system time when none is picked).
    readonly property var now: LocationService.localize(clock.date)

    // The page the island returns to when nothing else is open.
    function idlePage() {
        return (TimerService.running || TimerService.secondsRemaining > 0) ? "timertoast" : "clock"
    }

    function formatRemaining(seconds) {
        const total = Math.max(0, Math.floor(seconds))
        const m = Math.floor(total / 60)
        const s = total % 60
        return m + ":" + (s < 10 ? "0" : "") + s
    }

    // ---- Building blocks ----

    // A volume or brightness line: icon, a bar, the percent, and minus / plus buttons.
    // Scrolling over it also changes the level.
    component LevelRow: Item {
        id: lr

        property string icon: ""
        property real percent: 0
        signal stepUp()
        signal stepDown()

        implicitHeight: 30

        Text {
            id: lrIcon
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: lr.icon
            font.family: Fonts.icon
            font.pixelSize: Dimens.fontSizeLg
            color: Colors.fg
        }

        Rectangle {
            id: lrTrack
            anchors.left: lrIcon.right
            anchors.leftMargin: 10
            anchors.right: lrPercent.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            height: 6
            radius: 3
            color: Colors.elevatedBg

            Rectangle {
                width: parent.width * Math.max(0, Math.min(100, lr.percent)) / 100
                height: parent.height
                radius: parent.radius
                color: Colors.accent

                Behavior on width {
                    NumberAnimation {
                        duration: ShellState.motionDuration(Motion.snapMs)
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        Text {
            id: lrPercent
            anchors.right: lrButtons.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 34
            horizontalAlignment: Text.AlignRight
            text: Math.round(lr.percent) + "%"
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeSm
            color: Colors.fgMuted
        }

        Row {
            id: lrButtons
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Repeater {
                model: ["remove", "add"]

                delegate: Rectangle {
                    id: stepButton
                    required property string modelData

                    width: 24
                    height: 24
                    radius: 12
                    color: stepMouse.containsMouse ? Colors.elevatedBg : Colors.subBgMica

                    Text {
                        anchors.centerIn: parent
                        text: stepButton.modelData
                        font.family: Fonts.icon
                        font.pixelSize: Dimens.fontSizeMd
                        color: Colors.fg
                    }

                    MouseArea {
                        id: stepMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: stepButton.modelData === "add" ? lr.stepUp() : lr.stepDown()
                    }
                }
            }
        }

        WheelHandler {
            onWheel: (event) => event.angleDelta.y > 0 ? lr.stepUp() : lr.stepDown()
        }
    }

    // A tappable card: an icon, a title and a second line.
    component InfoCard: Rectangle {
        id: ic

        property string icon: ""
        property string title: ""
        property string subtitle: ""
        signal clicked()

        implicitHeight: 46
        radius: ShellState.islandCornerRadius
        color: icMouse.containsMouse ? Colors.elevatedBg : Colors.subBgMica
        border.width: 1
        border.color: Colors.border

        Text {
            id: icGlyph
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: ic.icon
            font.family: Fonts.icon
            font.pixelSize: Dimens.fontSizeLg
            color: Colors.accent
        }

        Column {
            anchors.left: icGlyph.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                width: parent.width
                text: ic.title
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
                font.weight: Font.Medium
                color: Colors.fg
                elide: Text.ElideRight
            }

            Text {
                visible: ic.subtitle !== ""
                width: parent.width
                text: ic.subtitle
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXSm
                color: Colors.fgMuted
                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: icMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: ic.clicked()
        }
    }

    // ---- The panel ----

    // A click on empty space opens the Dashboard, the same as tapping the island.
    MouseArea {
        anchors.fill: parent
        onClicked: ShellState.showPage("status")
    }

    Column {
        id: column
        x: root.padding
        y: root.padding
        width: root.implicitWidth - root.padding * 2
        spacing: 10

        // Date and time
        Column {
            visible: ShellState.hoverPanelShowDate
            width: parent.width
            spacing: 2

            Text {
                text: Qt.formatDateTime(root.now, ShellState.clockTimeFormat)
                font.family: Fonts.display
                font.pixelSize: Dimens.fontSizeXxl
                font.weight: Font.Bold
                color: Colors.fg
            }

            Text {
                text: Qt.formatDateTime(root.now, "dddd, d MMMM")
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
                color: Colors.fgMuted
            }
        }

        // Volume and brightness
        Column {
            visible: ShellState.hoverPanelShowLevels
            width: parent.width
            spacing: 4

            LevelRow {
                width: parent.width
                icon: VolumeService.muted ? "volume_off" : "volume_up"
                percent: VolumeService.percent
                onStepUp: VolumeService.increase()
                onStepDown: VolumeService.decrease()
            }

            LevelRow {
                width: parent.width
                icon: "brightness_6"
                percent: BrightnessService.percent
                onStepUp: BrightnessService.increase()
                onStepDown: BrightnessService.decrease()
            }
        }

        // Notifications
        InfoCard {
            visible: ShellState.hoverPanelShowNotifications
            width: parent.width
            icon: "notifications"
            title: NotificationService.count === 0
                ? "No notifications"
                : NotificationService.count + (NotificationService.count === 1 ? " notification" : " notifications")
            subtitle: (NotificationService.count > 0 && ShellState.notificationPreviewsEnabled
                       && NotificationService.latestNotification)
                ? NotificationService.latestNotification.summary : ""
            onClicked: ShellState.showPage("notificationcenter")
        }

        // Timer (only while one is running)
        InfoCard {
            visible: ShellState.hoverPanelShowTimer && (TimerService.running || TimerService.secondsRemaining > 0)
            width: parent.width
            icon: "timer"
            title: root.formatRemaining(TimerService.secondsRemaining)
            subtitle: TimerService.running ? "Running" : "Paused"
            onClicked: ShellState.showPage("timer")
        }

        // Quick actions
        Row {
            id: actions
            visible: ShellState.hoverPanelShowActions
            width: parent.width
            spacing: 6

            readonly property real buttonWidth: (width - spacing * 5) / 6

            Repeater {
                model: [
                    { icon: "tune", page: "control" },
                    { icon: "notifications", page: "notificationcenter" },
                    { icon: "dashboard", page: "status" },
                    { icon: "apps", page: "launcher" },
                    { icon: "settings", page: "settings" },
                    { icon: "power_settings_new", page: "power" }
                ]

                delegate: Rectangle {
                    id: actionButton
                    required property var modelData

                    width: actions.buttonWidth
                    height: 36
                    radius: ShellState.islandCornerRadius
                    color: actionMouse.containsMouse ? Colors.elevatedBg : Colors.subBgMica
                    border.width: 1
                    border.color: Colors.border

                    Text {
                        anchors.centerIn: parent
                        text: actionButton.modelData.icon
                        font.family: Fonts.icon
                        font.pixelSize: Dimens.fontSizeLg
                        color: Colors.fg
                    }

                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (actionButton.modelData.page === "settings") {
                                ShellState.openSettings()
                                ShellState.showPage(root.idlePage())
                            } else {
                                ShellState.showPage(actionButton.modelData.page)
                            }
                        }
                    }
                }
            }
        }
    }
}