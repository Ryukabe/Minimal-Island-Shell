// services/ShellState.qml
pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string activePage: "clock"
    property string previousPage: "clock"
    property bool focusModeEnabled: false
    property string activeFocusMode: "Do Not Disturb"
    property bool ignoreHover: false
    property bool settingsOpen: false

    // ================= BAR & ISLAND PROPERTIES =================
    property real islandTopMargin: 5
    property real islandCornerRadius: 12
    property real islandBorderWidth: 0
    property bool islandClickOutsideDismiss: true
    property bool islandNotchMode: false
    property real islandNotchFlare: 14

    property real islandCompactHeight: 36
    property real islandCompactWidth: 160
    property real islandExpandedHeight: 135
    property real islandMinExpandedWidth: 619

    // ================= MODULE SIZING PROPERTIES =================
    property real launcherWidth: 420
    property int launcherMaxRows: 7

    property real clipboardWidth: 420
    property int clipboardMaxRows: 6

    property real controlCenterWidth: 580
    property real controlCenterHeight: 400

    property real notificationCenterWidth: 360
    property real notificationCenterMaxHeight: 480

    property real powerMenuWidth: 320
    property real powerMenuHeight: 76

    property real statusPanelWidth: 520
    property real statusPanelHeight: 172

    property real timerWidth: 320
    property real timerHeight: 180

        // ================= MOTION & ANIMATIONS =================
    property bool motionReduced: false
    property real motionMovementMs: 480
    property real motionFadeMs: 220
    property real motionHoverMs: 250
    property real motionBouncePercent: 20
    property bool motionSpringEnabled: false

    // Keeps Hyprland's own window-manager animations (workspace switches,
    // window open/close, etc.) in sync with the shell's Reduce Motion
    // toggle. This only flips Hyprland's global animations:enabled switch
    // — it never touches which preset is selected in
    // HyprlandAnimationsService, so turning Reduce Motion back off
    // restores whatever preset was already active instead of resetting it.
    onMotionReducedChanged: HyprlandAnimationsService.setEnabled(!motionReduced)

    function motionDuration(ms) {
        return root.motionReduced ? 0 : ms
    }

    function motionOvershoot() {
        return root.motionReduced ? 1.0 : (1.0 + root.motionBouncePercent / 100)
    }

    function springStiffness() {
        var t = Math.max(50, Math.min(400, root.motionHoverMs))
        var normalized = 1 - (t - 50) / (400 - 50)
        return 2.0 + normalized * 4.0
    }

    function springDamping() {
        var b = Math.max(0, Math.min(100, root.motionBouncePercent))
        return 0.5 - (b / 100) * 0.35
    }
    
    // ================= TIMERS & HELPERS =================
    property Timer hoverResetTimer: Timer {
        interval: 300
        repeat: false
        onTriggered: root.ignoreHover = false
    }

    property Timer flashTimer: Timer {
        interval: 1500
        onTriggered: {
            if (root.previousPage === "control" || root.previousPage === "clock" || root.previousPage === "timertoast") {
                root.activePage = root.previousPage
            } else {
                root.activePage = (TimerService.running || TimerService.secondsRemaining > 0) ? "timertoast" : "clock"
            }
        }
    }

    function showPage(page) {
        flashTimer.stop()
        if (page !== "notification") root.previousPage = page
        if (page === "clock" || page === "timertoast") {
            root.ignoreHover = true
            hoverResetTimer.restart()
        }
        root.activePage = page
    }

    function flashPage(page) {
        if (root.activePage !== "notification" && root.activePage !== page) root.previousPage = root.activePage
        root.activePage = page
        flashTimer.interval = 1500
        flashTimer.restart()
    }

    function flashPageFor(page, durationMs) {
        if (root.activePage !== "notification" && root.activePage !== page) root.previousPage = root.activePage
        root.activePage = page
        flashTimer.interval = durationMs
        flashTimer.restart()
    }

    function togglePage(page) {
        if (root.activePage === page) {
            showPage((TimerService.running || TimerService.secondsRemaining > 0) ? "timertoast" : "clock")
        } else {
            showPage(page)
        }
    }

    function openSettings() { root.settingsOpen = true }
    function closeSettings() { root.settingsOpen = false }
    function toggleSettings() { root.settingsOpen = !root.settingsOpen }

    function _applyBackendForMode(mode, enabled) {
        if (mode === "Do Not Disturb") {
            dndProcess.command = enabled
                ? ["makoctl", "mode", "-a", "do-not-disturb"]
                : ["makoctl", "mode", "-r", "do-not-disturb"]
            dndProcess.running = true
        }
    }

    function toggleFocusMode() {
        focusModeEnabled = !focusModeEnabled
        _applyBackendForMode(activeFocusMode, focusModeEnabled)
    }

    function setFocusMode(name) {
        if (root.focusModeEnabled && root.activeFocusMode === name) {
            toggleFocusMode()
            return
        }
        if (root.focusModeEnabled) _applyBackendForMode(root.activeFocusMode, false)
        root.activeFocusMode = name
        root.focusModeEnabled = true
        _applyBackendForMode(name, true)
    }

    property Process dndProcess: Process { id: dndProcess }

    function toggleClipboard() { togglePage("clipboard") }

    Component.onCompleted: {
        // Sync Hyprland's animation switch to whatever motionReduced was
        // restored to at startup (e.g. if it was left true from a
        // previous session), rather than waiting for the next toggle.
        HyprlandAnimationsService.setEnabled(!motionReduced)
    }
}