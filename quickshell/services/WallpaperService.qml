pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel

Item {
    id: root

    property var wallpapersList: []
    property string currentWallpaper: ""
    property bool isOpen: false

    readonly property string hyprdfRoot: Quickshell.shellDir + "/../HyprDF"
    readonly property string applyScript: root.hyprdfRoot + "/scripts/apply-wallpaper.sh"
    readonly property string wallpaperStateFile: root.hyprdfRoot + "/themes/.wallpaper-state"
    readonly property string wallpapersPath: Quickshell.shellDir + "/assets/wallpapers/" + ThemeService.currentTheme

    onWallpapersPathChanged: rescan()
    Component.onCompleted: rescan()

    function rescan() {
        loadCurrentWallpaperProc.running = true
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

    Process {
        id: loadCurrentWallpaperProc
        command: ["bash", "-c", "grep '^" + ThemeService.currentTheme + ":' '" + root.wallpaperStateFile + "' 2>/dev/null | cut -d: -f2-"]
        stdout: SplitParser {
            onRead: data => {
                if (data.trim().length > 0)
                    root.currentWallpaper = data.trim()
            }
        }
    }

    function applyWallpaper(wallpaperPath) {
        if (!wallpaperPath) return
        currentWallpaper = wallpaperPath
        applyProcess.command = ["bash", root.applyScript, wallpaperPath]
        applyProcess.workingDirectory = root.hyprdfRoot
        applyProcess.running = true
    }

    Process {
        id: applyProcess
        stdout: SplitParser {
            onRead: data => console.log("[WallpaperService] stdout:", data)
        }
        stderr: SplitParser {
            onRead: data => console.log("[WallpaperService] stderr:", data)
        }
        onExited: (exitCode, exitStatus) => {
            console.log("[WallpaperService] apply-wallpaper.sh exited with code", exitCode)
        }
    }
}
