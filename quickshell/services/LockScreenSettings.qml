// services/LockScreenSettings.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string configPath: Quickshell.env("HOME") + "/.config/quickshell/lockscreen.json"

    property bool _configLoaded: false
    property bool _applyingConfig: false

    // Clock
    property bool clockFormat24h: true
    property bool showDate: true

    // Identity
    property bool showUsername: true

    // Password field
    property string passwordPlaceholder: "password"

    // Background
    property real wallpaperDimOpacity: 0.35
    property bool frostedBlurEnabled: false
    property real frostedBlurRadius: 32

    // Nav actions
    property bool showHyprlandAction: true
    property bool showRebootAction: true
    property bool showPowerAction: true

    // Error/accent
    property bool errorUsesAccent: false

    FileView {
        id: configFile
        path: root.configPath
        watchChanges: true
        onLoaded: {
            root._applyingConfig = true
            try {
                var data = JSON.parse(text());
                if (data.clockFormat24h !== undefined) root.clockFormat24h = data.clockFormat24h;
                if (data.showDate !== undefined) root.showDate = data.showDate;
                if (data.showUsername !== undefined) root.showUsername = data.showUsername;
                if (data.passwordPlaceholder !== undefined) root.passwordPlaceholder = data.passwordPlaceholder;
                if (data.wallpaperDimOpacity !== undefined) root.wallpaperDimOpacity = data.wallpaperDimOpacity;
                if (data.frostedBlurEnabled !== undefined) root.frostedBlurEnabled = data.frostedBlurEnabled;
                if (data.frostedBlurRadius !== undefined) root.frostedBlurRadius = data.frostedBlurRadius;
                if (data.showHyprlandAction !== undefined) root.showHyprlandAction = data.showHyprlandAction;
                if (data.showRebootAction !== undefined) root.showRebootAction = data.showRebootAction;
                if (data.showPowerAction !== undefined) root.showPowerAction = data.showPowerAction;
                if (data.errorUsesAccent !== undefined) root.errorUsesAccent = data.errorUsesAccent;
            } catch (e) {
                console.log("[LockScreenSettings] parse error:", e);
            }
            root._applyingConfig = false
            root._configLoaded = true
        }
        onLoadFailed: error => {
            root._configLoaded = true
        }
    }

    Process { id: saveProcess }

    function save() {
        if (!root._configLoaded || root._applyingConfig) return;
        var data = {
            "clockFormat24h": root.clockFormat24h,
            "showDate": root.showDate,
            "showUsername": root.showUsername,
            "passwordPlaceholder": root.passwordPlaceholder,
            "wallpaperDimOpacity": root.wallpaperDimOpacity,
            "frostedBlurEnabled": root.frostedBlurEnabled,
            "frostedBlurRadius": root.frostedBlurRadius,
            "showHyprlandAction": root.showHyprlandAction,
            "showRebootAction": root.showRebootAction,
            "showPowerAction": root.showPowerAction,
            "errorUsesAccent": root.errorUsesAccent
        };
        saveProcess.command = ["sh", "-c", "mkdir -p ~/.config/quickshell && echo '" + JSON.stringify(data) + "' > " + root.configPath];
        saveProcess.running = true;
    }

    onClockFormat24hChanged: save()
    onShowDateChanged: save()
    onShowUsernameChanged: save()
    onPasswordPlaceholderChanged: save()
    onWallpaperDimOpacityChanged: save()
    onFrostedBlurEnabledChanged: save()
    onFrostedBlurRadiusChanged: save()
    onShowHyprlandActionChanged: save()
    onShowRebootActionChanged: save()
    onShowPowerActionChanged: save()
    onErrorUsesAccentChanged: save()
}