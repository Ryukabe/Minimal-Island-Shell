// services/ClipboardService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var history: []
    property var filteredHistory: []
    property string searchQuery: ""

    Component.onCompleted: {
        refreshHistory()
    }

    onSearchQueryChanged: {
        filterHistory()
    }

    // Fetch history asynchronously using SplitParser for reliable stdout streaming
    Process {
        id: fetchProc
        command: ["cliphist", "list"]
        stdout: SplitParser {
            onRead: (data) => {
                var lines = data.trim().split("\n").filter(line => line.length > 0)
                var items = []
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i]
                    var tabIdx = line.indexOf("\t")
                    if (tabIdx !== -1) {
                        items.push({
                            id: line.substring(0, tabIdx),
                            text: line.substring(tabIdx + 1)
                        })
                    }
                }
                root.history = items
                root.filterHistory()
            }
        }
    }

    // Decode and copy directly using a single process pipe
    Process {
        id: pasteProc
        property string targetId: ""
        command: ["sh", "-c", "cliphist decode '" + targetId + "' | wl-copy"]
    }

    Process {
        id: clearProc
        command: ["cliphist", "wipe"]
        onExited: refreshHistory()
    }

    function refreshHistory() {
        if (!fetchProc.running) {
            fetchProc.running = true
        }
    }

    function filterHistory() {
        if (!searchQuery || searchQuery.trim() === "") {
            filteredHistory = history
            return
        }
        var q = searchQuery.toLowerCase()
        filteredHistory = history.filter(item => item.text.toLowerCase().includes(q))
    }

    function selectAndPaste(id) {
        if (!id) return
        pasteProc.targetId = id
        pasteProc.running = true
    }

    function clearAll() {
        clearProc.running = true
    }
}