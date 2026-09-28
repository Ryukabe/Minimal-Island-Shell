// services/ThemeService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel
import "../services"

Item {
    id: root

    property string currentTheme: "monochrome"
    property var themesList: []

    readonly property string themesPath: Quickshell.shellDir + "/styles/themes"
    readonly property string currentThemeFile: root.themesPath + "/.current-theme"
    readonly property string currentThemeJsonPath:
        root.themesPath + "/" + root.currentTheme + "/quickshell.json"

    function themeJsonPath(themeName) {
        return root.themesPath + "/" + themeName + "/quickshell.json"
    }

    Component.onCompleted: loadCurrentTheme()

    // ------------------------------------------------------------------
    // Load the saved theme.
    //
    // IMPORTANT:
    // Loading the saved theme on Quickshell startup does NOT change the
    // wallpaper. WallpaperService is responsible for restoring the
    // actual last-used wallpaper from .current-wallpaper.
    // ------------------------------------------------------------------
    Process {
        id: readCurrentThemeProc

        command: ["cat", root.currentThemeFile]

        stdout: SplitParser {
            onRead: data => {
                var themeName = data.trim()

                if (themeName.length > 0) {
                    root.currentTheme = themeName

                    console.log(
                        "[ThemeService] Loaded saved theme:",
                        themeName
                    )

                    // DO NOT call:
                    // WallpaperService.switchToThemeWallpaper(themeName)
                    //
                    // WallpaperService already restores the last selected
                    // wallpaper independently during startup.
                }
            }
        }

        stderr: SplitParser {
            onRead: data => {
                if (data.trim().length > 0) {
                    console.log(
                        "[ThemeService] Failed to read current theme:",
                        data.trim()
                    )
                }
            }
        }
    }

    function loadCurrentTheme() {
        readCurrentThemeProc.running = false
        readCurrentThemeProc.running = true
    }

    // ------------------------------------------------------------------
    // Theme list
    // ------------------------------------------------------------------

    FolderListModel {
        id: folderModel

        folder: "file://" + root.themesPath
        showDirs: true
        showFiles: false
        showDotAndDotDot: false

        onCountChanged: updateThemes()
        onStatusChanged: {
            if (folderModel.status === FolderListModel.Ready)
                updateThemes()
        }
    }

    function updateThemes() {
        var list = []

        for (var i = 0; i < folderModel.count; i++) {
            var folderName = folderModel.get(i, "fileName")

            if (
                !folderName.startsWith(".") &&
                !folderName.endsWith(".bak")
            ) {
                list.push({
                    name: folderName
                })
            }
        }

        themesList = list
    }

    // ------------------------------------------------------------------
    // Apply a theme manually.
    //
    // This IS an intentional theme change, so the remembered wallpaper
    // for that theme should be restored.
    // ------------------------------------------------------------------

    function applyTheme(themeName) {
        if (!themeName)
            return

        if (themeName === root.currentTheme)
            return

        root.currentTheme = themeName

        console.log(
            "[ThemeService] Applying theme:",
            themeName
        )

        persistProc.running = false

        persistProc.command = [
            "bash",
            "-c",
            "printf '%s' " +
            JSON.stringify(themeName) +
            " > " +
            JSON.stringify(root.currentThemeFile)
        ]

        persistProc.running = true

        // This is an intentional theme change, so now we DO restore the
        // wallpaper associated with the selected theme.
        WallpaperService.switchToThemeWallpaper(themeName)
    }

    // ------------------------------------------------------------------
    // Persist current theme
    // ------------------------------------------------------------------

    Process {
        id: persistProc

        stderr: SplitParser {
            onRead: data => {
                if (data.trim().length > 0) {
                    console.log(
                        "[ThemeService] Theme save error:",
                        data.trim()
                    )
                }
            }
        }
    }
}
