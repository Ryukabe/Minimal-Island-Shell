import QtQuick
import Quickshell.Io
import Quickshell.Hyprland as QsHypr
import "../../services"
import "../../styles"
import "../common"

Item {
    id: root

    readonly property int focusedId: QsHypr.Hyprland.focusedWorkspace ? QsHypr.Hyprland.focusedWorkspace.id : 1
    readonly property real dotSize: ShellState.workspaceDotSize
    readonly property real activeWidth: Math.max(ShellState.workspaceActiveWidth, ShellState.workspaceDotSize)

    readonly property color activeColor: ShellState.workspaceUseAccent ? Colors.accent : Colors.fg
    readonly property color occupiedColor: Qt.tint(Colors.fgMuted, Qt.alpha(Colors.accent, 0.55))

    function isOccupied(id) {
        var list = QsHypr.Hyprland.workspaces.values
        for (var i = 0; i < list.length; i++) {
            if (list[i].id === id) return true
        }
        return false
    }

    // Hyprland runs a Lua config, so the command is a Lua expression, not "workspace N".
    // Runs `hyprctl dispatch`, which is the form your terminal test showed Hyprland accepts.
    Process {
        id: switcher
    }

    function switchTo(id) {
        console.log("Workspaces: clicked dot for workspace", id)
        if (switcher.running) return
        switcher.command = ["hyprctl", "dispatch", "hl.dsp.focus({ workspace = " + id + " })"]
        switcher.running = true
    }

    // Height is only the dot height, so the pill never makes the island taller.
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Dimens.spacingSmall

        Repeater {
            model: ShellState.workspaceShownCount

            Rectangle {
                id: dot
                required property int index
                readonly property int wsId: index + 1
                readonly property bool isActive: root.focusedId === wsId
                readonly property bool highlighted: isActive && ShellState.workspaceActiveIndicator
                readonly property bool occupied: root.isOccupied(wsId)
                readonly property bool tinted: ShellState.workspaceOccupiedBackground && occupied

                width: Math.max(root.dotSize, spring.value)
                height: root.dotSize
                radius: height / 2

                color: highlighted ? root.activeColor : (tinted ? root.occupiedColor : Colors.fgMuted)
                opacity: highlighted ? 1.0 : (tinted ? 0.9 : 0.5)

                // Color and opacity only fade, they never spring.
                Behavior on color {
                    ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                }
                Behavior on opacity {
                    NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                }

                // One spring drives both styles: Glide = bounce 0, Bounce = lively.
                // With Active trail on, the dot you left shrinks on the slower Glide
                // duration while the new one grows quickly, so a short tail stays behind.
                MorphSpring {
                    id: spring
                    target: dot.highlighted ? root.activeWidth : root.dotSize
                    active: !ShellState.motionReduced
                    duration: (ShellState.workspaceActiveTrail && !dot.highlighted)
                        ? Motion.glideMs / 1000
                        : Motion.morphDuration
                    bounce: ShellState.workspaceBounce ? Math.max(0.25, Motion.morphBounce) : 0
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.leftMargin: -Dimens.spacingSmall / 2
                    anchors.rightMargin: -Dimens.spacingSmall / 2
                    anchors.topMargin: -Dimens.paddingSmall
                    anchors.bottomMargin: -Dimens.paddingSmall
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.switchTo(dot.wsId)
                }
            }
        }
    }
}