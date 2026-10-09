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

    // Captured when applyWallpaper() is called so asynchronous processes
    // always persist the wallpaper that was actually requested.
    property string _pendingPersistTheme: ""
    property string _pendingPersistPath: ""

    readonly property string wallpapersRootPath:
        Quickshell.shellDir + "/assets/wallpapers"

    readonly property string wallpapersPath:
        root.wallpapersRootPath + "/" + ThemeService.currentTheme

    readonly property string wallpaperStatePath:
        root.wallpapersRootPath + "/.wallpaper-state"

    readonly property string currentWallpaperFile:
        root.wallpapersRootPath + "/.current-wallpaper"

    readonly property string autoSwitchStatePath:
        root.wallpapersRootPath + "/.autoswitch"

    // ------------------------------------------------------------------
    // Wallpaper folder changes when the active theme changes.
    // ------------------------------------------------------------------

    onWallpapersPathChanged: rescanList()

    // ------------------------------------------------------------------
    // STARTUP
    //
    // Wallpaper restoration happens independently from ThemeService.
    //
    // .current-wallpaper is the authoritative last-selected wallpaper
    // when Quickshell starts.
    //
    // This prevents ThemeService's saved theme from overwriting it.
    // ------------------------------------------------------------------

    Component.onCompleted: {
        console.log("[WallpaperService] Starting wallpaper service")

        loadAutoSwitchProc.running = false
        loadAutoSwitchProc.running = true

        rescanList()

        restoreCurrentWallpaperProc.running = false
        restoreCurrentWallpaperProc.running = true
    }

    // ------------------------------------------------------------------
    // Wallpaper list
    // ------------------------------------------------------------------

    function rescanList() {
        folderModel.folder = "file://" + root.wallpapersPath
    }

    FolderListModel {
        id: folderModel

        folder: "file://" + root.wallpapersPath

        showDirs: false
        showFiles: true

        nameFilters: [
            "*.jpg",
            "*.jpeg",
            "*.png",
            "*.webp"
        ]

        showDotAndDotDot: false

        onCountChanged: updateWallpapers()

        onStatusChanged: {
            if (folderModel.status === FolderListModel.Ready)
                updateWallpapers()
        }
    }

    function updateWallpapers() {
        var list = []

        for (var i = 0; i < folderModel.count; i++) {
            var fileName = folderModel.get(i, "fileName")
            var filePath = root.wallpapersPath + "/" + fileName

            list.push({
                name: fileName,
                path: filePath
            })
        }

        wallpapersList = list
    }

    // ------------------------------------------------------------------
    // STARTUP RESTORE
    //
    // Only .current-wallpaper is used here.
    //
    // We deliberately DO NOT call switchToThemeWallpaper() during
    // startup. That function is reserved for an intentional theme change.
    // ------------------------------------------------------------------

    Process {
        id: restoreCurrentWallpaperProc

        command: [
            "cat",
            root.currentWallpaperFile
        ]

        stdout: SplitParser {
            onRead: data => {
                var path = data.trim()

                if (path.length === 0) {
                    console.log(
                        "[WallpaperService] No saved wallpaper found"
                    )
                    return
                }

                console.log(
                    "[WallpaperService] Restoring last wallpaper:",
                    path
                )

                // Startup restore.
                //
                // Passing an empty theme name prevents this restoration
                // from changing .wallpaper-state for the current theme.
                root.restoreWallpaper(path)
            }
        }

        stderr: SplitParser {
            onRead: data => {
                if (data.trim().length > 0) {
                    console.log(
                        "[WallpaperService] Wallpaper restore error:",
                        data.trim()
                    )
                }
            }
        }
    }

    // ------------------------------------------------------------------
    // Restore a wallpaper without changing per-theme state.
    //
    // This is ONLY used during Quickshell startup.
    // ------------------------------------------------------------------

    function restoreWallpaper(wallpaperPath) {
        if (!wallpaperPath)
            return

        currentWallpaper = wallpaperPath

        console.log(
            "[WallpaperService] Applying startup wallpaper:",
            wallpaperPath
        )

        startupApplyProcess.running = false

        startupApplyProcess.command = [
            "awww",
            "img",
            wallpaperPath
        ]

        startupApplyProcess.running = true
    }

    Process {
        id: startupApplyProcess

        stdout: SplitParser {
            onRead: data => {
                if (data.trim().length > 0) {
                    console.log(
                        "[WallpaperService] startup awww:",
                        data.trim()
                    )
                }
            }
        }

        stderr: SplitParser {
            onRead: data => {
                if (data.trim().length > 0) {
                    console.log(
                        "[WallpaperService] startup awww error:",
                        data.trim()
                    )
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                console.log(
                    "[WallpaperService] Startup wallpaper restored"
                )
            } else {
                console.log(
                    "[WallpaperService] Startup wallpaper failed:",
                    exitCode
                )
            }
        }
    }

    // ------------------------------------------------------------------
    // THEME WALLPAPER SWITCH
    //
    // This is called ONLY when the user intentionally changes theme.
    // ------------------------------------------------------------------

    function switchToThemeWallpaper(themeName) {
        if (!themeName)
            return

        if (!root.autoSwitchOnThemeChange) {
            console.log(
                "[WallpaperService] Auto-switch disabled"
            )
            return
        }

        root._lookupThemeName = themeName
        root._lookupFound = false

        console.log(
            "[WallpaperService] Looking for wallpaper for theme:",
            themeName
        )

        // Stop an older lookup before starting a new one.
        lookupProc.running = false

        lookupProc._forTheme = themeName

        lookupProc.command = [
            "bash",
            "-c",
            "grep '^" +
            themeName +
            ":' " +
            JSON.stringify(root.wallpaperStatePath) +
            " 2>/dev/null | cut -d: -f2-"
        ]

        lookupProc.running = true
    }

    // ------------------------------------------------------------------
    // Look up remembered wallpaper for a theme
    // ------------------------------------------------------------------

    Process {
        id: lookupProc

        property string _forTheme: ""

        stdout: SplitParser {
            onRead: data => {
                if (
                    lookupProc._forTheme !==
                    root._lookupThemeName
                ) {
                    return
                }

                var path = data.trim()

                if (path.length === 0)
                    return

                root._lookupFound = true

                console.log(
                    "[WallpaperService] Found remembered wallpaper:",
                    path
                )

                if (root.autoSwitchOnThemeChange) {
                    root.applyWallpaper(
                        path,
                        lookupProc._forTheme
                    )
                } else {
                    root.currentWallpaper = path
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (
                lookupProc._forTheme !==
                root._lookupThemeName
            ) {
                return
            }

            if (!root._lookupFound) {
                console.log(
                    "[WallpaperService] No remembered wallpaper for:",
                    lookupProc._forTheme
                )

                fallbackFirstProc.running = false

                fallbackFirstProc._forTheme =
                    lookupProc._forTheme

                fallbackFirstProc.command = [
                    "bash",
                    "-c",
                    "ls " +
                    JSON.stringify(
                        root.wallpapersRootPath +
                        "/" +
                        lookupProc._forTheme
                    ) +
                    " 2>/dev/null | " +
                    "grep -Ei '\\.(jpg|jpeg|png|webp)$' | " +
                    "sort | head -n1"
                ]

                fallbackFirstProc.running = true
            }
        }
    }

    // ------------------------------------------------------------------
    // Fallback wallpaper for a theme that has never been selected before
    // ------------------------------------------------------------------

    Process {
        id: fallbackFirstProc

        property string _forTheme: ""

        stdout: SplitParser {
            onRead: data => {
                if (
                    fallbackFirstProc._forTheme !==
                    root._lookupThemeName
                ) {
                    return
                }

                var fileName = data.trim()

                if (fileName.length === 0)
                    return

                var fullPath =
                    root.wallpapersRootPath +
                    "/" +
                    fallbackFirstProc._forTheme +
                    "/" +
                    fileName

                console.log(
                    "[WallpaperService] Using first wallpaper for theme:",
                    fullPath
                )

                if (root.autoSwitchOnThemeChange) {
                    root.applyWallpaper(
                        fullPath,
                        fallbackFirstProc._forTheme
                    )
                } else {
                    root.currentWallpaper = fullPath
                }
            }
        }
    }

    // ------------------------------------------------------------------
    // APPLY WALLPAPER
    //
    // This is used for normal wallpaper selection and theme switching.
    // It updates .current-wallpaper AND .wallpaper-state.
    // ------------------------------------------------------------------

    function applyWallpaper(wallpaperPath, themeName) {
        if (!wallpaperPath)
            return

        currentWallpaper = wallpaperPath

        _pendingPersistTheme =
            (themeName !== undefined && themeName !== "")
            ? themeName
            : ThemeService.currentTheme

        _pendingPersistPath = wallpaperPath

        console.log(
            "[WallpaperService] Applying wallpaper:",
            wallpaperPath,
            "theme:",
            _pendingPersistTheme
        )

        applyProcess.running = false

        applyProcess.command = [
            "awww",
            "img",
            wallpaperPath
        ]

        applyProcess.running = true
    }

    // ------------------------------------------------------------------
    // awww process
    // ------------------------------------------------------------------

    Process {
        id: applyProcess

        stdout: SplitParser {
            onRead: data => {
                if (data.trim().length > 0) {
                    console.log(
                        "[WallpaperService] awww stdout:",
                        data.trim()
                    )
                }
            }
        }

        stderr: SplitParser {
            onRead: data => {
                if (data.trim().length > 0) {
                    console.log(
                        "[WallpaperService] awww stderr:",
                        data.trim()
                    )
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.log(
                    "[WallpaperService] awww exited with code:",
                    exitCode,
                    "— wallpaper not persisted"
                )
                return
            }

            var persistTheme = root._pendingPersistTheme
            var persistPath = root._pendingPersistPath

            if (!persistPath)
                return

            persistProc.running = false

            // Escape values safely for the shell.
            var escapedTheme =
                persistTheme.replace(/'/g, "'\\''")

            var escapedPath =
                persistPath.replace(/'/g, "'\\''")

            persistProc.command = [
                "bash",
                "-c",

                // 1. Save the actual last selected wallpaper.
                "printf '%s' '" +
                escapedPath +
                "' > " +
                JSON.stringify(root.currentWallpaperFile) +
                "; " +

                // 2. Save the wallpaper for this theme.
                "touch " +
                JSON.stringify(root.wallpaperStatePath) +
                "; " +

                // 3. Remove the previous entry for this theme.
                "sed -i '/^" +
                escapedTheme +
                ":/d' " +
                JSON.stringify(root.wallpaperStatePath) +
                " 2>/dev/null; " +

                // 4. Save the new theme/path pair.
                "printf '%s\\n' '" +
                escapedTheme +
                ":" +
                escapedPath +
                "' >> " +
                JSON.stringify(root.wallpaperStatePath)
            ]

            persistProc.running = true

            console.log(
                "[WallpaperService] Wallpaper state saved:",
                persistPath
            )
        }
    }

    Process {
        id: persistProc

        stderr: SplitParser {
            onRead: data => {
                if (data.trim().length > 0) {
                    console.log(
                        "[WallpaperService] State save error:",
                        data.trim()
                    )
                }
            }
        }
    }

    // ------------------------------------------------------------------
    // AUTO SWITCH SETTING
    // ------------------------------------------------------------------

    function setAutoSwitch(enabled) {
        root.autoSwitchOnThemeChange = enabled

        saveAutoSwitchProc.running = false

        saveAutoSwitchProc.command = [
            "bash",
            "-c",
            "printf '%s' '" +
            (enabled ? "true" : "false") +
            "' > " +
            JSON.stringify(root.autoSwitchStatePath)
        ]

        saveAutoSwitchProc.running = true
    }

    Process {
        id: saveAutoSwitchProc

        stderr: SplitParser {
            onRead: data => {
                if (data.trim().length > 0) {
                    console.log(
                        "[WallpaperService] Auto-switch save error:",
                        data.trim()
                    )
                }
            }
        }
    }

    // ------------------------------------------------------------------
    // LOAD AUTO SWITCH SETTING
    // ------------------------------------------------------------------

    Process {
        id: loadAutoSwitchProc

        command: [
            "cat",
            root.autoSwitchStatePath
        ]

        stdout: SplitParser {
            onRead: data => {
                var val = data.trim()

                if (val.length > 0) {
                    root.autoSwitchOnThemeChange =
                        (val === "true")

                    console.log(
                        "[WallpaperService] Auto-switch:",
                        root.autoSwitchOnThemeChange
                    )
                }
            }
        }
    }
}

