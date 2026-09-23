// services/WallpaperService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel
import "../services"

Item {
    id: root

    property var wallpapersList: []
    property string currentWallpaper: ""
    property bool isOpen: false
    property bool autoSwitchOnThemeChange: true

    property bool _lookupFound: false
    property string _lookupThemeName: ""

    // Captured at the moment applyWallpaper() is called, so the async
    // apply + persist chain always writes the theme/path pair that was
    // actually requested — even if ThemeService.currentTheme or
    // root.currentWallpaper change again before "awww" exits.
    property string _pendingPersistTheme: ""
    property string _pendingPersistPath: ""

    readonly property string wallpapersPath: Quickshell.shellDir + "/assets/wallpapers/" + ThemeService.currentTheme
    readonly property string wallpaperStatePath: Quickshell.shellDir + "/assets/wallpapers/.wallpaper-state"
    readonly property string autoSwitchStatePath: Quickshell.shellDir + "/assets/wallpapers/.autoswitch"

    onWallpapersPathChanged: rescanList()

    Component.onCompleted: {
        loadAutoSwitchProc.running = true
        rescanList()
        // Restore the last-used wallpaper for whatever theme is already active.
        // Deferred one tick so other singletons (ThemeService) have a chance to
        // finish their own Component.onCompleted first — see caveat below.
        Qt.callLater(function() {
            if (ThemeService.currentTheme) {
                switchToThemeWallpaper(ThemeService.currentTheme)
            }
        })
    }

    function rescanList() {
        folderModel.folder = "file://" + root.wallpapersPath
    }

    FolderListModel {
        id: folderModel
        folder: "file://" + root.wallpapersPath
        showDirs: false
        showFiles: true
        nameFilters: ["*.jpg", "*.jpeg", "*.png"]
        showDotAndDotDot: false
        onCountChanged: updateWallpapers()
        onStatusChanged: {
            if (folderModel.status === FolderListModel.Ready) updateWallpapers()
        }
    }

    function updateWallpapers() {
        var list = []
        for (var i = 0; i < folderModel.count; i++) {
            var fileName = folderModel.get(i, "fileName")
            var filePath = root.wallpapersPath + "/" + fileName
            list.push({ name: fileName, path: filePath })
        }
        wallpapersList = list
    }

    // Explicit entry point called by ThemeService whenever the active theme changes.
    function switchToThemeWallpaper(themeName) {
        if (!themeName) return
        root._lookupThemeName = themeName
        root._lookupFound = false
        lookupProc._forTheme = themeName
        lookupProc.command = ["bash", "-c", "grep '^" + themeName + ":' '" + root.wallpaperStatePath + "' 2>/dev/null | cut -d: -f2-"]
        lookupProc.running = true
    }

    Process {
        id: lookupProc
        property string _forTheme: ""
        stdout: SplitParser {
            onRead: data => {
                // A newer switchToThemeWallpaper() call superseded this one — drop it.
                if (lookupProc._forTheme !== root._lookupThemeName) return
                var path = data.trim()
                if (path.length === 0) return
                root._lookupFound = true
                if (root.autoSwitchOnThemeChange) {
                    root.applyWallpaper(path, lookupProc._forTheme)
                } else {
                    root.currentWallpaper = path
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (lookupProc._forTheme !== root._lookupThemeName) return // superseded
            if (!root._lookupFound) {
                fallbackFirstProc._forTheme = lookupProc._forTheme
                fallbackFirstProc.command = ["bash", "-c",
                    "ls '" + Quickshell.shellDir + "/assets/wallpapers/" + lookupProc._forTheme + "' 2>/dev/null | grep -Ei '\\.(jpg|jpeg|png)$' | sort | head -n1"]
                fallbackFirstProc.running = true
            }
        }
    }

    Process {
        id: fallbackFirstProc
        property string _forTheme: ""
        stdout: SplitParser {
            onRead: data => {
                if (fallbackFirstProc._forTheme !== root._lookupThemeName) return // superseded
                var fileName = data.trim()
                if (fileName.length === 0) return
                var fullPath = Quickshell.shellDir + "/assets/wallpapers/" + fallbackFirstProc._forTheme + "/" + fileName
                if (root.autoSwitchOnThemeChange) {
                    root.applyWallpaper(fullPath, fallbackFirstProc._forTheme)
                } else {
                    root.currentWallpaper = fullPath
                }
            }
        }
    }

    function applyWallpaper(wallpaperPath, themeName) {
        if (!wallpaperPath) return
        currentWallpaper = wallpaperPath
        root._pendingPersistTheme = (themeName !== undefined) ? themeName : ThemeService.currentTheme
        root._pendingPersistPath = wallpaperPath
        applyProcess.command = ["awww", "img", wallpaperPath]
        applyProcess.running = true
    }

    Process {
        id: applyProcess
        stdout: SplitParser {
            onRead: data => console.log("[WallpaperService] awww stdout:", data)
        }
        stderr: SplitParser {
            onRead: data => console.log("[WallpaperService] awww stderr:", data)
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                var persistTheme = root._pendingPersistTheme
                var persistPath = root._pendingPersistPath
                persistProc.command = ["bash", "-c",
                    "sed -i '/^" + persistTheme + ":/d' '" + root.wallpaperStatePath + "' 2>/dev/null; " +
                    "echo '" + persistTheme + ":" + persistPath + "' >> '" + root.wallpaperStatePath + "'"]
                persistProc.running = true
            } else {
                console.log("[WallpaperService] awww exited with code", exitCode, "— wallpaper not applied")
            }
        }
    }

    Process { id: persistProc }

    function setAutoSwitch(enabled) {
        root.autoSwitchOnThemeChange = enabled
        saveAutoSwitchProc.command = ["bash", "-c", "echo -n \"" + (enabled ? "true" : "false") + "\" > \"" + root.autoSwitchStatePath + "\""]
        saveAutoSwitchProc.running = true
    }

    Process { id: saveAutoSwitchProc }

    Process {
        id: loadAutoSwitchProc
        command: ["cat", root.autoSwitchStatePath]
        stdout: SplitParser {
            onRead: data => {
                var val = data.trim()
                if (val.length > 0) root.autoSwitchOnThemeChange = (val === "true")
            }
        }
    }
}