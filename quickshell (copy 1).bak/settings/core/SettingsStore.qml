// SettingsStore.qml — persists every key in ShellState.defaults to disk.
// ShellState owns the key list and the default values; this file only loads, saves and resets.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../../services"

Item {
    id: root

    readonly property string settingsPath: Quickshell.env("HOME") + "/.config/quickshell/state/shell-settings.json"

    property bool _loaded: false
    property bool _applying: false

    function _defaults() {
        return JSON.parse(JSON.stringify(ShellState.defaults))
    }

    // Bar/Island/module-sizing subset of the defaults — lets the Bar page's reset
    // button reset just its own keys instead of nuking Motion/Clock/Typography too.
    readonly property var barKeys: [
        "islandTopMargin", "islandCornerRadius", "islandBorderWidth",
        "islandClickOutsideDismiss", "islandNotchMode", "islandNotchFlare",
        "islandHoverScale", "radiusUniversal", "customRadiusCard",
        "customRadiusControl", "customRadiusChip",
        "islandCompactHeight", "islandCompactWidth",
        "islandExpandedHeight", "islandMinExpandedWidth",
        "islandAlwaysVisible", "islandRevealOnHover", "islandRevealZone",
        "islandHideDelayMs", "islandScrollVolume", "islandScrollBrightness",
        "launcherWidth", "launcherMaxRows", "clipboardWidth", "clipboardMaxRows",
        "controlCenterWidth", "controlCenterHeight",
        "notificationCenterWidth", "notificationCenterMaxHeight",
        "powerMenuWidth", "powerMenuHeight",
        "statusPanelWidth", "statusPanelHeight",
        "timerWidth", "timerHeight"
    ]

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

    // Resets only the given keys back to their defaults, then saves once.
    function resetKeys(keys) {
        const defaults = root._defaults()
        root._applying = true
        for (let i = 0; i < keys.length; i++) {
            const key = keys[i]
            if (defaults[key] !== undefined && ShellState[key] !== undefined) {
                ShellState[key] = defaults[key]
            }
        }
        root._applying = false
        root._scheduleSave()
    }

    function resetBarDefaults() { resetKeys(root.barKeys) }

    // Full reset — every persisted key. Used by About's "Reset all to defaults".
    function resetAllDefaults() {
        root._applyToShellState(root._defaults())
        root._scheduleSave()
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

        // First run: no file yet. Keep ShellState's defaults and start saving.
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

    // One save trigger per key in ShellState.defaults, so a new setting only has to be added
    // to that table. A key with no matching ShellState property is reported, never skipped silently.
    Component.onCompleted: {
        Quickshell.execDetached(["mkdir", "-p", root.settingsPath.substring(0, root.settingsPath.lastIndexOf("/"))])
        const keys = Object.keys(ShellState.defaults)
        for (let i = 0; i < keys.length; i++) {
            const sig = ShellState[keys[i] + "Changed"]
            if (sig && sig.connect) sig.connect(root._scheduleSave)
            else console.warn("SettingsStore: ShellState has no property '" + keys[i] + "'")
        }
    }
}