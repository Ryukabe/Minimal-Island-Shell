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

    property Timer hoverResetTimer: Timer {
        interval: 300
        repeat: false
        onTriggered: root.ignoreHover = false
    }

    property Timer flashTimer: Timer {
        interval: 1500
        onTriggered: {
            if (root.previousPage === "timer") {
                root.activePage = "timer"
            } else if (root.previousPage && root.previousPage !== "timertoast") {
                root.activePage = root.previousPage
            } else {
                root.activePage = "clock"
            }
        }
    }

    function showPage(page) {
        flashTimer.stop()
        if (page !== "notification") {
            root.previousPage = page
        }
        if (page === "clock" || page === "timertoast") {
            root.ignoreHover = true
            hoverResetTimer.restart()
        }
        root.activePage = page
    }

    function flashPage(page) {
        if (root.activePage !== "notification" && root.activePage !== page) {
            root.previousPage = root.activePage
        }
        root.activePage = page
        flashTimer.interval = 1500
        flashTimer.restart()
    }

    function flashPageFor(page, durationMs) {
        if (root.activePage !== "notification" && root.activePage !== page) {
            root.previousPage = root.activePage
        }
        root.activePage = page
        flashTimer.interval = durationMs
        flashTimer.restart()
    }

    function togglePage(page) {
        if (root.activePage === page) {
            showPage("clock")
        } else {
            showPage(page)
        }
    }

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
        if (root.focusModeEnabled) {
            _applyBackendForMode(root.activeFocusMode, false)
        }
        root.activeFocusMode = name
        root.focusModeEnabled = true
        _applyBackendForMode(name, true)
    }

    property Process dndProcess: Process {
        id: dndProcess
    }

    function toggleClipboard() {
        togglePage("clipboard")
    }
}