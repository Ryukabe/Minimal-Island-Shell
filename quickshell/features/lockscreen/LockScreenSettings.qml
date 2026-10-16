// features/lockscreen/LockScreenSettings.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel
import "../../core/shell"

Item {
    id: root

    readonly property string _home: Quickshell.env("HOME")
    readonly property string configPath: root._home + "/.config/quickshell/state/lockscreen.json"

    property bool _configLoaded: false
    property bool _applyingConfig: false

    // Clock
    property bool clockFormat24h: true
    property bool showDate: true

    // Identity
    property bool showUsername: true

    // Password field
    property string passwordPlaceholder: "password"
    property bool shakeOnWrongPassword: true
    property bool errorUsesAccent: false

    // Background
    property real wallpaperDimOpacity: 0.35
    property bool frostedBlurEnabled: false
    property real frostedBlurRadius: 32
    property bool playEntranceAnimation: true

    // Notifications
    property bool showNotifications: true
    property int notificationLimit: 3

    // Nav actions
    property bool showHyprlandAction: true
    property bool showRebootAction: true
    property bool showPowerAction: true

    // Weather (the temperature unit lives in Language & Region: ShellState.weatherUnit)
    property bool showWeather: true
    property bool weatherShowHourly: true
    property bool weatherShowFeelsLike: true

    // Media
    property bool showMedia: true
    property bool mediaBlurBackdrop: true
    property bool mediaShowProgress: true
    property bool mediaHideDetails: false

    // Lock screen wallpaper
    property bool useOwnWallpaper: false
    property string wallpaperFolder: root._home + "/Pictures/Wallpapers"
    property string wallpaperFile: ""
    property var wallpaperList: []

    function folderUrl(p) {
        return "file://" + p.split("/").map(encodeURIComponent).join("/")
    }

    function normalizeFolder(p) {
        var t = (p || "").trim()
        if (t === "") return root._home + "/Pictures/Wallpapers"
        t = t.replace(/^~(?=\/|$)/, root._home)
        while (t.length > 1 && t.endsWith("/")) t = t.slice(0, -1)
        return t
    }

    function setWallpaperFolder(p) {
        root.wallpaperFolder = root.normalizeFolder(p)
    }

    // What the lock screen actually draws.
    readonly property string effectiveWallpaper: {
        if (!root.useOwnWallpaper) return WallpaperService.currentWallpaper
        var list = root.wallpaperList
        for (var i = 0; i < list.length; i++)
            if (list[i].path === root.wallpaperFile) return root.wallpaperFile
        return list.length > 0 ? list[0].path : WallpaperService.currentWallpaper
    }

    function _rebuildWallpapers() {
        var list = []
        for (var i = 0; i < lockFolderModel.count; i++) {
            var n = lockFolderModel.get(i, "fileName")
            list.push({ name: n, path: root.wallpaperFolder + "/" + n })
        }
        root.wallpaperList = list
    }

    FolderListModel {
        id: lockFolderModel
        folder: root.folderUrl(root.wallpaperFolder)
        showDirs: false
        showDotAndDotDot: false
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        onCountChanged: root._rebuildWallpapers()
        onStatusChanged: if (status === FolderListModel.Ready) root._rebuildWallpapers()
    }

    // Unknown keys in the file (like the old weatherFahrenheit) are ignored.
    function _apply(data) {
        root._applyingConfig = true
        if (data.clockFormat24h !== undefined) root.clockFormat24h = data.clockFormat24h;
        if (data.showDate !== undefined) root.showDate = data.showDate;
        if (data.showUsername !== undefined) root.showUsername = data.showUsername;
        if (data.passwordPlaceholder !== undefined) root.passwordPlaceholder = data.passwordPlaceholder;
        if (data.shakeOnWrongPassword !== undefined) root.shakeOnWrongPassword = data.shakeOnWrongPassword;
        if (data.errorUsesAccent !== undefined) root.errorUsesAccent = data.errorUsesAccent;
        if (data.wallpaperDimOpacity !== undefined) root.wallpaperDimOpacity = data.wallpaperDimOpacity;
        if (data.frostedBlurEnabled !== undefined) root.frostedBlurEnabled = data.frostedBlurEnabled;
        if (data.frostedBlurRadius !== undefined) root.frostedBlurRadius = data.frostedBlurRadius;
        if (data.playEntranceAnimation !== undefined) root.playEntranceAnimation = data.playEntranceAnimation;
        if (data.showNotifications !== undefined) root.showNotifications = data.showNotifications;
        if (data.notificationLimit !== undefined) root.notificationLimit = data.notificationLimit;
        if (data.showHyprlandAction !== undefined) root.showHyprlandAction = data.showHyprlandAction;
        if (data.showRebootAction !== undefined) root.showRebootAction = data.showRebootAction;
        if (data.showPowerAction !== undefined) root.showPowerAction = data.showPowerAction;
        if (data.useOwnWallpaper !== undefined) root.useOwnWallpaper = data.useOwnWallpaper;
        if (data.wallpaperFolder !== undefined) root.wallpaperFolder = data.wallpaperFolder;
        if (data.wallpaperFile !== undefined) root.wallpaperFile = data.wallpaperFile;
        if (data.showWeather !== undefined) root.showWeather = data.showWeather;
        if (data.weatherShowHourly !== undefined) root.weatherShowHourly = data.weatherShowHourly;
        if (data.weatherShowFeelsLike !== undefined) root.weatherShowFeelsLike = data.weatherShowFeelsLike;
        if (data.showMedia !== undefined) root.showMedia = data.showMedia;
        if (data.mediaBlurBackdrop !== undefined) root.mediaBlurBackdrop = data.mediaBlurBackdrop;
        if (data.mediaShowProgress !== undefined) root.mediaShowProgress = data.mediaShowProgress;
        if (data.mediaHideDetails !== undefined) root.mediaHideDetails = data.mediaHideDetails;
        root._applyingConfig = false
    }

    FileView {
        id: configFile
        path: root.configPath
        watchChanges: true
        onLoaded: {
            try {
                root._apply(JSON.parse(text()));
            } catch (e) {
                console.log("[LockScreenSettings] parse error:", e);
            }
            root._configLoaded = true
        }
        // First run: no file yet. Without this, save() would never be allowed.
        onLoadFailed: root._configLoaded = true
    }

    Process { id: saveProcess }

    function save() {
        if (!root._configLoaded || root._applyingConfig) return;
        var data = {
            "clockFormat24h": root.clockFormat24h,
            "showDate": root.showDate,
            "showUsername": root.showUsername,
            "passwordPlaceholder": root.passwordPlaceholder,
            "shakeOnWrongPassword": root.shakeOnWrongPassword,
            "errorUsesAccent": root.errorUsesAccent,
            "wallpaperDimOpacity": root.wallpaperDimOpacity,
            "frostedBlurEnabled": root.frostedBlurEnabled,
            "frostedBlurRadius": root.frostedBlurRadius,
            "playEntranceAnimation": root.playEntranceAnimation,
            "showNotifications": root.showNotifications,
            "notificationLimit": root.notificationLimit,
            "showHyprlandAction": root.showHyprlandAction,
            "showRebootAction": root.showRebootAction,
            "showPowerAction": root.showPowerAction,
            "useOwnWallpaper": root.useOwnWallpaper,
            "wallpaperFolder": root.wallpaperFolder,
            "wallpaperFile": root.wallpaperFile,
            "showWeather": root.showWeather,
            "weatherShowHourly": root.weatherShowHourly,
            "weatherShowFeelsLike": root.weatherShowFeelsLike,
            "showMedia": root.showMedia,
            "mediaBlurBackdrop": root.mediaBlurBackdrop,
            "mediaShowProgress": root.mediaShowProgress,
            "mediaHideDetails": root.mediaHideDetails
        };
        // Values are passed as arguments, so quotes in a path can't break the command.
        saveProcess.command = ["sh", "-c",
            "mkdir -p \"$(dirname \"$2\")\"; printf '%s' \"$1\" > \"$2\"",
            "sh", JSON.stringify(data), root.configPath];
        saveProcess.running = true;
    }

    onClockFormat24hChanged: save()
    onShowDateChanged: save()
    onShowUsernameChanged: save()
    onPasswordPlaceholderChanged: save()
    onShakeOnWrongPasswordChanged: save()
    onErrorUsesAccentChanged: save()
    onWallpaperDimOpacityChanged: save()
    onFrostedBlurEnabledChanged: save()
    onFrostedBlurRadiusChanged: save()
    onPlayEntranceAnimationChanged: save()
    onShowNotificationsChanged: save()
    onNotificationLimitChanged: save()
    onShowHyprlandActionChanged: save()
    onShowRebootActionChanged: save()
    onShowPowerActionChanged: save()
    onUseOwnWallpaperChanged: save()
    onWallpaperFolderChanged: save()
    onWallpaperFileChanged: save()
    onShowWeatherChanged: save()
    onWeatherShowHourlyChanged: save()
    onWeatherShowFeelsLikeChanged: save()
    onShowMediaChanged: save()
    onMediaBlurBackdropChanged: save()
    onMediaShowProgressChanged: save()
    onMediaHideDetailsChanged: save()
}