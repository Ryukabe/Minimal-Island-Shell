// features/clipboard/ClipboardService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../launcher"

Singleton {
    id: root

    // Raw list from cliphist, newest first
    property var allHistory: []
    // Enriched, ordered (pinned first, then newest), limited
    property var history: []
    property var filteredHistory: []
    property string searchQuery: ""

    // Persisted in state/clipboard.json
    property var pinnedKeys: []   // keyed by preview text, because cliphist re-issues ids on re-copy
    property var times: ({})      // id -> ms since epoch (0 = unknown)

    property var readyThumbs: ({})
    property bool _loaded: false
    property bool _firstRun: false
    property bool _haveRaw: false

    readonly property int previewWidth: 200
    readonly property string cacheDir:
        (Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")) + "/hermit/clipboard"

    // $1 = cache dir, remaining args = image ids to keep/generate
    readonly property string thumbScript:
        'd="$1"; shift; mkdir -p "$d"; ' +
        'for f in "$d"/*; do [ -e "$f" ] || continue; n="${f##*/}"; keep=0; ' +
        'for id in "$@"; do [ "$id" = "$n" ] && { keep=1; break; }; done; ' +
        '[ "$keep" = 1 ] || rm -f "$f"; done; ' +
        'for id in "$@"; do [ -s "$d/$id" ] || cliphist decode "$id" > "$d/$id"; done'

    readonly property string awkKeep:
        'BEGIN{n=split(pins,a," ");for(i=1;i<=n;i++)p[a[i]]=1} !($1 in p)'

    Component.onCompleted: refreshHistory()

    onSearchQueryChanged: filterHistory()

    Connections {
        target: LauncherSettings
        function onClipboardLimitChanged() { root.applyLimit() }
    }

    // ---------- persistence ----------
    FileView {
        id: store
        path: Quickshell.shellPath("state/clipboard.json")
        watchChanges: false
        onLoaded: {
            try {
                var d = JSON.parse(store.text())
                root.pinnedKeys = d.pinned || []
                root.times = d.times || {}
            } catch (e) {}
            root._loaded = true
            root.reconcile()
        }
        onLoadFailed: (error) => {
            root._firstRun = true
            root._loaded = true
            root.reconcile()
        }
    }

    Timer {
        id: saveTimer
        interval: 400
        repeat: false
        onTriggered: store.setText(JSON.stringify({ pinned: root.pinnedKeys, times: root.times }))
    }

    function scheduleSave() {
        if (_loaded) saveTimer.restart()
    }

    // ---------- cliphist ----------
    Process {
        id: collectorProc
        command: ["cliphist", "-preview-width", String(root.previewWidth), "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.allHistory = root.parseList(text)
                root._haveRaw = true
                root.reconcile()
            }
        }
    }

    // Re-read whenever the clipboard changes, so timestamps are close to the real copy time
    Process {
        id: watchProc
        command: ["wl-paste", "--watch", "sh", "-c", "cat >/dev/null; echo changed"]
        running: true
        stdout: SplitParser {
            onRead: root.scheduleRefresh()
        }
    }

    Timer {
        id: refreshTimer
        interval: 300
        repeat: false
        onTriggered: root.refreshHistory()
    }

    Process {
        id: thumbProc
        property var ids: []
        command: ["sh", "-c", root.thumbScript, "sh", root.cacheDir].concat(ids)
        onExited: {
            var r = {}
            for (var k in root.readyThumbs) r[k] = true
            for (var i = 0; i < ids.length; i++) r[ids[i]] = true
            root.readyThumbs = r
            Qt.callLater(root.applyLimit)
        }
    }

    function refreshHistory() {
        collectorProc.running = false
        collectorProc.running = true
    }

    function scheduleRefresh() {
        refreshTimer.restart()
    }

    function parseList(text) {
        var lines = text.split("\n")
        var items = []
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i]
            if (!line) continue
            var tab = line.indexOf("\t")
            if (tab === -1) continue
            var body = line.substring(tab + 1)
            var m = /^\[\[ binary data (.+?) (\w+) (\d+)x(\d+) \]\]$/.exec(body)
            items.push({
                id: line.substring(0, tab),
                text: body,
                isImage: m !== null,
                imageInfo: m ? (m[2] + " " + m[3] + "×" + m[4] + " · " + m[1]) : ""
            })
        }
        return items
    }

    // ---------- state sync ----------
    function reconcile() {
        if (!_loaded || !_haveRaw) return
        var now = Date.now()
        var next = {}
        for (var i = 0; i < allHistory.length; i++) {
            var id = allHistory[i].id
            next[id] = times[id] !== undefined ? times[id] : (_firstRun ? 0 : now)
        }
        _firstRun = false
        if (JSON.stringify(next) !== JSON.stringify(times)) {
            times = next
            scheduleSave()
        }
        applyLimit()
    }

    function applyLimit() {
        var limit = LauncherSettings.clipboardLimit
        var pinned = []
        var rest = []
        for (var i = 0; i < allHistory.length; i++) {
            var it = allHistory[i]
            var isPinned = pinnedKeys.indexOf(it.text) !== -1
            if (!isPinned && rest.length >= limit) continue
            var entry = {
                id: it.id,
                text: it.text,
                isImage: it.isImage,
                imageInfo: it.imageInfo,
                time: times[it.id] || 0,
                pinned: isPinned,
                thumb: (it.isImage && readyThumbs[it.id]) ? ("file://" + cacheDir + "/" + it.id) : ""
            }
            if (isPinned) pinned.push(entry)
            else rest.push(entry)
        }
        history = pinned.concat(rest)
        filterHistory()
        requestThumbs()
    }

    function requestThumbs() {
        var ids = []
        var need = false
        for (var i = 0; i < history.length; i++) {
            if (!history[i].isImage) continue
            ids.push(history[i].id)
            if (!readyThumbs[history[i].id]) need = true
        }
        if (!need || thumbProc.running) return
        thumbProc.ids = ids
        thumbProc.running = true
    }

    function filterHistory() {
        if (!searchQuery || searchQuery.trim() === "") {
            filteredHistory = history
            return
        }
        var q = searchQuery.toLowerCase()
        filteredHistory = history.filter(item => item.text.toLowerCase().includes(q))
    }

    // ---------- actions ----------
    function selectAndPaste(id) {
        if (!id || !/^\d+$/.test(id)) return
        Quickshell.execDetached(["sh", "-c", 'cliphist decode "$1" | wl-copy', "sh", id])
    }

    function togglePin(item) {
        if (!item) return
        var arr = pinnedKeys.slice()
        var i = arr.indexOf(item.text)
        if (i === -1) arr.push(item.text)
        else arr.splice(i, 1)
        pinnedKeys = arr
        scheduleSave()
        applyLimit()
    }

    function deleteItem(item) {
        if (!item || !/^\d+$/.test(item.id)) return
        if (item.pinned) {
            pinnedKeys = pinnedKeys.filter(k => k !== item.text)
            scheduleSave()
        }
        allHistory = allHistory.filter(i => i.id !== item.id)
        applyLimit()
        Quickshell.execDetached(["sh", "-c",
            'printf "%s\\t\\n" "$1" | cliphist delete; rm -f "$2/$1"',
            "sh", item.id, cacheDir])
        scheduleRefresh()
    }

    // Clears everything except pinned items
    function clearAll() {
        var keepIds = []
        for (var i = 0; i < allHistory.length; i++) {
            if (pinnedKeys.indexOf(allHistory[i].text) !== -1) keepIds.push(allHistory[i].id)
        }
        var tail = 'for f in "$3"/*; do [ -e "$f" ] || continue; ' +
                   'case " $1 " in *" ${f##*/} "*) ;; *) rm -f "$f";; esac; done'
        var script = keepIds.length > 0
            ? 'cliphist list | awk -F"\\t" -v pins="$1" "$2" | cliphist delete; ' + tail
            : 'cliphist wipe; ' + tail
        Quickshell.execDetached(["sh", "-c", script, "sh", keepIds.join(" "), awkKeep, cacheDir])

        allHistory = allHistory.filter(i => keepIds.indexOf(i.id) !== -1)
        searchQuery = ""
        applyLimit()
        scheduleRefresh()
    }
}