// modules/PowerMenu.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../styles"
import "../services"

Item {
    id: root
    implicitWidth: row.implicitWidth + 48
    implicitHeight: 76
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
        revealTimer.restart()
    }

    Timer {
        id: revealTimer
        interval: 30
        onTriggered: {
            contentWrapper.opacity = 1.0
            contentWrapper.scale = 1.0
        }
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

    Item {
        id: contentWrapper
        anchors.fill: parent
        opacity: 0.0
        scale: 0.94

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 280; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
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

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on scale {
                        NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1.25 }
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
}