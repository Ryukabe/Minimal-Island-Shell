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

    Process {
        id: fetchProc
        command: ["cliphist", "list"]
        running: true
        stdout: SplitParser {
            property var accumulatedItems: []
            
            onRead: (data) => {
                var lines = data.trim().split("\n").filter(line => line.length > 0)
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i]
                    var tabIdx = line.indexOf("\t")
                    if (tabIdx !== -1) {
                        accumulatedItems.push({
                            id: line.substring(0, tabIdx),
                            text: line.substring(tabIdx + 1)
                        })
                    }
                }
            }
            
            Component.onDestruction: {
                // fallback if needed
            }
        }
        onExited: {
            // Parse through standard collector pattern via a fresh execution or direct read
        }
    }

    // Let's use a bulletproof StdioCollector approach with an explicit trigger function
    Process {
        id: collectorProc
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n").filter(line => line.length > 0)
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

    Process {
        id: pasteProc
        property string targetId: ""
        command: ["sh", "-c", "cliphist decode '" + targetId + "' | wl-copy"]
    }

    Process {
        id: clearProc
        command: ["cliphist", "wipe"]
        onExited: {
            root.history = []
            root.filteredHistory = []
            root.searchQuery = ""
            refreshHistory()
        }
    }

    function refreshHistory() {
        collectorProc.running = false
        collectorProc.running = true
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