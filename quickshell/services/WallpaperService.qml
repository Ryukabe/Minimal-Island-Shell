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

    readonly property string wallpapersPath: Quickshell.shellDir + "/assets/wallpapers/" + ThemeService.currentTheme
    readonly property string wallpaperStatePath: Quickshell.shellDir + "/assets/wallpapers/.wallpaper-state"
    readonly property string autoSwitchStatePath: Quickshell.shellDir + "/assets/wallpapers/.autoswitch"

    onWallpapersPathChanged: rescanList()

    Component.onCompleted: {
        loadAutoSwitchProc.running = true
        rescanList()
    }

    function rescanList() {
        folderModel.folder = "file://" + root.wallpapersPath
    }

    FolderListModel {
        id: folderModel
        folder: "file://" + root.wallpapersPath
        showDirs: false
        showFiles: true
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
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
        root._lookupFound = false
        root._lookupThemeName = themeName
        lookupProc.command = ["bash", "-c", "grep '^" + themeName + ":' '" + root.wallpaperStatePath + "' 2>/dev/null | cut -d: -f2-"]
        lookupProc.running = true
    }

    Process {
        id: lookupProc
        stdout: SplitParser {
            onRead: data => {
                var path = data.trim()
                if (path.length === 0) return
                root._lookupFound = true
                if (root.autoSwitchOnThemeChange) {
                    root.applyWallpaper(path)
                } else {
                    root.currentWallpaper = path
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            // No saved entry for this theme — fall back to the first wallpaper in its folder.
            if (!root._lookupFound) {
                fallbackFirstProc.command = ["bash", "-c",
                    "ls '" + Quickshell.shellDir + "/assets/wallpapers/" + root._lookupThemeName + "' 2>/dev/null | grep -Ei '\\.(jpg|jpeg|png|webp)$' | sort | head -n1"]
                fallbackFirstProc.running = true
            }
        }
    }

    Process {
        id: fallbackFirstProc
        stdout: SplitParser {
            onRead: data => {
                var fileName = data.trim()
                if (fileName.length === 0) return
                var fullPath = Quickshell.shellDir + "/assets/wallpapers/" + root._lookupThemeName + "/" + fileName
                if (root.autoSwitchOnThemeChange) {
                    root.applyWallpaper(fullPath)
                } else {
                    root.currentWallpaper = fullPath
                }
            }
        }
    }

    function applyWallpaper(wallpaperPath) {
        if (!wallpaperPath) return
        currentWallpaper = wallpaperPath
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
                persistProc.command = ["bash", "-c",
                    "sed -i '/^" + ThemeService.currentTheme + ":/d' '" + root.wallpaperStatePath + "' 2>/dev/null; " +
                    "echo '" + ThemeService.currentTheme + ":" + root.currentWallpaper + "' >> '" + root.wallpaperStatePath + "'"]
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