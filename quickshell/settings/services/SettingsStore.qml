// settings/services/SettingsStore.qml — persists Bar & Island / Motion settings to disk
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
            motionReduced: false,
            motionMovementMs: 480,
            motionFadeMs: 220,
            motionHoverMs: 250,
            motionBouncePercent: 20
        }
    }

    function _applyToShellState(obj) {
        root._applying = true
        ShellState.islandTopMargin = obj.islandTopMargin
        ShellState.islandCornerRadius = obj.islandCornerRadius
        ShellState.islandBorderWidth = obj.islandBorderWidth
        ShellState.islandClickOutsideDismiss = obj.islandClickOutsideDismiss
        ShellState.islandNotchMode = obj.islandNotchMode
        ShellState.islandNotchFlare = obj.islandNotchFlare
        ShellState.motionReduced = obj.motionReduced
        ShellState.motionMovementMs = obj.motionMovementMs
        ShellState.motionFadeMs = obj.motionFadeMs
        ShellState.motionHoverMs = obj.motionHoverMs
        ShellState.motionBouncePercent = obj.motionBouncePercent
        root._applying = false
    }

    function _collectFromShellState() {
        return {
            islandTopMargin: ShellState.islandTopMargin,
            islandCornerRadius: ShellState.islandCornerRadius,
            islandBorderWidth: ShellState.islandBorderWidth,
            islandClickOutsideDismiss: ShellState.islandClickOutsideDismiss,
            islandNotchMode: ShellState.islandNotchMode,
            islandNotchFlare: ShellState.islandNotchFlare,
            motionReduced: ShellState.motionReduced,
            motionMovementMs: ShellState.motionMovementMs,
            motionFadeMs: ShellState.motionFadeMs,
            motionHoverMs: ShellState.motionHoverMs,
            motionBouncePercent: ShellState.motionBouncePercent
        }
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
        interval: 200
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
        function onMotionReducedChanged() { root._scheduleSave() }
        function onMotionMovementMsChanged() { root._scheduleSave() }
        function onMotionFadeMsChanged() { root._scheduleSave() }
        function onMotionHoverMsChanged() { root._scheduleSave() }
        function onMotionBouncePercentChanged() { root._scheduleSave() }
    }
}