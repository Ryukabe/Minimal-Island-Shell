// settings/services/SettingsStore.qml — persists all Bar/Island/Motion/panel-size settings to disk
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../../services"

Item {
    id: root

    readonly property string settingsPath: Quickshell.shellDir + "/settings/state.json"

    property bool _loaded: false
    property bool _applying: false

    function _defaults() {
        return {
            islandTopMargin: 5,
            islandCornerRadius: 12,
            islandBorderWidth: 0,
            islandClickOutsideDismiss: true,
            islandNotchMode: false,
            islandNotchFlare: 14,
            islandCompactHeight: 36,
            islandCompactWidth: 140,
            islandExpandedHeight: 80,
            islandMinExpandedWidth: 300,
            launcherWidth: 420,
            launcherMaxRows: 7,
            clipboardWidth: 420,
            clipboardMaxRows: 6,
            controlCenterWidth: 580,
            controlCenterHeight: 400,
            notificationCenterWidth: 360,
            notificationCenterMaxHeight: 480,
            powerMenuWidth: 370,
            powerMenuHeight: 75,
            statusPanelWidth: 520,
            statusPanelHeight: 172,
            timerWidth: 320,
            timerHeight: 180,
            motionReduced: false,
            motionMovementMs: 480,
            motionFadeMs: 220,
            motionHoverMs: 250,
            motionBouncePercent: 20
        }
    }

    function _applyToShellState(obj) {
        root._applying = true
        const defaults = root._defaults()
        for (let key in defaults) {
            if (obj[key] !== undefined && ShellState[key] !== undefined) {
                ShellState[key] = obj[key]
            }
        }
        root._applying = false
    }

    function _collectFromShellState() {
        const defaults = root._defaults()
        let out = {}
        for (let key in defaults) {
            out[key] = ShellState[key]
        }
        return out
    }

    function _scheduleSave() {
        if (!root._loaded || root._applying) return
        saveTimer.restart()
    }

    FileView {
        id: fileView
        path: root.settingsPath
        printErrors: false

        onLoaded: {
            try {
                root._applyToShellState(JSON.parse(text()))
            } catch (e) {
                root._applyToShellState(root._defaults())
            }
            root._loaded = true
        }

        onLoadFailed: (error) => {
            root._applyToShellState(root._defaults())
            root._loaded = true
        }
    }

    Timer {
        id: saveTimer
        interval: 250
        repeat: false
        onTriggered: fileView.setText(JSON.stringify(root._collectFromShellState(), null, 2))
    }

    Connections {
        target: ShellState
        function onIslandTopMarginChanged() { root._scheduleSave() }
        function onIslandCornerRadiusChanged() { root._scheduleSave() }
        function onIslandBorderWidthChanged() { root._scheduleSave() }
        function onIslandClickOutsideDismissChanged() { root._scheduleSave() }
        function onIslandNotchModeChanged() { root._scheduleSave() }
        function onIslandNotchFlareChanged() { root._scheduleSave() }
        function onIslandCompactHeightChanged() { root._scheduleSave() }
        function onIslandCompactWidthChanged() { root._scheduleSave() }
        function onIslandExpandedHeightChanged() { root._scheduleSave() }
        function onIslandMinExpandedWidthChanged() { root._scheduleSave() }
        function onLauncherWidthChanged() { root._scheduleSave() }
        function onLauncherMaxRowsChanged() { root._scheduleSave() }
        function onClipboardWidthChanged() { root._scheduleSave() }
        function onClipboardMaxRowsChanged() { root._scheduleSave() }
        function onControlCenterWidthChanged() { root._scheduleSave() }
        function onControlCenterHeightChanged() { root._scheduleSave() }
        function onNotificationCenterWidthChanged() { root._scheduleSave() }
        function onNotificationCenterMaxHeightChanged() { root._scheduleSave() }
        function onPowerMenuWidthChanged() { root._scheduleSave() }
        function onPowerMenuHeightChanged() { root._scheduleSave() }
        function onStatusPanelWidthChanged() { root._scheduleSave() }
        function onStatusPanelHeightChanged() { root._scheduleSave() }
        function onTimerWidthChanged() { root._scheduleSave() }
        function onTimerHeightChanged() { root._scheduleSave() }
        function onMotionReducedChanged() { root._scheduleSave() }
        function onMotionMovementMsChanged() { root._scheduleSave() }
        function onMotionFadeMsChanged() { root._scheduleSave() }
        function onMotionHoverMsChanged() { root._scheduleSave() }
        function onMotionBouncePercentChanged() { root._scheduleSave() }
    }
}