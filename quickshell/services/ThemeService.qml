// services/ThemeService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel

Item {
    id: root

    property string currentTheme: "monochrome"
    property var themesList: []

    readonly property string themesPath: Quickshell.shellDir + "/styles/themes"
    readonly property string currentThemeFile: root.themesPath + "/.current-theme"

    readonly property string currentThemeJsonPath: root.themesPath + "/" + root.currentTheme + "/quickshell.json"

    // Fix: Added the missing function that ThemeCard.qml is trying to call
    function themeJsonPath(themeName) {
        return root.themesPath + "/" + themeName + "/quickshell.json";
    }

    Component.onCompleted: loadCurrentTheme()

    Process {
        id: readCurrentThemeProc
        command: ["cat", root.currentThemeFile]
        stdout: SplitParser {
            onRead: data => {
                if (data.trim().length > 0) root.currentTheme = data.trim();
            }
        }
    }

    function loadCurrentTheme() {
        readCurrentThemeProc.running = true;
    }

    FolderListModel {
        id: folderModel
        folder: "file://" + root.themesPath
        showDirs: true
        showFiles: false
        showDotAndDotDot: false
        onCountChanged: updateThemes()
    }

    function updateThemes() {
        var list = [];
        for (var i = 0; i < folderModel.count; i++) {
            var folderName = folderModel.get(i, "fileName");
            if (!folderName.startsWith(".")) list.push({ name: folderName });
        }
        themesList = list;
    }

    function applyTheme(themeName) {
        if (!themeName) return;
        currentTheme = themeName;
        persistProc.command = ["bash", "-c", "echo -n \"" + themeName + "\" > \"" + root.currentThemeFile + "\""];
        persistProc.running = true;
    }

    Process { id: persistProc }
}