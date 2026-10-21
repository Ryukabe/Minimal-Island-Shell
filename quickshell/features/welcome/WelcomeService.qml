// features/welcome/WelcomeService.qml — first-run flag + open state for the welcome window.
// Persists to state/welcome.json. A missing file (or completed != true) means first run.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    // Window visibility (transient, never saved).
    property bool open: false
    // Saved flag: true once the user has finished or closed the welcome screen.
    property bool completed: false
    property bool ready: false

    readonly property string statePath: Quickshell.shellDir + "/state/welcome.json"

    function show() { root.open = true }

    // Closes the window and remembers that it was seen.
    function finish() {
        root.open = false
        if (!root.completed) {
            root.completed = true
            root._save()
        }
    }

    // For testing: clears the flag and shows the screen again.
    function reset() {
        root.completed = false
        root._save()
        root.open = true
    }

    function _save() {
        file.setText(JSON.stringify({ completed: root.completed }, null, 2) + "\n")
    }

    function _loadDone() {
        root.ready = true
        if (!root.completed) root.open = true
    }

    property FileView file: FileView {
        path: root.statePath
        printErrors: false
        // Write synchronously: the shell can be killed right after finish() (shell switch).
        blockWrites: true

        onLoaded: {
            try {
                root.completed = JSON.parse(text()).completed === true
            } catch (e) {
                root.completed = false
            }
            root._loadDone()
        }

        // Missing file = fresh install.
        onLoadFailed: (error) => root._loadDone()
    }
}