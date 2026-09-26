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
    property bool notificationPreviewsEnabled: true
    property bool ignoreHover: false
    property bool settingsOpen: false

    // ================= BAR & ISLAND PROPERTIES =================
    property real islandTopMargin: 5
    property real islandCornerRadius: 12
    property real islandBorderWidth: 0
    property bool islandClickOutsideDismiss: true
    property bool islandNotchMode: false
    property real islandNotchFlare: 14
    property real islandHoverScale: 1.02

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

    // ================= CLOCK =================
    // Single source of truth for the bar clock AND the Clock settings preview.
    // The two format strings below are derived — never persisted, never set by hand.
    property bool clockUse24Hour: false
    property bool clockShowSeconds: false
    property bool clockLeadingZero: true
    property bool clockLowercaseAmPm: false
    property int clockDateStyle: 0            // 0 = off, 1 = "ddd d", 2 = "ddd d MMM"
    property bool clockShowVisualizer: true
    property bool clockShowTimerIcon: true
    property bool clockShowRecordingIndicator: true
    property bool timerToastShowRecordingIndicator: true

    // 12-hour mode always includes an AM/PM token, which is what makes h/hh
    // render as 1-12 instead of 0-23.
    readonly property string clockTimeFormat: {
        const hour = clockUse24Hour
            ? (clockLeadingZero ? "HH" : "H")
            : (clockLeadingZero ? "hh" : "h")
        const seconds = clockShowSeconds ? ":ss" : ""
        const ampm = clockUse24Hour ? "" : (clockLowercaseAmPm ? " ap" : " AP")
        return hour + ":mm" + seconds + ampm
    }

    readonly property string clockDateFormat: clockDateStyle === 2 ? "ddd d MMM" : "ddd d"

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

    // Generalized spring-stiffness mapping: shorter user-set duration (ms)
    // -> higher stiffness (snappier convergence). minK/maxK are the actual
    // SpringAnimation.spring range a tier should produce (e.g. 250-550 for
    // the snap tier, 150-400 for the slower glide tier).
    function springStiffnessFor(ms, minMs, maxMs, minK, maxK) {
        var t = Math.max(minMs, Math.min(maxMs, ms))
        var normalized = 1 - (t - minMs) / (maxMs - minMs)
        return minK + normalized * (maxK - minK)
    }

    // Generalized damping mapping, shared "Bounce" slider: more bounce %
    // -> lower damping (more oscillation before settling). minD/maxD are
    // the actual SpringAnimation.damping range a tier should produce.
    function springDampingFor(minD, maxD) {
        var b = Math.max(0, Math.min(100, root.motionBouncePercent))
        return maxD - (b / 100) * (maxD - minD)
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

    // Hook for per-mode backend behavior (deferred: personal/work/calm
    // presets each changing wallpaper/theme/animations/border style — see
    // project notes). The previous mako-based Do Not Disturb implementation
    // has been removed from here: mako is gone from this project —
    // NotificationService.qml owns notifications directly and already
    // gates toast popups on focusModeEnabled itself, so calling makoctl
    // was commanding a daemon that isn't running. Nothing needs to happen
    // here for "Do Not Disturb" anymore; wire real per-mode backends here
    // as they get built.
    function _applyBackendForMode(mode, enabled) {
        // intentionally empty for now
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

    function toggleClipboard() { togglePage("clipboard") }

    Component.onCompleted: {
        // Sync Hyprland's animation switch to whatever motionReduced was
        // restored to at startup (e.g. if it was left true from a
        // previous session), rather than waiting for the next toggle.
        HyprlandAnimationsService.setEnabled(!motionReduced)
    }
}