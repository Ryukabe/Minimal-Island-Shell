// welcome/WelcomeStore.qml — state shared by the welcome app: the "seen" flag, which shell is
// active, and the channel to the main shell.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string stateDir: home + "/.config/quickshell/state"
    readonly property string seenPath: stateDir + "/welcome.json"
    readonly property string requestPath: stateDir + "/welcome-request.json"
    readonly property string activeShellPath: home + "/.config/hypr/.active-shell"
    readonly property string switchScript: home + "/.config/hypr/scripts/switch-shell.sh"

    // Contents of ~/.config/hypr/.active-shell ("qs" | "ags"). A missing file counts as Quickshell.
    property string activeShellRaw: ""
    readonly property string activeShell: activeShellRaw === "ags" ? "ags" : "qs"

    property bool _finishing: false

    // Saves "seen" and quits the app. Safe to call more than once.
    function finish() {
        if (root._finishing) return
        root._finishing = true
        seenFile.setText(JSON.stringify({ completed: true }, null, 2) + "\n")
        Qt.quit()
    }

    // Asks the main Quickshell shell to do something (see features/welcome/WelcomeBridge.qml).
    function requestMain(action, arg) {
        requestFile.setText(JSON.stringify({ id: Date.now(), action: action, arg: arg }) + "\n")
    }

    // Runs switch-shell.sh detached, so it keeps going whatever happens to this app.
    function switchTo(name) {
        Quickshell.execDetached([root.switchScript, name])
    }

    property Process mkdirProc: Process {
        command: ["mkdir", "-p", root.stateDir]
        running: true
    }

    property FileView seenFile: FileView {
        path: root.seenPath
        printErrors: false
        // Write before the app quits.
        blockWrites: true
    }

    property FileView requestFile: FileView {
        path: root.requestPath
        printErrors: false
    }

    property FileView activeFile: FileView {
        path: root.activeShellPath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.activeShellRaw = text().trim()
        onLoadFailed: (error) => root.activeShellRaw = ""
    }
}