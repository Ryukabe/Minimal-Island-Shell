// features/dashboard/QuickNoteService.qml — the Dashboard quick note, stored as Markdown.
// Standalone for now; it can be connected to the launcher notes later.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    readonly property string path: Quickshell.env("HOME") + "/.config/quickshell/state/dashboard-quicknote.md"

    property string text: ""
    property bool loaded: false
    property bool _applying: false

    function setText(value) { root.text = value }

    // Save button: write now, no waiting for the autosave delay.
    function saveNow() {
        root.saveTimer.stop()
        root._write()
    }

    // Writes immediately if an autosave is pending (called when the editor goes away).
    function flush() {
        if (root.saveTimer.running) root.saveNow()
    }

    function openFile() {
        root._opener.command = ["xdg-open", root.path]
        root._opener.running = true
    }

    function _write() {
        if (root.loaded) root.file.setText(root.text)
    }

    onTextChanged: if (root.loaded && !root._applying) root.saveTimer.restart()

    property FileView file: FileView {
        path: root.path
        printErrors: false
        onLoaded: {
            root._applying = true
            root.text = text()
            root._applying = false
            root.loaded = true
        }
        onLoadFailed: root.loaded = true
    }

    property Timer saveTimer: Timer {
        interval: 600
        onTriggered: root._write()
    }

    property Process _opener: Process {}
}