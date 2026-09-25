// services/LauncherSettings.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ---- Search ----
    property int maxResults: 8
    property string matchMode: "Fuzzy"          // "Fuzzy" | "Prefix"
    property bool searchDescriptions: true

    // ---- Recent apps ----
    property bool showRecentsFirst: true
    property int recentLimit: 10
    property var recentIds: []

    // ---- Appearance ----
    property bool showIcons: true
    property bool animateResults: true
    property string launcherWidth: "Normal"     // "Compact" | "Normal" | "Wide"
    property bool shrinkForFewResults: true

    // ---- Extras ----
    property bool inlineCalculator: true
    property bool clipboardHistory: true
    property int clipboardLimit: 100

    // ---- Feature switches (one per launcher provider) ----
    property var features: ({
        commands: true, web: true, files: true,
        system: true, units: true, emoji: true, snippets: true, notes: true
    })

    // ---- Trigger marks for emoji / snippets / notes. Reserved: > ? / : ----
    property string triggerEmoji: ";"
    property string triggerSnippets: "\""
    property string triggerNotes: "-"
    readonly property var reservedMarks: [">", "?", "/", ":"]

    readonly property real widthScale: launcherWidth === "Compact" ? 0.8
                                     : (launcherWidth === "Wide" ? 1.25 : 1.0)

    property bool _loading: false

    onMaxResultsChanged: scheduleSave()
    onMatchModeChanged: scheduleSave()
    onSearchDescriptionsChanged: scheduleSave()
    onShowRecentsFirstChanged: scheduleSave()
    onRecentLimitChanged: scheduleSave()
    onRecentIdsChanged: scheduleSave()
    onShowIconsChanged: scheduleSave()
    onAnimateResultsChanged: scheduleSave()
    onLauncherWidthChanged: scheduleSave()
    onShrinkForFewResultsChanged: scheduleSave()
    onInlineCalculatorChanged: scheduleSave()
    onClipboardHistoryChanged: scheduleSave()
    onClipboardLimitChanged: scheduleSave()
    onFeaturesChanged: scheduleSave()
    onTriggerEmojiChanged: scheduleSave()
    onTriggerSnippetsChanged: scheduleSave()
    onTriggerNotesChanged: scheduleSave()

    FileView {
        id: file
        path: Quickshell.env("HOME") + "/.config/quickshell/state/launcher-settings.json"
        printErrors: false
        onLoaded: root.applyJson(text())
        onLoadFailed: (error) => root.saveNow()
    }

    // Slider drags fire many changes, so writes are debounced.
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
            maxResults: maxResults,
            matchMode: matchMode,
            searchDescriptions: searchDescriptions,
            showRecentsFirst: showRecentsFirst,
            recentLimit: recentLimit,
            recentIds: recentIds,
            showIcons: showIcons,
            animateResults: animateResults,
            launcherWidth: launcherWidth,
            shrinkForFewResults: shrinkForFewResults,
            inlineCalculator: inlineCalculator,
            clipboardHistory: clipboardHistory,
            clipboardLimit: clipboardLimit,
            features: features,
            triggerEmoji: triggerEmoji,
            triggerSnippets: triggerSnippets,
            triggerNotes: triggerNotes
        }, null, 2))
    }

    function feature(name) {
        return features[name] !== false
    }

    function setFeature(name, value) {
        var copy = {}
        for (var k in features) copy[k] = features[k]
        copy[name] = value
        features = copy
    }

    // A trigger mark must be exactly one character, not a letter or digit,
    // and not one of the marks already fixed in the parser (> ? / :).
    function _basicValidTrigger(ch) {
        return !!ch && ch.length === 1 && !/[a-z0-9]/i.test(ch) && reservedMarks.indexOf(ch) < 0
    }

    // Used by the Settings UI: also rejects a mark already used by one of
    // the other two triggers. Returns false (and changes nothing) on any
    // invalid or duplicate mark.
    function setTrigger(name, raw) {
        var ch = (raw || "").trim().charAt(0)
        if (!_basicValidTrigger(ch)) return false
        if ((name !== "emoji" && ch === triggerEmoji) ||
            (name !== "snippets" && ch === triggerSnippets) ||
            (name !== "notes" && ch === triggerNotes)) return false

        if (name === "emoji") triggerEmoji = ch
        else if (name === "snippets") triggerSnippets = ch
        else if (name === "notes") triggerNotes = ch
        else return false
        return true
    }

    function _num(v, lo, hi, fallback) {
        return (typeof v === "number" && isFinite(v)) ? Math.max(lo, Math.min(hi, Math.round(v))) : fallback
    }
    function _bool(v, fallback) { return typeof v === "boolean" ? v : fallback }
    function _choice(v, allowed, fallback) { return allowed.indexOf(v) >= 0 ? v : fallback }

    function applyJson(txt) {
        if (!txt || txt.trim() === "") { saveNow(); return }

        var d
        try {
            d = JSON.parse(txt)
        } catch (e) {
            console.warn("LauncherSettings: bad settings file, using defaults", e)
            return
        }

        _loading = true
        maxResults = _num(d.maxResults, 3, 15, maxResults)
        matchMode = _choice(d.matchMode, ["Fuzzy", "Prefix"], matchMode)
        searchDescriptions = _bool(d.searchDescriptions, searchDescriptions)
        showRecentsFirst = _bool(d.showRecentsFirst, showRecentsFirst)
        recentLimit = _num(d.recentLimit, 3, 20, recentLimit)
        recentIds = Array.isArray(d.recentIds)
            ? d.recentIds.filter(x => typeof x === "string").slice(0, 20)
            : []
        showIcons = _bool(d.showIcons, showIcons)
        animateResults = _bool(d.animateResults, animateResults)
        launcherWidth = _choice(d.launcherWidth, ["Compact", "Normal", "Wide"], launcherWidth)
        shrinkForFewResults = _bool(d.shrinkForFewResults, shrinkForFewResults)
        inlineCalculator = _bool(d.inlineCalculator, inlineCalculator)
        clipboardHistory = _bool(d.clipboardHistory, clipboardHistory)
        clipboardLimit = _num(d.clipboardLimit, 10, 100, clipboardLimit)

        // Keys from an older save (e.g. "windows", "processes") are simply
        // dropped here since they're no longer in the default `features` set.
        if (d.features && typeof d.features === "object") {
            var f = {}
            for (var k in features) f[k] = _bool(d.features[k], features[k])
            features = f
        }

        if (_basicValidTrigger(d.triggerEmoji)) triggerEmoji = d.triggerEmoji
        if (_basicValidTrigger(d.triggerSnippets)) triggerSnippets = d.triggerSnippets
        if (_basicValidTrigger(d.triggerNotes)) triggerNotes = d.triggerNotes
        _loading = false
    }

    // ---- Recent apps ----
    function recordLaunch(id) {
        if (!id) return
        var list = recentIds.filter(x => x !== id)
        list.unshift(id)
        recentIds = list.slice(0, 20)
    }

    function clearRecents() {
        recentIds = []
    }
}