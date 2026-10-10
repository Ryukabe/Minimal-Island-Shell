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
import "settings/core"

PanelWindow {
    id: window

    readonly property string iconDir: "file://" + Quickshell.shellDir + "/assets/icons/"

    // ---- Idle / toast state ----
    readonly property bool compactPage: ShellState.activePage === "clock" || ShellState.activePage === "timertoast"
    readonly property bool toastPage: ShellState.activePage === "notification" || ShellState.activePage === "eventtoast"

    // Auto-hide: the island only slides away while a compact page is showing and the pointer is
    // away. Any panel, toast or shortcut brings it back (compactPage goes false).
    property bool revealed: false
    readonly property bool islandHidden: !ShellState.islandAlwaysVisible && compactPage && !revealed
    readonly property bool pointerOver: islandTapArea.containsMouse || hoverZoneHover.hovered

    onCompactPageChanged: {
        if (compactPage) {
            revealed = true
            hideTimer.restart()
        } else {
            hideTimer.stop()
        }
    }

    onPointerOverChanged: {
        if (pointerOver) {
            hideTimer.stop()
            revealed = true
        } else if (compactPage) {
            hideTimer.restart()
        }
    }

    Timer {
        id: hideTimer
        interval: ShellState.islandHideDelayMs
        repeat: false
        onTriggered: if (!window.pointerOver) window.revealed = false
    }

    WlrLayershell.namespace: "quickshell:island"
    // Overlay renders above fullscreen windows; only used while a toast is showing.
    WlrLayershell.layer: (ShellState.notificationOverFullscreen && window.toastPage) ? WlrLayer.Overlay : WlrLayer.Top
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
    // Auto-hide gives the space back to windows.
    exclusiveZone: ShellState.islandAlwaysVisible ? island.compactHeight + island.anchors.topMargin : 0

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
        EventToastService.title
        PolkitService.isActive
        Hyprland
        Kitty
        VSCode
        Gtk
        SettingsStore
        // Show briefly at startup, then let auto-hide take over.
        window.revealed = true
        hideTimer.restart()
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

    // Input region. Auto-hide on + compact page: the hover zone (the edge strip while hidden,
    // the island plus the gap above it while shown). Otherwise exactly as before.
    mask: Region {
        item: (island.expanded && ShellState.activePage !== "notification" && ShellState.islandClickOutsideDismiss)
            ? clickCatcher
            : ((!ShellState.islandAlwaysVisible && window.compactPage) ? hoverZone : island)
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

    // Edge strip that reveals the island, and keeps it revealed while the pointer is in the gap
    // between the screen edge and the island.
    Rectangle {
        id: hoverZone
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        color: "transparent"
        width: window.islandHidden ? ShellState.islandCompactWidth : island.width
        height: window.islandHidden
            ? (ShellState.islandRevealOnHover ? ShellState.islandRevealZone : 0)
            : island.height + (ShellState.islandNotchMode ? 0 : ShellState.islandTopMargin)

        HoverHandler {
            id: hoverZoneHover
            enabled: ShellState.islandRevealOnHover || !window.islandHidden
        }
    }

    NotchShape {
        id: notchShape
        visible: ShellState.islandNotchMode
        anchors.horizontalCenter: parent.horizontalCenter
        y: island.anchors.topMargin
        z: -1
        notchWidth: island.width
        notchHeight: island.height
        bottomRadius: ShellState.islandCornerRadius
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
        // Hidden: parked above the screen edge, far enough that the shadow halo clears it too.
        anchors.topMargin: window.islandHidden
            ? -(island.height + ShellState.islandTopMargin + Dimens.paddingLarge * 4)
            : (ShellState.islandNotchMode ? 0 : ShellState.islandTopMargin)
        clip: true

        readonly property bool expanded: ShellState.activePage !== "clock" 
                       && ShellState.activePage !== "timertoast" 
                       && ShellState.activePage !== "notificationtoast" 
                       && ShellState.activePage !== "eventtoast"
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

        // Spring physics on: width/height follow MorphSpring (velocity-carrying, can overshoot,
        // retargets mid-flight). Off / Reduce Motion: the old ease Behaviors below take over.
        readonly property bool springMorph: ShellState.motionSpringEnabled && !ShellState.motionReduced

        MorphSpring {
            id: widthSpring
            target: island.targetWidth
            active: island.springMorph
            duration: Motion.morphDuration
            bounce: Motion.morphBounce
        }

        MorphSpring {
            id: heightSpring
            target: island.targetHeight
            active: island.springMorph
            duration: Motion.morphDuration
            bounce: Motion.morphBounce
        }

        // Rounded so text stays crisp; clamped so overshoot can never go negative.
        width: springMorph ? Math.max(0, Math.round(widthSpring.value)) : targetWidth
        height: springMorph ? Math.max(0, Math.round(heightSpring.value)) : targetHeight

        // Single source of truth: both compact and expanded states read
        // the same master radius now. (Previously expanded had its own
        // independent ShellState.islandExpandedCornerRadius, which is
        // what let the two drift out of sync.)
        radius: ShellState.islandCornerRadius
        color: ShellState.islandNotchMode ? "transparent" : Colors.mainBgMica
        border.color: Colors.border
        border.width: ShellState.islandNotchMode ? 0 : ShellState.islandBorderWidth

        // ---- width/height ease path (spring physics off / Reduce Motion) ----
        NumberAnimation {
            id: widthEaseAnim
            duration: ShellState.motionDuration(Motion.glideMs)
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.15, 1.0, 0.05, 1.0, 1, 1]
        }
        Behavior on width {
            enabled: !island.springMorph
            animation: widthEaseAnim
        }

        NumberAnimation {
            id: heightEaseAnim
            duration: ShellState.motionDuration(Motion.glideMs)
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.15, 1.0, 0.05, 1.0, 1, 1]
        }
        Behavior on height {
            enabled: !island.springMorph
            animation: heightEaseAnim
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
            // Without this, containsMouse is only true while a button is pressed,
            // so the hover lift never played on plain hover.
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            // Wheel gestures: top half = volume, bottom half = brightness. Wheel deltas arrive in
            // units of 120 per notch; touchpads send many small ones, so they are accumulated.
            property real wheelAccumulator: 0
            onWheel: (wheel) => {
                wheelAccumulator += wheel.angleDelta.y
                var steps = Math.trunc(wheelAccumulator / 120)
                if (steps === 0) return
                wheelAccumulator -= steps * 120

                var topHalf = wheel.y < height / 2
                var up = steps > 0
                var count = Math.abs(steps)
                for (var i = 0; i < count; i++) {
                    if (topHalf && ShellState.islandScrollVolume) {
                        if (up) VolumeService.increase(); else VolumeService.decrease()
                    } else if (!topHalf && ShellState.islandScrollBrightness) {
                        if (up) BrightnessService.increase(); else BrightnessService.decrease()
                    }
                }
            }

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

            // hover feedback = snap tier. Scale moves only a few percent, so it
            // needs scaleEpsilon — the pixel epsilon (0.25) is bigger than the whole
            // travel and would end the spring immediately.
            SpringAnimation {
                id: hoverSpringAnim
                spring: Motion.snapSpring
                damping: Motion.snapDamping
                mass: Motion.snapMass
                epsilon: Motion.scaleEpsilon
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

            // Content entrance — ease variant (spring toggle off / reduced motion).
            // The container leads; content starts after Motion.contentDelayMs.
            SequentialAnimation {
                id: contentAnimEase
                PauseAnimation { duration: ShellState.motionDuration(Motion.contentDelayMs) }
                ParallelAnimation {
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
            }

            // Content entrance — real spring variant (spring toggle on), same delay
            SequentialAnimation {
                id: contentAnimSpring
                PauseAnimation { duration: ShellState.motionDuration(Motion.contentDelayMs) }
                ParallelAnimation {
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
                        epsilon: Motion.scaleEpsilon
                    }
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
                    case "eventtoast": return eventToastPage
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
        Component { id: eventToastPage; EventToast {} }
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