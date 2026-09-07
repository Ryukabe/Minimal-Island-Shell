// modules/PowerMenu.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../styles"
import "../services"

Item {
    id: root
    implicitWidth: ShellState.powerMenuWidth
    implicitHeight: ShellState.powerMenuHeight
    focus: true
    clip: true

    readonly property var actions: [
        {
            icon: "lock",
            label: "Lock",
            cmd: ["sh", "-c", "hyprlock -c $HOME/.config/hypr/hyprlock/hyprlock.conf"]
        },
        {
            icon: "bedtime",
            label: "Sleep",
            cmd: ["systemctl", "suspend"]
        },
        {
            icon: "restart_alt",
            label: "Restart",
            cmd: ["systemctl", "reboot"]
        },
        {
            icon: "logout",
            label: "Logout",
            cmd: ["hyprctl", "dispatch", "exit"]
        },
        {
            icon: "power_settings_new",
            label: "Power Off",
            cmd: ["systemctl", "poweroff"]
        }
    ]

    property int selectedIndex: 0

    Process {
        id: cmdRunner
    }

    function runCmd(cmd) {
        if (!cmd) return
        cmdRunner.command = cmd
        cmdRunner.startDetached()
        ShellState.showPage("clock")
    }

    function triggerSelected() {
        if (actions[selectedIndex]) {
            runCmd(actions[selectedIndex].cmd)
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: root.forceActiveFocus()
    }

    Connections {
        target: ShellState
        function onActivePageChanged() {
            if (ShellState.activePage === "power") {
                root.selectedIndex = 0
                focusTimer.restart()
            }
        }
    }

    Component.onCompleted: {
        if (ShellState.activePage === "power") focusTimer.restart()
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Left) {
            root.selectedIndex = Math.max(root.selectedIndex - 1, 0)
            event.accepted = true
        } else if (event.key === Qt.Key_Right) {
            root.selectedIndex = Math.min(root.selectedIndex + 1, root.actions.length - 1)
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.triggerSelected()
            event.accepted = true
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 16

        Repeater {
            model: root.actions

            Rectangle {
                required property int index
                required property var modelData

                width: 52
                height: 52
                radius: width / 2
                color: index === root.selectedIndex ? Colors.accent : Colors.subBgMica
                border.width: 1
                border.color: Colors.border

                scale: index === root.selectedIndex ? 1.15 : 1.0

                Behavior on color {
                    ColorAnimation { duration: ShellState.motionDuration(ShellState.motionFadeMs) }
                }

                NumberAnimation {
                    id: scaleEaseAnim
                    duration: ShellState.motionDuration(ShellState.motionHoverMs)
                    easing.type: Easing.OutBack
                    easing.overshoot: ShellState.motionOvershoot()
                }

                SpringAnimation {
                    id: scaleSpringAnim
                    spring: ShellState.springStiffness()
                    damping: ShellState.springDamping()
                }

                Behavior on scale {
                    animation: (ShellState.motionSpringEnabled && !ShellState.motionReduced) ? scaleSpringAnim : scaleEaseAnim
                }

                Text {
                    anchors.centerIn: parent
                    text: parent.modelData.icon
                    font.family: Fonts.icon
                    font.pixelSize: Dimens.fontSizeXl
                    font.variableAxes: Fonts.iconAxes
                    font.features: { "liga": 1, "dlig": 1 }
                    color: parent.index === root.selectedIndex ? Colors.fg : Colors.fgMuted
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: root.selectedIndex = parent.index
                    onClicked: {
                        root.selectedIndex = parent.index
                        root.runCmd(parent.modelData.cmd)
                    }
                }
            }
        }
    }
}