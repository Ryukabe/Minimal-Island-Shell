// Island.qml — bar window, page router, and IPC
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "modules"
import "styles"
import "styles/adapters"
import "services"
import "components/bar"
import "components/common"

PanelWindow {
    id: window

    readonly property string iconDir: "file://" + Quickshell.shellDir + "/assets/icons/"

    // Restrict exclusive keyboard focus strictly to interactive overlay pages (excluding clock and timertoast)
    // so that normal screen clicks/focus pass through to underlying windows.
    WlrLayershell.namespace: "quickshell:island"
    WlrLayershell.keyboardFocus: (
        ShellState.activePage === "launcher" ||
        ShellState.activePage === "clipboard" ||
        ShellState.activePage === "power" ||
        ShellState.activePage === "theme" ||
        ShellState.activePage === "wallpaper" ||
        ShellState.activePage === "control" ||
        ShellState.activePage === "notificationcenter" ||
        ShellState.activePage === "polkit" ||
        ShellState.activePage === "status" ||
        ShellState.activePage === "timer"
    ) ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors { top: true }
    implicitHeight: 600
    implicitWidth: 1200
    color: "transparent"

    exclusionMode: ExclusionMode.Normal
    exclusiveZone: island.compactHeight + island.anchors.topMargin

    function getDefaultPage() {
        return (TimerService.running || TimerService.secondsRemaining > 0) ? "timertoast" : "clock"
    }

    Shortcut {
        sequence: "Escape"
        enabled: ShellState.activePage !== getDefaultPage()
        onActivated: ShellState.showPage(getDefaultPage())
    }

    Component.onCompleted: {
        BrightnessService.percent
        VolumeService.percent
        NotificationService.trackedNotifications
        PolkitService.isActive
        Hyprland
        Kitty
        VSCode
    }

    function brightnessTier(percent) {
        var tier = Math.round(percent / 20) * 20
        return Math.max(20, Math.min(100, tier))
    }

    IpcHandler {
        target: "launcher"
        function toggle() { ShellState.activePage = ShellState.activePage === "launcher" ? getDefaultPage() : "launcher" }
        function open() { ShellState.showPage("launcher") }
        function close() { ShellState.showPage(getDefaultPage()) }
    }

    IpcHandler {
        target: "clipboard"
        function toggle(): void {
            ShellState.activePage === "clipboard" ? ShellState.showPage(getDefaultPage()) : ShellState.showPage("clipboard")
        }
        function open(): void { ShellState.showPage("clipboard") }
        function close() { ShellState.showPage(getDefaultPage()) }
    }

    IpcHandler {
        target: "power"
        function toggle() { ShellState.activePage === "power" ? ShellState.showPage(getDefaultPage()) : ShellState.showPage("power") }
        function open() { ShellState.showPage("power") }
        function close() { ShellState.showPage(getDefaultPage()) }
    }

    IpcHandler {
        target: "controlcenter"
        function toggle(): void { ShellState.activePage === "control" ? ShellState.showPage(getDefaultPage()) : ShellState.showPage("control") }
        function open() { ShellState.showPage("control") }
        function close() { ShellState.showPage(getDefaultPage()) }
    }

    IpcHandler {
        target: "notificationcenter"
        function toggle(): void { ShellState.activePage === "notificationcenter" ? ShellState.showPage(getDefaultPage()) : ShellState.showPage("notificationcenter") }
        function open(): void { ShellState.showPage("notificationcenter") }
        function close() { ShellState.showPage(getDefaultPage()) }
    }

    IpcHandler {
        target: "themeswitcher"
        function toggle() { ShellState.activePage === "theme" ? ShellState.showPage(getDefaultPage()) : ShellState.showPage("theme") }
        function open() { ShellState.showPage("theme") }
        function close() { ShellState.showPage(getDefaultPage()) }
    }

    IpcHandler {
        target: "wallpaper"
        function toggle(): void {
            WallpaperService.isOpen = !WallpaperService.isOpen
            if (WallpaperService.isOpen) {
                ShellState.showPage("wallpaper")
            } else {
                ShellState.showPage(getDefaultPage())
            }
        }
    }

    IpcHandler {
        target: "timer"
        function toggle() { ShellState.activePage === "timer" ? ShellState.showPage(getDefaultPage()) : ShellState.showPage("timer") }
        function open() { ShellState.showPage("timer") }
        function close() { ShellState.showPage(getDefaultPage()) }
    }

    // Input mask restricts click interactions to just the island element when showing 
    // compact states ("clock" or "timertoast"), allowing clicks to pass through everywhere else.
    mask: Region {
        item: (island.expanded && ShellState.activePage !== "notification") ? clickCatcher : island
    }

    Rectangle {
        id: clickCatcher
        anchors.fill: parent
        color: "transparent"
        visible: island.expanded

        MouseArea {
            anchors.fill: parent
            onClicked: ShellState.showPage(getDefaultPage())
        }
    }

    Rectangle {
        id: island
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 5
        clip: true

        // Both "clock" and "timertoast" should be treated as compact unexpanded components
        readonly property bool expanded: ShellState.activePage !== "clock" && ShellState.activePage !== "timertoast"
        readonly property int compactHeight: 36
        readonly property int compactWidth: 160
        property int targetWidth: pageLoader.item ? pageLoader.item.implicitWidth : compactWidth
        property int targetHeight: pageLoader.item ? pageLoader.item.implicitHeight : compactHeight

        width: targetWidth
        height: targetHeight

        radius: Math.min(height / 2, Dimens.islandRadius)
        color: Colors.islandMica
        border.color: Colors.islandMica
        border.width: 0

        Behavior on width {
            NumberAnimation {
                duration: 380
                easing.type: Easing.OutExpo
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 380
                easing.type: Easing.OutExpo
            }
        }

        Behavior on radius {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            id: islandTapArea
            anchors.fill: parent
            enabled: ShellState.activePage === "clock" || ShellState.activePage === "timertoast"
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (ShellState.activePage === "timertoast") {
                    ShellState.togglePage("timer")
                } else {
                    ShellState.togglePage("status")
                }
            }
        }

        MouseArea {
            id: islandConsumeArea
            anchors.fill: parent
            enabled: island.expanded
            onClicked: {}
        }

        Loader {
            id: pageLoader
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            scale: islandTapArea.containsMouse ? 1.02 : 1.0
            opacity: 1.0

            Behavior on scale {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.2
                }
            }

            onItemChanged: {
                if (item) {
                    contentAnim.stop()
                    item.opacity = 0
                    item.scale = 0.94
                    contentAnim.start()
                }
            }

            ParallelAnimation {
                id: contentAnim
                NumberAnimation {
                    target: pageLoader.item
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 220
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: pageLoader.item
                    property: "scale"
                    from: 0.94
                    to: 1.0
                    duration: 280
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.1
                }
            }

            sourceComponent: {
                switch (ShellState.activePage) {
                    case "clock": return clockPage
                    case "status": return statusPage
                    case "media": return mediaPage
                    case "power": return powerPage
                    case "control": return controlPage
                    case "launcher": return launcherPage
                    case "clipboard": return clipboardPage
                    case "volume": return volumePage
                    case "brightness": return brightnessPage
                    case "notification": return notificationPage
                    case "notificationcenter": return notificationCenterPage
                    case "theme": return themePage
                    case "wallpaper": return wallpaperSwitcherPage
                    case "polkit": return polkitPage
                    case "timer": return timerPage
                    case "timertoast": return timerToastPage
                    default: return clockPage
                }
            }
        }

        Component { id: clockPage; Clock {} }
        Component { id: mediaPage; MediaExpanded { color: "transparent" } }
        Component { id: notificationPage; NotificationToast {} }
        Component { id: launcherPage; AppLauncher {} }
        Component { id: clipboardPage; Clipboard {} }
        Component { id: powerPage; PowerMenu {} }
        Component { id: themePage; ThemeSwitcher {} }
        Component { id: wallpaperSwitcherPage; WallpaperSwitcher {} }
        Component { id: controlPage; ControlCenter {} }
        Component { id: notificationCenterPage; NotificationCenter {} }
        Component { id: polkitPage; PolkitAgent {} }
        Component { id: timerToastPage; TimerToast {} }
        Component { id: timerPage; TimerModule {} }
        Component { id: statusPage; StatusPanel {} }

        Component {
            id: brightnessPage
            LevelIndicator {
                iconSource: window.iconDir + "brightness-" + brightnessTier(BrightnessService.percent) + ".png"
                percent: BrightnessService.percent
            }
        }

        Component {
            id: volumePage
            LevelIndicator {
                iconSource: VolumeService.muted || VolumeService.percent === 0 ? window.iconDir + "volume-mute.png"
                    : VolumeService.percent <= 35 ? window.iconDir + "volume-low.png"
                    : VolumeService.percent <= 65 ? window.iconDir + "volume-mid.png"
                    : window.iconDir + "volume-high.png"
                percent: VolumeService.percent
            }
        }
    }
}