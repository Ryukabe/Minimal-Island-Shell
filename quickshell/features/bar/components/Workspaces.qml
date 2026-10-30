// features/bar/components/Workspaces.qml
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland as QsHypr
import "../../theme"
import "../../../core/shell"
import "../../../core/styles"
import "../../../core/common"

Item {
    id: root

    readonly property int focusedId: QsHypr.Hyprland.focusedWorkspace ? QsHypr.Hyprland.focusedWorkspace.id : 1
    readonly property real dotSize: ShellState.workspaceDotSize
    readonly property real activeWidth: Math.max(ShellState.workspaceActiveWidth, ShellState.workspaceDotSize)

    readonly property color activeColor: ShellState.workspaceUseAccent ? Colors.accent : Colors.fg
    readonly property color occupiedColor: Qt.tint(Colors.fgMuted, Qt.alpha(Colors.accent, 0.55))

    // ---- window icons ----
    readonly property bool showWindows: ShellState.workspaceShowWindows
    // Tallest icon that fits the compact island. Clock.qml pads the row by 8px total
    // (implicitHeight = layout + 8), so that 8 is subtracted here; keep them in step.
    readonly property real iconSize: Math.max(dotSize, ShellState.islandCompactHeight - 8 - Dimens.spacingMedium)
    // Icons of one workspace sit close together; workspaces sit further apart.
    readonly property real iconGap: Dimens.spacingSmall / 2
    readonly property real workspaceGap: showWindows ? Dimens.spacingLarge : Dimens.spacingSmall
    readonly property real inactiveIconOpacity: 0.5
    readonly property real rowHeight: showWindows ? iconSize : dotSize

    // ---- monitor ----
    readonly property var barScreen: QsWindow.window ? QsWindow.window.screen : null
    readonly property var barMonitor: barScreen ? QsHypr.Hyprland.monitorFor(barScreen) : null

    function onThisMonitor(ws) {
        if (!ShellState.workspacePerMonitor || !barMonitor || !ws || !ws.monitor) return true
        return ws.monitor === barMonitor
    }

    function workspaceFor(id) {
        var list = QsHypr.Hyprland.workspaces.values
        for (var i = 0; i < list.length; i++) {
            if (list[i].id === id) return list[i]
        }
        return null
    }

    function isOccupied(id) {
        return workspaceFor(id) !== null
    }

    function isSpecialWs(ws) {
        return ws && ws.id < 0 && String(ws.name).indexOf("special:") === 0
    }

    function appIdOf(t) {
        var w = t.wayland
        return (w && w.appId) ? w.appId : "?"
    }

    // "firefox|kitty" style keys: plain strings, so a binding only changes when the window
    // list really changes and the slots do not rebuild on every Hyprland event.
    function appKeyFor(id) {
        var out = []
        var list = QsHypr.Hyprland.toplevels.values
        for (var i = 0; i < list.length; i++) {
            var ws = list[i].workspace
            if (ws && ws.id === id && onThisMonitor(ws)) out.push(appIdOf(list[i]))
        }
        return out.join("|")
    }

    function specialAppKey() {
        var out = []
        var list = QsHypr.Hyprland.toplevels.values
        for (var i = 0; i < list.length; i++) {
            var ws = list[i].workspace
            if (isSpecialWs(ws) && onThisMonitor(ws)) out.push(appIdOf(list[i]))
        }
        return out.join("|")
    }

    function iconFor(appId) {
        if (!appId || appId === "?") return ""
        var entry = DesktopEntries.heuristicLookup(appId)
        return IconThemeService.resolve(entry && entry.icon ? entry.icon : appId)
    }

    // Which slots exist: workspace ids 1..N (filtered per monitor), plus 0 = the special slot.
    readonly property string idsKey: {
        var ids = []
        for (var i = 1; i <= ShellState.workspaceShownCount; i++) {
            var ws = workspaceFor(i)
            if (!ws || onThisMonitor(ws)) ids.push(i)
        }
        if (showWindows && ShellState.workspaceWindowsOnSpecial && specialAppKey() !== "") ids.push(0)
        return ids.join(",")
    }
    readonly property var visibleIds: idsKey === "" ? [] : idsKey.split(",").map(Number)

    Component.onCompleted: QsHypr.Hyprland.refreshToplevels()

    // Hyprland runs a Lua config, so the command is a Lua expression, not "workspace N".
    Process {
        id: switcher
    }

    function switchTo(id) {
        if (switcher.running) return
        switcher.command = ["hyprctl", "dispatch", "hl.dsp.focus({ workspace = " + id + " })"]
        switcher.running = true
    }

    // Height is rowHeight (dot height, or icon height with Show windows), never above what
    // the 36px island leaves free, so the island itself never grows.
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        anchors.centerIn: parent
        spacing: root.workspaceGap

        Repeater {
            model: root.visibleIds

            Item {
                id: slot
                required property var modelData

                readonly property bool isSpecial: modelData === 0
                readonly property int wsId: modelData
                readonly property bool isActive: !isSpecial && root.focusedId === wsId
                readonly property bool highlighted: isActive && ShellState.workspaceActiveIndicator
                readonly property bool occupied: !isSpecial && root.isOccupied(wsId)
                readonly property bool tinted: ShellState.workspaceOccupiedBackground && occupied

                readonly property string appKey: isSpecial ? root.specialAppKey() : root.appKeyFor(wsId)
                readonly property var appIds: appKey === "" ? [] : appKey.split("|")
                // With windows the dot is replaced by bare icons. Without: the dot.
                readonly property bool hasIcons: root.showWindows && appIds.length > 0
                readonly property int extraCount: Math.max(0, appIds.length - ShellState.workspaceMaxWindowIcons)

                readonly property real contentWidth: iconsRow.implicitWidth
                readonly property real dotWidth: highlighted ? root.activeWidth : root.dotSize
                readonly property real springBounce: ShellState.workspaceBounce ? Math.max(0.25, Motion.morphBounce) : 0

                readonly property color dotColor: highlighted ? root.activeColor : (tinted ? root.occupiedColor : Colors.fgMuted)
                readonly property real dotOpacity: highlighted ? 1.0 : (tinted ? 0.9 : 0.5)

                width: Math.max(root.dotSize, widthSpring.value)
                height: root.rowHeight

                MorphSpring {
                    id: widthSpring
                    target: slot.hasIcons ? slot.contentWidth : slot.dotWidth
                    active: !ShellState.motionReduced
                    duration: (ShellState.workspaceActiveTrail && !slot.highlighted && !slot.hasIcons)
                        ? Motion.glideMs / 1000
                        : Motion.morphDuration
                    bounce: slot.springBounce
                }

                // The dot. With icons it fades out (to transparent in its own color, so there
                // is no dark flash) and the icons fade in where it was.
                Rectangle {
                    id: bg
                    width: parent.width
                    height: root.dotSize
                    anchors.verticalCenter: parent.verticalCenter
                    radius: height / 2

                    color: slot.hasIcons ? Qt.alpha(slot.dotColor, 0) : slot.dotColor
                    opacity: slot.hasIcons ? 0.0 : slot.dotOpacity

                    Behavior on color {
                        ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                    }
                }

                // Icons are clipped to the slot while it opens. Icons of workspaces you are not
                // on are dimmed so the active one reads at a glance.
                Item {
                    anchors.fill: parent
                    clip: true
                    opacity: slot.hasIcons
                        ? ((ShellState.workspaceActiveIndicator && !slot.isActive && !slot.isSpecial) ? root.inactiveIconOpacity : 1.0)
                        : 0.0
                    Behavior on opacity {
                        NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
                    }

                    Row {
                        id: iconsRow
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: root.iconGap

                        Repeater {
                            model: slot.appIds.slice(0, ShellState.workspaceMaxWindowIcons)

                            Item {
                                id: iconBox
                                required property string modelData
                                width: root.iconSize
                                height: root.iconSize

                                Image {
                                    id: appIcon
                                    anchors.fill: parent
                                    fillMode: Image.PreserveAspectFit
                                    sourceSize.width: width * 2
                                    sourceSize.height: height * 2
                                    source: root.iconFor(iconBox.modelData)
                                    visible: status === Image.Ready
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: appIcon.status !== Image.Ready
                                    text: iconBox.modelData.charAt(0).toUpperCase()
                                    font.family: Fonts.text
                                    font.pixelSize: Dimens.fontSizeMd
                                    font.weight: Font.Bold
                                    color: Colors.fg
                                }
                            }
                        }

                        Text {
                            visible: slot.extraCount > 0
                            anchors.verticalCenter: parent.verticalCenter
                            text: "+" + slot.extraCount
                            font.family: Fonts.text
                            font.pixelSize: Dimens.fontSizeXs
                            font.weight: Font.Bold
                            color: Colors.fg
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.leftMargin: -root.workspaceGap / 2
                    anchors.rightMargin: -root.workspaceGap / 2
                    anchors.topMargin: -Dimens.paddingSmall
                    anchors.bottomMargin: -Dimens.paddingSmall
                    enabled: !slot.isSpecial
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.switchTo(slot.wsId)
                }
            }
        }
    }
}