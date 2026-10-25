// features/welcome/WelcomeBridge.qml — lets the standalone welcome app (quickshell -c welcome) ask
// this shell to open Settings, the theme switcher or the wallpaper picker.
// The welcome app writes state/welcome-request.json; this file watches it.
import QtQuick
import Quickshell
import Quickshell.Io
import "../settings/core"
import "../theme"
import "../../core/shell"

Scope {
    id: root

    readonly property string stateDir: Quickshell.env("HOME") + "/.config/quickshell/state"
    readonly property string requestPath: stateDir + "/welcome-request.json"

    property real _lastId: -1
    property bool _primed: false

    // Creates the state folder and an empty request file when there is none yet, so the
    // watcher below has a file to watch.
    Process {
        id: mkdirProc
        command: ["mkdir", "-p", root.stateDir]
        onExited: requestFile.setText("{\"id\":0}\n")
    }

    FileView {
        id: requestFile
        path: root.requestPath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root._handle(text())
        onLoadFailed: (error) => {
            root._primed = true
            mkdirProc.running = true
        }
    }

    function _handle(raw) {
        var data
        try {
            data = JSON.parse(raw)
        } catch (e) {
            return
        }
        if (data.id === undefined || data.id === root._lastId) return

        // The first file read after startup is a request left over from an earlier session:
        // remember it, but do not act on it.
        var stale = !root._primed
        root._lastId = data.id
        root._primed = true
        if (stale) return

        root._run(data.action, data.arg)
    }

    function _run(action, arg) {
        if (action === "settings") {
            ShellState.openSettings()
            if (arg) SettingsNav.openByName(arg)
        } else if (action === "page") {
            ShellState.showPage(arg)
        } else if (action === "wallpaper") {
            WallpaperService.isOpen = true
            ShellState.showPage("wallpaper")
        }
    }
}