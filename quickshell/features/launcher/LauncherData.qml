// features/launcher/LauncherData.qml
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

    // ---- editable from Settings > Launcher > Aliases & pinned and Search engines ----
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
    onAliasesChanged: scheduleSave()
    onPinnedChanged: scheduleSave()
    onEnginesChanged: scheduleSave()
    onDefaultEngineChanged: scheduleSave()

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

    // ---- aliases, pinned apps and search engines (Settings > Launcher) ----
    function _cleanKey(raw) { return (raw || "").trim().toLowerCase() }

    function setAlias(rawKey, target) {
        var k = _cleanKey(rawKey)
        if (!/^[a-z0-9._-]{1,16}$/.test(k) || !target) return false
        var copy = {}
        for (var a in aliases) copy[a] = aliases[a]
        copy[k] = target
        aliases = copy
        return true
    }

    function removeAlias(key) {
        var copy = {}
        for (var a in aliases) if (a !== key) copy[a] = aliases[a]
        aliases = copy
    }

    function addPinned(name) {
        var n = (name || "").trim()
        if (n === "" || pinned.some(p => p.toLowerCase() === n.toLowerCase())) return false
        pinned = pinned.concat([n])
        return true
    }

    function removePinned(name) {
        pinned = pinned.filter(p => p !== name)
    }

    // Returns "" when the engine was added, or a sentence saying what is wrong.
    function addEngine(rawKey, rawName, rawUrl) {
        var k = _cleanKey(rawKey)
        var name = (rawName || "").trim()
        var url = (rawUrl || "").trim()
        if (!/^[a-z]{1,12}$/.test(k)) return "The keyword is 1 to 12 letters, nothing else"
        if (Object.prototype.hasOwnProperty.call(engines, k)) return "That keyword is already used"
        if (!/^https?:\/\//i.test(url)) return "The address must start with http:// or https://"
        if (url.indexOf("%s") < 0) return "The address needs %s where the search words go"
        var copy = {}
        for (var e in engines) copy[e] = engines[e]
        copy[k] = { name: name !== "" ? name : k, url: url }
        engines = copy
        return ""
    }

    function removeEngine(key) {
        var keys = Object.keys(engines)
        if (keys.length <= 1 || keys.indexOf(key) < 0) return false
        var copy = {}
        for (var e in engines) if (e !== key) copy[e] = engines[e]
        engines = copy
        if (defaultEngine === key) defaultEngine = Object.keys(copy)[0]
        return true
    }

    function setDefaultEngine(key) {
        if (Object.prototype.hasOwnProperty.call(engines, key)) defaultEngine = key
    }

    function resetEngines() {
        engines = JSON.parse(JSON.stringify(defaultEngines))
        defaultEngine = "g"
    }

    function _dirOf(path) {
        var i = path.lastIndexOf("/")
        return i > 0 ? path.slice(0, i) : path
    }

    // Used by Settings > Launcher > Reset. Aliases, pinned apps and search engines are your own data, not options, so they stay.
    function resetStorageDefaults() {
        notesMode = "running"
        notesFile = home + "/Documents/quick-notes.md"
        notesFolder = home + "/Documents/Quick Notes"
        snippetsFolder = home + "/.config/quickshell/snippets"
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