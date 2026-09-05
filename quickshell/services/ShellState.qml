// services/ShellState.qml
pragma Singleton
import QtQuick
import Quickshell.Io
import "../settings"

QtObject {
    id: root

    // File Persistence Helper
    property StatePersistence persistence: StatePersistence { id: serializer }

    property string activePage: "clock"
    property string previousPage: "clock"
    property bool focusModeEnabled: false
    property string activeFocusMode: "Do Not Disturb"
    property bool ignoreHover: false
    property bool settingsOpen: false

    // ================= BAR & ISLAND PROPERTIES =================
    property real islandTopMargin: 5; onIslandTopMarginChanged: serializer.triggerSave()
    property real islandCornerRadius: 12; onIslandCornerRadiusChanged: serializer.triggerSave()
    property real islandBorderWidth: 0; onIslandBorderWidthChanged: serializer.triggerSave()
    property bool islandClickOutsideDismiss: true; onIslandClickOutsideDismissChanged: serializer.triggerSave()
    property bool islandNotchMode: false; onIslandNotchModeChanged: serializer.triggerSave()
    property real islandNotchFlare: 14; onIslandNotchFlareChanged: serializer.triggerSave()

    property real islandCompactHeight: 36; onIslandCompactHeightChanged: serializer.triggerSave()
    property real islandCompactWidth: 160; onIslandCompactWidthChanged: serializer.triggerSave()
    property real islandExpandedHeight: 135; onIslandExpandedHeightChanged: serializer.triggerSave()
    property real islandMinExpandedWidth: 619; onIslandMinExpandedWidthChanged: serializer.triggerSave()

    // ================= MODULE SIZING PROPERTIES =================
    property real launcherWidth: 420; onLauncherWidthChanged: serializer.triggerSave()
    property int launcherMaxRows: 7; onLauncherMaxRowsChanged: serializer.triggerSave()

    property real clipboardWidth: 420; onClipboardWidthChanged: serializer.triggerSave()
    property int clipboardMaxRows: 6; onClipboardMaxRowsChanged: serializer.triggerSave()

    property real controlCenterWidth: 580; onControlCenterWidthChanged: serializer.triggerSave()
    property real controlCenterHeight: 400; onControlCenterHeightChanged: serializer.triggerSave()

    property real notificationCenterWidth: 360; onNotificationCenterWidthChanged: serializer.triggerSave()
    property real notificationCenterMaxHeight: 480; onNotificationCenterMaxHeightChanged: serializer.triggerSave()

    property real powerMenuWidth: 320; onPowerMenuWidthChanged: serializer.triggerSave()
    property real powerMenuHeight: 76; onPowerMenuHeightChanged: serializer.triggerSave()

    property real statusPanelWidth: 520; onStatusPanelWidthChanged: serializer.triggerSave()
    property real statusPanelHeight: 172; onStatusPanelHeightChanged: serializer.triggerSave()

    property real timerWidth: 320; onTimerWidthChanged: serializer.triggerSave()
    property real timerHeight: 180; onTimerHeightChanged: serializer.triggerSave()

    // ================= MOTION & ANIMATIONS =================
    property bool motionReduced: false; onMotionReducedChanged: serializer.triggerSave()
    property real motionMovementMs: 480; onMotionMovementMsChanged: serializer.triggerSave()
    property real motionFadeMs: 220; onMotionFadeMsChanged: serializer.triggerSave()
    property real motionHoverMs: 250; onMotionHoverMsChanged: serializer.triggerSave()
    property real motionBouncePercent: 20; onMotionBouncePercentChanged: serializer.triggerSave()

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
}