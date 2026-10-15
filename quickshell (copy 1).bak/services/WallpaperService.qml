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

    // false = static images, true = animated (GIF + video)
    property bool animatedMode: false

    // Wallpaper source: theme folders (default) or one custom folder.
    property bool useCustomFolder: false
    readonly property string defaultCustomFolder:
    (Quickshell.env("HOME") || "") + "/Pictures/Wallpapers"

    property string customFolderPath: defaultCustomFolder

    // Bumped whenever video thumbnails finish generating so cards reload them.
    property int thumbVersion: 0

    property bool _lookupFound: false
    property string _lookupThemeName: ""

    property string _pendingPersistTheme: ""
    property string _pendingPersistPath: ""

    readonly property string wallpapersRootPath:
        Quickshell.shellDir + "/assets/wallpapers"

    // Folder currently being listed.
    readonly property string wallpapersPath:
    root.useCustomFolder
    ? (root.customFolderPath !== "" ? root.customFolderPath : "/nonexistent")
    : root.wallpapersRootPath + "/" + ThemeService.currentTheme

    readonly property string stateDir:
        Quickshell.shellDir + "/state"

    readonly property string thumbDir:
        root.stateDir + "/thumbs"

    readonly property string wallpaperStatePath:
        root.stateDir + "/.wallpaper-state"

    readonly property string currentWallpaperFile:
        root.stateDir + "/.current-wallpaper"

    readonly property string autoSwitchStatePath:
        root.stateDir + "/.autoswitch"

    readonly property string modeStatePath:
        root.stateDir + "/.wallpaper-mode"

    readonly property string sourceStatePath:
        root.stateDir + "/.wallpaper-source"

    readonly property string customFolderStatePath:
        root.stateDir + "/.custom-folder"

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------

    function isVideoPath(p) {
        return /\.(mp4|webm|mkv|mov)$/i.test(p)
    }

    function isGifPath(p) {
        return /\.gif$/i.test(p)
    }

    function folderUrl(p) {
        return "file://" + p.split("/").map(encodeURIComponent).join("/")
    }

    // Cache name derived from the full path so identical filenames in
    // different folders never collide.
    function thumbFor(p) {
        return root.thumbDir + "/" + p.replace(/[^A-Za-z0-9._-]/g, "_") + ".jpg"
    }

    function normalizeFolder(p) {
        var t = (p || "").trim()
        if (t === "")
            return ""
        t = t.replace(/^~(?=\/|$)/, Quickshell.env("HOME") || "")
        while (t.length > 1 && t.endsWith("/"))
            t = t.slice(0, -1)
        return t
    }

    // Static images and GIFs go through awww (killing mpvpaper first so a
    // previous video wallpaper disappears). Videos go through mpvpaper,
    // started detached so it keeps running independently of Quickshell.
    function buildApplyCommand(p) {
        if (isVideoPath(p)) {
            return [
                "bash",
                "-c",
                "pkill -x mpvpaper; sleep 0.1; " +
                "setsid -f mpvpaper -o 'no-audio loop' ALL \"$1\" >/dev/null 2>&1",
                "bash",
                p
            ]
        }

        return [
            "bash",
            "-c",
            "pkill -x mpvpaper; awww img \"$1\"",
            "bash",
            p
        ]
    }

    // Writes a single value to a state file, creating state/ if needed.
    function saveState(proc, file, value) {
        proc.running = false
        proc.command = [
            "bash",
            "-c",
            "mkdir -p \"$1\"; printf '%s' \"$2\" > \"$3\"",
            "bash",
            root.stateDir,
            value,
            file
        ]
        proc.running = true
    }

    // ------------------------------------------------------------------
    // Wallpaper folder changes when the theme or source changes.
    // ------------------------------------------------------------------

    onWallpapersPathChanged: rescanList()

    // ------------------------------------------------------------------
    // STARTUP
    // ------------------------------------------------------------------

    Component.onCompleted: {
        console.log("[WallpaperService] Starting wallpaper service")

        loadAutoSwitchProc.running = false
        loadAutoSwitchProc.running = true

        loadModeProc.running = false
        loadModeProc.running = true

        loadSourceProc.running = false
        loadSourceProc.running = true

        loadCustomFolderProc.running = false
        loadCustomFolderProc.running = true

        rescanList()

        restoreCurrentWallpaperProc.running = false
        restoreCurrentWallpaperProc.running = true
    }

    // ------------------------------------------------------------------
    // Wallpaper list
    // ------------------------------------------------------------------

    function rescanList() {
        folderModel.folder = root.folderUrl(root.wallpapersPath)
    }

    FolderListModel {
        id: folderModel

        folder: root.folderUrl(root.wallpapersPath)

        showDirs: false
        showFiles: true

        nameFilters: [
            "*.jpg",
            "*.jpeg",
            "*.png",
            "*.webp",
            "*.gif",
            "*.mp4",
            "*.webm",
            "*.mkv",
            "*.mov"
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
            var video = isVideoPath(fileName)
            var gif = isGifPath(fileName)

            list.push({
                name: fileName,
                path: filePath,
                video: video,
                animated: video || gif,
                thumb: root.thumbFor(filePath)
            })
        }

        wallpapersList = list

        generateThumbs()
    }

    // ------------------------------------------------------------------
    // Video thumbnails (needs ffmpeg). Generated once, cached in state/thumbs.
    // The list of (video, output) pairs is built here and passed as arguments.
    // ------------------------------------------------------------------

    function generateThumbs() {
        var args = []

        for (var i = 0; i < wallpapersList.length; i++) {
            if (wallpapersList[i].video) {
                args.push(wallpapersList[i].path)
                args.push(wallpapersList[i].thumb)
            }
        }

        if (args.length === 0)
            return

        thumbProc.running = false

        thumbProc.command = [
            "bash",
            "-c",
            "mkdir -p \"$1\"; shift; " +
            "while [ $# -ge 2 ]; do " +
            "  f=\"$1\"; o=\"$2\"; shift 2; " +
            "  [ -s \"$o\" ] && continue; " +
            "  ffmpeg -y -loglevel error -ss 1 -i \"$f\" -frames:v 1 " +
            "    -vf scale=290:-2 \"$o.tmp.jpg\" 2>/dev/null; " +
            "  [ -s \"$o.tmp.jpg\" ] || ffmpeg -y -loglevel error -i \"$f\" " +
            "    -frames:v 1 -vf scale=290:-2 \"$o.tmp.jpg\"; " +
            "  [ -s \"$o.tmp.jpg\" ] && mv \"$o.tmp.jpg\" \"$o\"; " +
            "done",
            "bash",
            root.thumbDir
        ].concat(args)

        thumbProc.running = true
    }

    Process {
        id: thumbProc

        stderr: SplitParser {
            onRead: data => {
                if (data.trim().length > 0) {
                    console.log(
                        "[WallpaperService] thumbnail error:",
                        data.trim()
                    )
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            root.thumbVersion++
        }
    }

    // ------------------------------------------------------------------
    // STARTUP RESTORE
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

    // Restore a wallpaper without changing per-theme state.
    // ONLY used during Quickshell startup.
    function restoreWallpaper(wallpaperPath) {
        if (!wallpaperPath)
            return

        currentWallpaper = wallpaperPath

        console.log(
            "[WallpaperService] Applying startup wallpaper:",
            wallpaperPath
        )

        startupApplyProcess.running = false
        startupApplyProcess.command = root.buildApplyCommand(wallpaperPath)
        startupApplyProcess.running = true
    }

    Process {
        id: startupApplyProcess

        stdout: SplitParser {
            onRead: data => {
                if (data.trim().length > 0) {
                    console.log(
                        "[WallpaperService] startup apply:",
                        data.trim()
                    )
                }
            }
        }

        stderr: SplitParser {
            onRead: data => {
                if (data.trim().length > 0) {
                    console.log(
                        "[WallpaperService] startup apply error:",
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
    // Called ONLY when the user intentionally changes theme.
    // Does nothing while a custom folder is in use.
    // ------------------------------------------------------------------

    function switchToThemeWallpaper(themeName) {
        if (!themeName)
            return

        if (root.useCustomFolder) {
            console.log(
                "[WallpaperService] Custom folder in use, skipping theme wallpaper"
            )
            return
        }

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

                // Fallback only picks a static image.
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
    // In custom-folder mode only .current-wallpaper is saved; the
    // per-theme memory is left alone so theme folders stay untouched.
    // ------------------------------------------------------------------

    function applyWallpaper(wallpaperPath, themeName) {
        if (!wallpaperPath)
            return

        currentWallpaper = wallpaperPath

        if (root.useCustomFolder) {
            _pendingPersistTheme = ""
        } else {
            _pendingPersistTheme =
                (themeName !== undefined && themeName !== "")
                ? themeName
                : ThemeService.currentTheme
        }

        _pendingPersistPath = wallpaperPath

        console.log(
            "[WallpaperService] Applying wallpaper:",
            wallpaperPath,
            "theme:",
            _pendingPersistTheme
        )

        applyProcess.running = false
        applyProcess.command = root.buildApplyCommand(wallpaperPath)
        applyProcess.running = true
    }

    Process {
        id: applyProcess

        stdout: SplitParser {
            onRead: data => {
                if (data.trim().length > 0) {
                    console.log(
                        "[WallpaperService] apply stdout:",
                        data.trim()
                    )
                }
            }
        }

        stderr: SplitParser {
            onRead: data => {
                if (data.trim().length > 0) {
                    console.log(
                        "[WallpaperService] apply stderr:",
                        data.trim()
                    )
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.log(
                    "[WallpaperService] apply exited with code:",
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

            var escapedTheme =
                persistTheme.replace(/'/g, "'\\''")

            var escapedPath =
                persistPath.replace(/'/g, "'\\''")

            // 0 + 1: make sure state/ exists, save the last selected wallpaper.
            var cmd =
                "mkdir -p " +
                JSON.stringify(root.stateDir) +
                "; " +
                "printf '%s' '" +
                escapedPath +
                "' > " +
                JSON.stringify(root.currentWallpaperFile) +
                "; "

            // 2-4: per-theme memory, only outside custom-folder mode.
            if (persistTheme !== "") {
                cmd +=
                    "touch " +
                    JSON.stringify(root.wallpaperStatePath) +
                    "; " +
                    "sed -i '/^" +
                    escapedTheme +
                    ":/d' " +
                    JSON.stringify(root.wallpaperStatePath) +
                    " 2>/dev/null; " +
                    "printf '%s\\n' '" +
                    escapedTheme +
                    ":" +
                    escapedPath +
                    "' >> " +
                    JSON.stringify(root.wallpaperStatePath)
            }

            persistProc.command = ["bash", "-c", cmd]
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
    // STATIC / ANIMATED MODE
    // ------------------------------------------------------------------

    function setAnimatedMode(enabled) {
        if (root.animatedMode === enabled)
            return

        root.animatedMode = enabled
        root.saveState(saveModeProc, root.modeStatePath,
                       enabled ? "animated" : "static")
    }

    Process {
        id: saveModeProc

        stderr: SplitParser {
            onRead: data => {
                if (data.trim().length > 0) {
                    console.log(
                        "[WallpaperService] Mode save error:",
                        data.trim()
                    )
                }
            }
        }
    }

    Process {
        id: loadModeProc

        command: [
            "cat",
            root.modeStatePath
        ]

        stdout: SplitParser {
            onRead: data => {
                var val = data.trim()

                if (val.length > 0)
                    root.animatedMode = (val === "animated")
            }
        }
    }

    // ------------------------------------------------------------------
    // WALLPAPER SOURCE (theme folders / custom folder)
    // ------------------------------------------------------------------

    function setUseCustomFolder(enabled) {
        if (root.useCustomFolder === enabled)
            return

        root.useCustomFolder = enabled
        root.saveState(saveSourceProc, root.sourceStatePath,
                       enabled ? "custom" : "theme")
    }

    function setCustomFolderPath(path) {
        var p = root.normalizeFolder(path)
    
        if (p === "")
            p = root.defaultCustomFolder
    
        if (root.customFolderPath === p)
            return
    
        root.customFolderPath = p
        root.saveState(saveCustomFolderProc, root.customFolderStatePath, p)
    }

    Process {
        id: saveSourceProc

        stderr: SplitParser {
            onRead: data => {
                if (data.trim().length > 0) {
                    console.log(
                        "[WallpaperService] Source save error:",
                        data.trim()
                    )
                }
            }
        }
    }

    Process {
        id: saveCustomFolderProc

        stderr: SplitParser {
            onRead: data => {
                if (data.trim().length > 0) {
                    console.log(
                        "[WallpaperService] Custom folder save error:",
                        data.trim()
                    )
                }
            }
        }
    }

    Process {
        id: loadSourceProc

        command: [
            "cat",
            root.sourceStatePath
        ]

        stdout: SplitParser {
            onRead: data => {
                var val = data.trim()

                if (val.length > 0)
                    root.useCustomFolder = (val === "custom")
            }
        }
    }

    Process {
        id: loadCustomFolderProc

        command: [
            "cat",
            root.customFolderStatePath
        ]

        stdout: SplitParser {
            onRead: data => {
                var val = data.trim()

                if (val.length > 0)
                    root.customFolderPath = val
            }
        }
    }

    // ------------------------------------------------------------------
    // AUTO SWITCH SETTING
    // ------------------------------------------------------------------

    function setAutoSwitch(enabled) {
        root.autoSwitchOnThemeChange = enabled
        root.saveState(saveAutoSwitchProc, root.autoSwitchStatePath,
                       enabled ? "true" : "false")
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