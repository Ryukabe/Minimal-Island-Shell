// services/LauncherData.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string statePath: home + "/.config/quickshell/state/launcher-data.json"
    readonly property string legacyPath: home + "/.config/quickshell/launcher-data.json"

    readonly property var defaultEngines: ({
        g:    { name: "Google",         url: "https://www.google.com/search?q=%s" },
        ddg:  { name: "DuckDuckGo",     url: "https://duckduckgo.com/?q=%s" },
        yt:   { name: "YouTube",        url: "https://www.youtube.com/results?search_query=%s" },
        gh:   { name: "GitHub",         url: "https://github.com/search?q=%s" },
        wiki: { name: "Wikipedia",      url: "https://en.wikipedia.org/w/index.php?search=%s" },
        so:   { name: "Stack Overflow", url: "https://stackoverflow.com/search?q=%s" },
        maps: { name: "Google Maps",    url: "https://www.google.com/maps/search/%s" }
    })

    // ---- hand-edited in launcher-data.json ----
    property var aliases: ({})
    property var pinned: []
    property var engines: defaultEngines
    property string defaultEngine: "g"

    // ---- editable from Settings > Launcher ----
    property string notesFile: home + "/Documents/quick-notes.md"     // used when notesMode === "running"
    property string notesFolder: home + "/Documents/Quick Notes"      // used when notesMode === "daily" or "capture"
    property string notesMode: "running"                              // "running" | "daily" | "capture"
    property string snippetsFolder: home + "/.config/quickshell/snippets"

    property bool _loading: false
    property bool _newLoaded: false

    onNotesFileChanged: scheduleSave()
    onNotesFolderChanged: scheduleSave()
    onNotesModeChanged: scheduleSave()
    onSnippetsFolderChanged: scheduleSave()

    FileView {
        id: file
        path: root.statePath
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root._newLoaded = true
            root.applyJson(text())
        }
        onLoadFailed: (error) => {}   // legacyFile handles the fallback
    }

    // One-time migration from the pre-"state/" location.
    FileView {
        id: legacyFile
        path: root.legacyPath
        printErrors: false
        onLoaded: {
            if (root._newLoaded) return
            root.applyJson(text())
            root.saveNow()
            Quickshell.execDetached(["rm", "-f", legacyFile.path])
        }
        onLoadFailed: (error) => {
            if (root._newLoaded) return
            root.writeDefaults()
        }
    }

    function _defaultData() {
        return {
            aliases: { ff: "Firefox" },
            pinned: [],
            engines: defaultEngines,
            defaultEngine: "g",
            notesFile: "~/Documents/quick-notes.md",
            notesFolder: "~/Documents/Quick Notes",
            notesMode: "running",
            snippetsFolder: "~/.config/quickshell/snippets"
        }
    }

    function writeDefaults() {
        var txt = JSON.stringify(_defaultData(), null, 2)
        applyJson(txt)
        file.setText(txt)
    }

    Timer {
        id: saveTimer
        interval: 300
        repeat: false
        onTriggered: root.saveNow()
    }

    function scheduleSave() {
        if (!_loading) saveTimer.restart()
    }

    function saveNow() {
        file.setText(JSON.stringify({
            aliases: aliases,
            pinned: pinned,
            engines: engines,
            defaultEngine: defaultEngine,
            notesFile: notesFile,
            notesFolder: notesFolder,
            notesMode: notesMode,
            snippetsFolder: snippetsFolder
        }, null, 2))
    }

    function _isObj(v) {
        return v !== null && typeof v === "object" && !Array.isArray(v)
    }

    function _expand(p) {
        var t = (p || "").trim()
        return t.indexOf("~/") === 0 ? home + t.slice(1) : t
    }

    function applyJson(txt) {
        var d
        try {
            d = JSON.parse(txt)
        } catch (e) {
            console.warn("LauncherData: bad launcher-data.json, keeping previous values", e)
            return
        }
        if (!_isObj(d)) return

        _loading = true

        var al = {}
        if (_isObj(d.aliases)) {
            for (var k in d.aliases) {
                if (typeof d.aliases[k] === "string") al[k.toLowerCase().trim()] = d.aliases[k]
            }
        }
        aliases = al

        pinned = Array.isArray(d.pinned) ? d.pinned.filter(x => typeof x === "string") : []

        var en = {}
        if (_isObj(d.engines)) {
            for (var e in d.engines) {
                var eng = d.engines[e]
                if (_isObj(eng) && typeof eng.url === "string" && eng.url.indexOf("%s") >= 0) {
                    en[e.toLowerCase().trim()] = { name: String(eng.name || e), url: eng.url }
                }
            }
        }
        engines = Object.keys(en).length > 0 ? en : defaultEngines

        var de = typeof d.defaultEngine === "string" ? d.defaultEngine.toLowerCase() : "g"
        defaultEngine = Object.prototype.hasOwnProperty.call(engines, de) ? de : Object.keys(engines)[0]

        if (typeof d.notesFile === "string" && d.notesFile.trim() !== "") notesFile = _expand(d.notesFile)
        if (typeof d.notesFolder === "string" && d.notesFolder.trim() !== "") notesFolder = _expand(d.notesFolder).replace(/\/+$/, "")
        if (["running", "daily", "capture"].indexOf(d.notesMode) >= 0) notesMode = d.notesMode
        if (typeof d.snippetsFolder === "string" && d.snippetsFolder.trim() !== "") snippetsFolder = _expand(d.snippetsFolder).replace(/\/+$/, "")

        _loading = false
    }

    // ---- editing from Settings > Launcher ----
    function setNotesFile(raw) {
        var v = _expand(raw)
        if (v.length === 0) return false
        notesFile = v
        return true
    }

    function setNotesFolder(raw) {
        var v = _expand(raw).replace(/\/+$/, "")
        if (v.length === 0) return false
        notesFolder = v
        return true
    }

    function setNotesMode(mode) {
        if (["running", "daily", "capture"].indexOf(mode) < 0) return false
        notesMode = mode
        return true
    }

    function setSnippetsFolder(raw) {
        var v = _expand(raw).replace(/\/+$/, "")
        if (v.length === 0) return false
        snippetsFolder = v
        return true
    }

    function _dirOf(path) {
        var i = path.lastIndexOf("/")
        return i > 0 ? path.slice(0, i) : path
    }

    function openNotesFolder() {
        var target = notesMode === "running" ? _dirOf(notesFile) : notesFolder
        Quickshell.execDetached(["sh", "-c", "mkdir -p \"$1\" && xdg-open \"$1\"", "sh", target])
    }

    function openSnippetsFolder() {
        Quickshell.execDetached(["sh", "-c", "mkdir -p \"$1\" && xdg-open \"$1\"", "sh", snippetsFolder])
    }

    function openFile() {
        Quickshell.execDetached(["xdg-open", statePath])
    }
}