// Island.qml — bar window, page router, and IPC
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "modules"
import "styles"
import "styles/adapters"
import "services"
import "components/bar"
import "components/common"
import "settings/services"

PanelWindow {
    id: window

    readonly property string iconDir: "file://" + Quickshell.shellDir + "/assets/icons/"

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
        SettingsStore
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
        function open() { ShellState.showPage("notificationcenter") }
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

    mask: Region {
        item: (island.expanded && ShellState.activePage !== "notification" && ShellState.islandClickOutsideDismiss) ? clickCatcher : island
    }

    Rectangle {
        id: clickCatcher
        anchors.fill: parent
        color: "transparent"
        visible: island.expanded && ShellState.islandClickOutsideDismiss

        MouseArea {
            anchors.fill: parent
            onClicked: ShellState.showPage(getDefaultPage())
        }
    }

    NotchShape {
        id: notchShape
        visible: ShellState.islandNotchMode
        anchors.horizontalCenter: parent.horizontalCenter
        y: 0
        z: -1
        notchWidth: island.width
        notchHeight: island.height
        bottomRadius: Math.min(island.height / 2, ShellState.islandCornerRadius)
        flare: ShellState.islandNotchFlare
        fillColor: Colors.mainBgMica
    }

    // ---- Island drop shadow ----
    // islandShadowSource is an exact-shape, exact-position copy of the
    // island (same anchors, same size, same radius) sitting directly
    // behind it. MultiEffect's autoPaddingEnabled grows the effect's
    // rendered bounds beyond the source automatically — no fixed pixel
    // margin to guess. shadowScale grows the shadow shape itself before
    // blurring, which is what pushes the halo out past the LEFT/RIGHT
    // edges specifically (shadowBlur alone only softens the edge, it
    // doesn't reach further). The island, painted on top at identical
    // geometry, covers the crisp unblurred center completely.
    Rectangle {
        id: islandShadowSource
        anchors.horizontalCenter: island.horizontalCenter
        anchors.top: island.top
        width: island.width
        height: island.height
        radius: island.radius
        color: Colors.mainBgMica
        visible: Colors.islandShadowEnabled
    }

    MultiEffect {
        id: islandShadow
        anchors.fill: islandShadowSource
        source: islandShadowSource
        visible: Colors.islandShadowEnabled
        z: -0.5
        autoPaddingEnabled: true
        shadowEnabled: true
        shadowColor: Colors.shadowColor
        shadowOpacity: Colors.shadowOpacity
        shadowBlur: Colors.shadowBlur
        shadowScale: Colors.shadowScale
        shadowVerticalOffset: Colors.shadowVerticalOffset
        shadowHorizontalOffset: 0
    }

    Rectangle {
        id: island
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: ShellState.islandNotchMode ? 0 : ShellState.islandTopMargin
        clip: true

        readonly property bool expanded: ShellState.activePage !== "clock" 
                       && ShellState.activePage !== "timertoast" 
                       && ShellState.activePage !== "notificationtoast" 
                       && ShellState.activePage !== "volume" 
                       && ShellState.activePage !== "brightness" 
                       && ShellState.activePage !== "settings" 
                       && ShellState.activePage !== "lock"
                       && ShellState.activePage !== "polkit"
        readonly property int compactHeight: ShellState.islandCompactHeight
        readonly property int compactWidth: ShellState.islandCompactWidth

        property int targetWidth: {
            if (!pageLoader.item) return compactWidth
            var floor = expanded ? ShellState.islandMinExpandedWidth : compactWidth
            return Math.max(pageLoader.item.implicitWidth, floor)
        }
        property int targetHeight: {
            if (!pageLoader.item) return compactHeight
            var floor = expanded ? ShellState.islandExpandedHeight : compactHeight
            return Math.max(pageLoader.item.implicitHeight, floor)
        }

        width: targetWidth
        height: targetHeight

        radius: island.expanded
            ? Math.min(height / 2, ShellState.islandExpandedCornerRadius)
            : Math.min(height / 2, ShellState.islandCornerRadius)
        color: ShellState.islandNotchMode ? "transparent" : Colors.mainBgMica
        border.color: Colors.border
        border.width: ShellState.islandNotchMode ? 0 : ShellState.islandBorderWidth

        // ---- width/height: the "big" morph, gets the full spring/ease toggle ----
        SpringAnimation {
            id: widthSpringAnim
            spring: Motion.glideSpring
            damping: Motion.glideDamping
            mass: Motion.glideMass
            epsilon: Motion.epsilon
        }
        NumberAnimation {
            id: widthEaseAnim
            duration: ShellState.motionDuration(Motion.glideMs)
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.15, 1.0, 0.05, 1.0, 1, 1]
        }
        Behavior on width {
            animation: (ShellState.motionSpringEnabled && !ShellState.motionReduced) ? widthSpringAnim : widthEaseAnim
        }

        SpringAnimation {
            id: heightSpringAnim
            spring: Motion.glideSpring
            damping: Motion.glideDamping
            mass: Motion.glideMass
            epsilon: Motion.epsilon
        }
        NumberAnimation {
            id: heightEaseAnim
            duration: ShellState.motionDuration(Motion.glideMs)
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.15, 1.0, 0.05, 1.0, 1, 1]
        }
        Behavior on height {
            animation: (ShellState.motionSpringEnabled && !ShellState.motionReduced) ? heightSpringAnim : heightEaseAnim
        }

        // ---- radius/topMargin/border.width: intentionally short plain eases, never spring ----
        Behavior on radius {
            NumberAnimation {
                duration: ShellState.motionDuration(Motion.glideMs * 0.85)
                easing.type: Easing.OutCubic
            }
        }

        Behavior on anchors.topMargin {
            NumberAnimation {
                duration: ShellState.motionDuration(Motion.glideMs)
                easing.type: Easing.OutCubic
            }
        }

        Behavior on border.width {
            NumberAnimation {
                duration: ShellState.motionDuration(Motion.fadeMs)
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
            scale: islandTapArea.containsMouse ? ShellState.islandHoverScale : 1.0
            opacity: 1.0

            // hover feedback = snap tier
            SpringAnimation {
                id: hoverSpringAnim
                spring: Motion.snapSpring
                damping: Motion.snapDamping
                mass: Motion.snapMass
                epsilon: Motion.epsilon
            }
            NumberAnimation {
                id: hoverEaseAnim
                duration: ShellState.motionDuration(Motion.snapMs)
                easing.type: Easing.OutCubic
            }
            Behavior on scale {
                animation: (ShellState.motionSpringEnabled && !ShellState.motionReduced) ? hoverSpringAnim : hoverEaseAnim
            }

            onItemChanged: {
                if (item) {
                    contentAnimSpring.stop()
                    contentAnimEase.stop()
                    item.opacity = 0
                    item.scale = 0.94
                    if (ShellState.motionSpringEnabled && !ShellState.motionReduced) {
                        contentAnimSpring.start()
                    } else {
                        contentAnimEase.start()
                    }
                }
            }

            // Content entrance — ease variant (spring toggle off / reduced motion)
            ParallelAnimation {
                id: contentAnimEase
                NumberAnimation {
                    target: pageLoader.item
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: ShellState.motionDuration(Motion.fadeMs)
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: pageLoader.item
                    property: "scale"
                    from: 0.94
                    to: 1.0
                    duration: ShellState.motionDuration(Motion.glideMs)
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.15, 1.0, 0.05, 1.0, 1, 1]
                }
            }

            // Content entrance — real spring variant (spring toggle on)
            ParallelAnimation {
                id: contentAnimSpring
                NumberAnimation {
                    target: pageLoader.item
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: ShellState.motionDuration(Motion.fadeMs)
                    easing.type: Easing.OutCubic
                }
                SpringAnimation {
                    target: pageLoader.item
                    property: "scale"
                    to: 1.0
                    spring: Motion.glideSpring
                    damping: Motion.glideDamping
                    mass: Motion.glideMass
                    epsilon: Motion.epsilon
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