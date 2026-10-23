pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string noteText: ""
    property bool _loaded: false

    readonly property string _home: Quickshell.env("HOME")

    Process {
        id: mkdirProc
        command: ["mkdir", "-p", root._home + "/.config/quickshell/state"]
        onExited: (code) => {
            if (code === 0) root.noteFile.reload()
        }
    }

    property FileView noteFile: FileView {
        path: root._home + "/.config/quickshell/state/dashboard-quicknote.md"
        printErrors: true
        onLoaded: {
            root.noteText = text()
            root._loaded = true
        }
        onLoadFailed: (error) => {
            console.warn("QuickNoteService: load failed, starting empty", error)
            root._loaded = true
        }
    }

    property Timer saveTimer: Timer {
        interval: 300
        onTriggered: root._doSave()
    }

    Component.onCompleted: {
        mkdirProc.running = true
    }

    function _doSave() {
        if (!root._loaded) return
        root.noteFile.setText(root.noteText)
    }

    function updateText(text) {
        root.noteText = text
        if (root._loaded) {
            root.saveTimer.restart()
        }
    }

    function flush() {
        saveTimer.stop()
        root._doSave()
    }
}