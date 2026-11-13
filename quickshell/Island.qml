// Island.qml — the bar window: page router, island morphing, auto-hide, hover panel and IPC.
//
// Order of this file:
//   1. Window, layer and input region
//   2. Page state, auto-hide, and the hover panel's timers and magnify trigger
//   3. Startup and helpers
//   4. IPC handlers
//   5. Click catcher and hover zone
//   6. Island background (shape and shadow)
//   7. The island: size, style, magnify, visibility, pointer input, page loader
//   8. Page components
//
// One animation type everywhere: eases. Growing uses OutBack, so it overshoots a little and settles
// (the Dynamic Island feel); shrinking and everything small uses an ease-out. How far OutBack
// overshoots is Motion > Island bounce (ShellState.motionIslandBouncePercent).

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "features/bar"
import "features/clipboard"
import "features/control-center"
import "features/dashboard"
import "features/hoverpanel"
import "features/launcher"
import "features/lockscreen"
import "features/notifications"
import "features/power"
import "features/theme"
import "features/timer"
import "features/display"
import "features/sound"
import "features/bar/components"
import "features/settings/core"
import "core/shell"
import "core/styles"
import "core/styles/adapters"
import "core/common"

PanelWindow {
    id: window

    // ============================================================
    // 1. WINDOW, LAYER AND INPUT REGION
    // ============================================================

    readonly property string iconDir: "file://" + Quickshell.shellDir + "/assets/icons/"

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

    // The window covers the whole screen, so the island has all of it to play with (bigger panels, and a
    // full-width Bar style later). It is anchored to the left, right and top edges, and its height is the
    // screen's. Only the island, the click catcher and the hover zone take input (see the mask below).
    anchors { top: true; left: true; right: true }
    implicitHeight: window.screen ? window.screen.height : 780
    color: "transparent"

    exclusionMode: ExclusionMode.Normal
    // Auto-hide gives the space back to windows. The gap counts only in island style, and it is read from
    // the setting (not the animated margin), so windows are not re-laid out on every frame of a style change.
    exclusiveZone: ShellState.islandAlwaysVisible
        ? island.compactHeight + (ShellState.islandNotchMode ? 0 : ShellState.islandTopMargin)
        : 0

    // Input region. Auto-hide on + compact page: the hover zone (the edge strip while hidden,
    // the island plus the gap above it while shown). Popups and the hover panel never turn on the
    // click catcher, so you can keep clicking your windows while they are up.
    mask: Region {
        item: (island.expanded
               && ShellState.activePage !== "notification"
               && ShellState.activePage !== "hover"
               && ShellState.islandClickOutsideDismiss
               && ShellState.activePage !== "apptoast")
            ? clickCatcher
            : ((!ShellState.islandAlwaysVisible && window.compactPage) ? hoverZone : island)
    }

    // ============================================================
    // 2. PAGE STATE, AUTO-HIDE, AND THE HOVER PANEL'S TIMERS AND MAGNIFY TRIGGER
    // ============================================================

    // The idle pages, and the pages that pop up briefly.
    readonly property bool compactPage: ShellState.activePage === "clock" || ShellState.activePage === "timertoast"
    readonly property bool toastPage: ShellState.activePage === "notification" || ShellState.activePage === "eventtoast" || ShellState.activePage === "apptoast"
    readonly property bool hoverPageOpen: ShellState.activePage === "hover"

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

    // The pointer is resting on the idle island (it is on screen and showing an idle page).
    readonly property bool pointerOnIdle: window.compactPage && !window.islandHidden && islandTapArea.containsMouse

    // ---- Magnify: when the island grows a little wider and taller and drops a little ----
    readonly property bool magnifyActive: {
        switch (ShellState.islandMagnifyTrigger) {
            case "Pointer over": return window.pointerOnIdle
            case "Panel opens": return window.hoverPageOpen
            case "Both": return window.pointerOnIdle || window.hoverPageOpen
            default: return false
        }
    }

    // ---- Hover panel ----
    // Resting the pointer on the idle island for the hover delay opens the hover panel.
    readonly property bool dwellActive: ShellState.hoverPanelEnabled && window.pointerOnIdle

    onDwellActiveChanged: {
        if (dwellActive) dwellTimer.restart()
        else dwellTimer.stop()
    }

    Timer {
        id: dwellTimer
        interval: ShellState.hoverPanelDelayMs
        repeat: false
        onTriggered: if (window.dwellActive) ShellState.showPage("hover")
    }

    // The panel closes a moment after the pointer leaves the island.
    Timer {
        id: hoverCloseTimer
        interval: ShellState.hoverPanelCloseDelayMs
        repeat: false
        onTriggered: if (window.hoverPageOpen) ShellState.showPage(window.getDefaultPage())
    }

    // ============================================================
    // 3. STARTUP AND HELPERS
    // ============================================================

    function getDefaultPage() {
        return (TimerService.running || TimerService.secondsRemaining > 0) ? "timertoast" : "clock"
    }

    function brightnessTier(percent) {
        var tier = Math.round(percent / 20) * 20
        return Math.max(20, Math.min(100, tier))
    }

    Shortcut {
        sequence: "Escape"
        enabled: ShellState.activePage !== window.getDefaultPage()
        onActivated: ShellState.showPage(window.getDefaultPage())
    }

    Component.onCompleted: {
        BrightnessService.percent
        VolumeService.percent
        NotificationService.trackedNotifications
        EventToastService.title
        // Singleton: must be touched here or it never starts listening for new windows
        // (its only other user, AppToast, only loads after the service itself opens the page).
        AppLaunchToastService.appName
        PolkitService.isActive
        Hyprland
        Kitty
        VSCode
        Gtk3
        Gtk4
        Alacritty
        Btop
        Firefox
        Chrome
        Brave
        Helium
        Zen
        Helix
        Obsidian
        Qt5ct
        Qt6ct
        Starship
        SettingsStore
        // Show briefly at startup, then let auto-hide take over.
        window.revealed = true
        hideTimer.restart()
    }

    // ============================================================
    // 4. IPC HANDLERS
    // ============================================================

    IpcHandler {
        target: "launcher"
        function toggle() { ShellState.activePage = ShellState.activePage === "launcher" ? window.getDefaultPage() : "launcher" }
        function open() { ShellState.showPage("launcher") }
        function close() { ShellState.showPage(window.getDefaultPage()) }
    }

    IpcHandler {
        target: "clipboard"
        function toggle(): void {
            ShellState.activePage === "clipboard" ? ShellState.showPage(window.getDefaultPage()) : ShellState.showPage("clipboard")
        }
        function open(): void { ShellState.showPage("clipboard") }
        function close() { ShellState.showPage(window.getDefaultPage()) }
    }

    IpcHandler {
        target: "power"
        function toggle() { ShellState.activePage === "power" ? ShellState.showPage(window.getDefaultPage()) : ShellState.showPage("power") }
        function open() { ShellState.showPage("power") }
        function close() { ShellState.showPage(window.getDefaultPage()) }
    }

    IpcHandler {
        target: "controlcenter"
        function toggle(): void { ShellState.activePage === "control" ? ShellState.showPage(window.getDefaultPage()) : ShellState.showPage("control") }
        function open() { ShellState.showPage("control") }
        function close() { ShellState.showPage(window.getDefaultPage()) }
    }

    IpcHandler {
        target: "notificationcenter"
        function toggle(): void { ShellState.activePage === "notificationcenter" ? ShellState.showPage(window.getDefaultPage()) : ShellState.showPage("notificationcenter") }
        function open() { ShellState.showPage("notificationcenter") }
        function close() { ShellState.showPage(window.getDefaultPage()) }
    }

    IpcHandler {
        target: "themeswitcher"
        function toggle() { ShellState.activePage === "theme" ? ShellState.showPage(window.getDefaultPage()) : ShellState.showPage("theme") }
        function open() { ShellState.showPage("theme") }
        function close() { ShellState.showPage(window.getDefaultPage()) }
    }

    IpcHandler {
        target: "wallpaper"
        function toggle(): void {
            WallpaperService.isOpen = !WallpaperService.isOpen
            if (WallpaperService.isOpen) {
                ShellState.showPage("wallpaper")
            } else {
                ShellState.showPage(window.getDefaultPage())
            }
        }
    }

    IpcHandler {
        target: "timer"
        function toggle() { ShellState.activePage === "timer" ? ShellState.showPage(window.getDefaultPage()) : ShellState.showPage("timer") }
        function open() { ShellState.showPage("timer") }
        function close() { ShellState.showPage(window.getDefaultPage()) }
    }

    // ============================================================
    // 5. CLICK CATCHER AND HOVER ZONE
    // ============================================================

    Rectangle {
        id: clickCatcher
        anchors.fill: parent
        color: "transparent"
        visible: island.expanded && ShellState.islandClickOutsideDismiss

        MouseArea {
            anchors.fill: parent
            onClicked: ShellState.showPage(window.getDefaultPage())
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

    // ============================================================
    // 6. ISLAND BACKGROUND: SHAPE AND SHADOW
    // ============================================================

    // The fill for every style. It morphs between island and notch with the island's style progress,
    // and follows the island's size and (animated) corner radius.
    IslandShape {
        id: islandShape
        anchors.horizontalCenter: parent.horizontalCenter
        y: island.anchors.topMargin
        z: -1
        bodyWidth: island.width
        bodyHeight: island.height
        topRadius: island.radius
        bottomRadius: island.radius
        flare: ShellState.islandNotchFlare
        progress: island.styleProgress
        fillColor: Colors.mainBgMica
    }

    // islandShadowSource is an exact-shape, exact-position copy of the island (same anchors, same
    // size, same radius) sitting directly behind it. MultiEffect's autoPaddingEnabled grows the
    // effect's rendered bounds beyond the source automatically, so there is no fixed pixel margin to
    // guess. shadowScale grows the shadow shape itself before blurring, which pushes the halo out
    // past the left and right edges (shadowBlur alone only softens the edge). The island, painted
    // on top at identical geometry, covers the crisp unblurred centre completely.
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

    // ============================================================
    // 7. THE ISLAND
    // ============================================================

    Rectangle {
        id: island

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: island.styleMargin + island.hideOffset + island.moveDown
        clip: true
        // The fill is drawn by islandShape; the island itself only clips its content and draws the border.
        color: "transparent"
        radius: ShellState.islandCornerRadius
        border.color: Colors.border
        border.width: Math.max(0, 1 - island.styleProgress) * ShellState.islandBorderWidth

        // Radius changes are a short plain ease, never a bounce.
        Behavior on radius {
            NumberAnimation {
                duration: ShellState.motionDuration(Motion.glideMs * 0.85)
                easing.type: Easing.OutCubic
            }
        }

        // ---------- Page kinds ----------

        // NOTE: "notificationtoast" below is an old page name (the real page is "notification"), so a
        // notification popup still counts as expanded and gets the minimum expanded size.
        // Compact popups keep that behaviour on purpose; Detailed and Interactive size themselves.
        readonly property bool expanded: ShellState.activePage !== "clock"
                       && ShellState.activePage !== "timertoast"
                       && ShellState.activePage !== "notificationtoast"
                       && ShellState.activePage !== "eventtoast"
                       && ShellState.activePage !== "apptoast"
                       && ShellState.activePage !== "volume"
                       && ShellState.activePage !== "brightness"
                       && ShellState.activePage !== "settings"
                       && ShellState.activePage !== "lock"
                       && ShellState.activePage !== "polkit"
        readonly property int compactHeight: ShellState.islandCompactHeight
        readonly property int compactWidth: ShellState.islandCompactWidth

        // Pages that size themselves from their own content, so the minimum expanded size does not apply:
        // the Detailed and Interactive notification popups, the hover panel, the launcher and the clipboard.
        readonly property bool sizesItself: ShellState.activePage === "hover"
            || ShellState.activePage === "launcher"
            || ShellState.activePage === "clipboard"
            || ShellState.activePage === "control"
            || (ShellState.activePage === "notification" && ShellState.notificationPopupStyle !== "Compact")
    
        // ---------- 7a. Size ----------
        // The size the current page wants.
        property int targetWidth: {
            const page = pageLoader.item as Item
            if (!page) return compactWidth
            var floor = (expanded && !sizesItself) ? ShellState.islandMinExpandedWidth : compactWidth
            return Math.max(page.implicitWidth, floor)
        }
        property int targetHeight: {
            if (!pageLoader.item) return compactHeight
            var floor = (expanded && !sizesItself) ? ShellState.islandExpandedHeight : compactHeight
            return Math.max(pageLoader.implicitHeight, floor)
        }

        // The size the page morph has reached. It is animated by hand so the curve can depend on the
        // direction: growing uses OutBack (a quick start, a small overshoot, a soft settle); shrinking
        // uses an ease-out with no overshoot, so the island never dips below its true size.
        property real animWidth: 0
        property real animHeight: 0
        property bool _sized: false

        // The size on screen: the morph plus the magnify (7c).
        width: Math.max(0, Math.round(animWidth + island.extraWidth))
        height: Math.max(0, Math.round(animHeight + island.extraHeight))

        Component.onCompleted: {
            island.animWidth = island.targetWidth
            island.animHeight = island.targetHeight
            island._sized = true
        }

        onTargetWidthChanged: if (island._sized)
            island._morph(widthAnim, "animWidth", island.animWidth, island.targetWidth, ShellState.motionIslandOvershoot())
        onTargetHeightChanged: if (island._sized)
            island._morph(heightAnim, "animHeight", island.animHeight, island.targetHeight, ShellState.motionIslandOvershoot() * 0.85)

        function _morph(anim, prop, from, to, overshoot) {
            anim.stop()
            if (Math.abs(to - from) < 0.5) {
                island[prop] = to
                return
            }
            anim.from = from
            anim.to = to
            if (to > from) {
                anim.easing.type = Easing.OutBack
                anim.easing.overshoot = overshoot
                anim.duration = ShellState.motionDuration(Motion.glideMs)
            } else {
                anim.easing.type = Easing.BezierSpline
                anim.easing.bezierCurve = [0.15, 1.0, 0.05, 1.0, 1, 1]
                anim.duration = ShellState.motionDuration(Motion.glideMs * 0.75)
            }
            anim.restart()
        }

        NumberAnimation { id: widthAnim; target: island; property: "animWidth" }
        NumberAnimation { id: heightAnim; target: island; property: "animHeight" }

        // ---------- 7b. Style (island <-> notch) ----------
        // 0 = floating island, 1 = notch. It animates when the style changes, and the shape, the top
        // margin and the border all follow it. A future Bar style adds a second progress here.
        property real styleProgress: ShellState.islandNotchMode ? 1 : 0

        Behavior on styleProgress {
            NumberAnimation {
                duration: ShellState.motionDuration(Motion.glideMs)
                easing.type: Easing.OutBack
                easing.overshoot: ShellState.motionIslandOvershoot() * 0.6
            }
        }

        // The gap above the island: the full margin as an island, none as a notch.
        readonly property real styleMargin: (1 - island.styleProgress) * ShellState.islandTopMargin

        // ---------- 7c. Magnify on hover ----------
        // 0 = normal, 1 = magnified. The island gets wider (left and right), longer (at the bottom) and drops
        // a little, as if the pointer were magnifying it. The notch stays attached to the top edge, so the
        // drop fades out as the style goes to notch. It is a plain ease, so it never squeezes below its size.
        property real magnifyProgress: window.magnifyActive ? 1 : 0

        Behavior on magnifyProgress {
            NumberAnimation {
                duration: ShellState.motionDuration(Motion.glideMs * 0.6)
                easing.type: Easing.OutCubic
            }
        }

        readonly property real extraWidth: island.magnifyProgress * ShellState.islandMagnifyWidth
        readonly property real extraHeight: island.magnifyProgress * ShellState.islandMagnifyHeight
        readonly property real moveDown: island.magnifyProgress * ShellState.islandMagnifyMoveDown * (1 - island.styleProgress)

        // ---------- 7d. Visibility (auto-hide) ----------
        // Hidden: parked above the screen edge, far enough that the shadow halo clears it too.
        property real hideOffset: window.islandHidden
            ? -(island.height + ShellState.islandTopMargin + Dimens.paddingLarge * 4)
            : 0

        Behavior on hideOffset {
            NumberAnimation {
                duration: ShellState.motionDuration(Motion.glideMs)
                easing.type: Easing.OutCubic
            }
        }

        // ---------- 7e. Pointer input ----------
        MouseArea {
            id: islandTapArea
            anchors.fill: parent
            enabled: ShellState.activePage === "clock" || ShellState.activePage === "timertoast"
            // Without this, containsMouse is only true while a button is pressed,
            // so the hover effects never played on plain hover.
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            // Wheel gestures: top half = volume, bottom half = brightness. Wheel deltas arrive in
            // units of 120 per notch; touchpads send many small ones, so they are accumulated.
            property real wheelAccumulator: 0
            onWheel: (wheel) => {
                // Scrolling means you are using the island, so the wait for the hover panel starts over.
                if (window.dwellActive) dwellTimer.restart()

                wheelAccumulator += wheel.angleDelta.y
                var steps = Math.trunc(wheelAccumulator / 120)
                if (steps === 0) return
                wheelAccumulator -= steps * 120

                var topHalf = wheel.y < height / 2
                var up = steps > 0
                var count = Math.abs(steps)
                for (let i = 0; i < count; i++) {
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

        // While the hover panel is open it closes a moment after the pointer leaves the island.
        HoverHandler {
            id: islandPointer
            onHoveredChanged: {
                if (!window.hoverPageOpen) return
                if (hovered) hoverCloseTimer.stop()
                else hoverCloseTimer.restart()
            }
        }

        MouseArea {
            id: islandConsumeArea
            anchors.fill: parent
            enabled: island.expanded
            onClicked: {}
        }

        // A thin line that grows along the bottom of the island while you wait for the hover panel.
        Rectangle {
            id: dwellHint
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            z: 5
            height: 2
            radius: 1
            color: Colors.accent
            opacity: 0.85
            width: 0
            visible: window.dwellActive && ShellState.hoverPanelShowHint && !ShellState.motionReduced

            NumberAnimation on width {
                running: dwellHint.visible
                from: 0
                to: island.width * 0.6
                duration: ShellState.hoverPanelDelayMs
                easing.type: Easing.InOutSine
            }
        }

        // ---------- 7f. Page loader ----------
        Loader {
            id: pageLoader
            anchors.top: parent.top
            // While the island grows downwards, half of the extra height goes above the content, so it stays centred.
            anchors.topMargin: island.extraHeight / 2
            anchors.horizontalCenter: parent.horizontalCenter
            // In Bar style the idle page fills the bar, so it can lay its zones out from edge to edge.
            width: window.barStyle ? island.width : implicitWidth
            // The content grows with the island, by half as much, so the magnify reads as one effect.
            scale: 1 + island.magnifyProgress * (ShellState.islandMagnifyWidth / Math.max(1, island.animWidth)) * 0.5
            opacity: 1.0

            // Content entrance: the island leads, the content follows after Motion.contentDelayMs.
            onItemChanged: {
                const page = item as Item
                if (page) {
                    contentAnim.stop()
                    page.opacity = 0
                    page.scale = 0.94
                    contentAnim.start()
                }
            }

            SequentialAnimation {
                id: contentAnim
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
                        easing.type: Easing.OutBack
                        easing.overshoot: ShellState.motionIslandOvershoot() * 0.8
                    }
                }
            }

            // The page router: which page ShellState.activePage shows.
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
                    case "apptoast": return appToastPage
                    case "hover": return hoverPage
                    default: return clockPage
                }
            }
        }

        // ============================================================
        // 8. PAGE COMPONENTS
        // ============================================================

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
        Component { id: statusPage; Dashboard {} }
        Component { id: appToastPage; AppToast {} }
        Component { id: hoverPage; HoverPanel {} }

        Component {
            id: brightnessPage
            LevelIndicator {
                iconSource: window.iconDir + "brightness-" + window.brightnessTier(BrightnessService.percent) + ".png"
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