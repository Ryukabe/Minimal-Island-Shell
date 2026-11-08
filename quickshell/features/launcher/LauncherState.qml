// features/launcher/LauncherState.qml — saved Launcher options (state/launcher-settings.json).
// The panel width and visible rows live in ShellState (launcherWidth, launcherMaxRows).
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../settings/core"
import "../../core/shell"

Singleton {
    id: root

    readonly property var defaults: ({
        maxResults: 8,
        matchMode: "Fuzzy",
        searchDescriptions: true,
        showRecentsFirst: true,
        recentLimit: 10,
        showIcons: true,
        animateResults: true,
        shrinkForFewResults: true,
        viewMode: "List",
        gridColumns: 4,
        inlineCalculator: true,
        clipboardHistory: true,
        clipboardLimit: 100,
        features: { commands: true, web: true, files: true, system: true, units: true, emoji: true, snippets: true, notes: true },
        triggerEmoji: ";",
        triggerSnippets: "\"",
        triggerNotes: "-"
    })

    // ---- Search ----
    property int maxResults: root.defaults.maxResults
    property string matchMode: root.defaults.matchMode               // "Fuzzy" | "Prefix"
    property bool searchDescriptions: root.defaults.searchDescriptions

    // ---- Recent apps ----
    property bool showRecentsFirst: root.defaults.showRecentsFirst
    property int recentLimit: root.defaults.recentLimit
    property var recentIds: []

    // ---- Appearance ----
    property bool showIcons: root.defaults.showIcons
    property bool animateResults: root.defaults.animateResults
    property bool shrinkForFewResults: root.defaults.shrinkForFewResults
    property string viewMode: root.defaults.viewMode                 // "List" | "Grid" (apps only; emoji is always a grid)
    property int gridColumns: root.defaults.gridColumns              // 3..6, app grid only

    // ---- Extras ----
    property bool inlineCalculator: root.defaults.inlineCalculator
    property bool clipboardHistory: root.defaults.clipboardHistory
    property int clipboardLimit: root.defaults.clipboardLimit

    // ---- Feature switches (one per launcher provider) ----
    property var features: root.defaults.features

    // ---- Trigger marks for emoji / snippets / notes. Reserved: > ? / : ----
    property string triggerEmoji: root.defaults.triggerEmoji
    property string triggerSnippets: root.defaults.triggerSnippets
    property string triggerNotes: root.defaults.triggerNotes
    readonly property var reservedMarks: [">", "?", "/", ":"]

    // Old saves kept a width preset here ("Compact" | "Normal" | "Wide"). The width is now the one
    // slider ShellState.launcherWidth, so the preset is folded into it once and then dropped.
    property real _legacyWidthScale: 0

    property bool _loading: false

    onMaxResultsChanged: scheduleSave()
    onMatchModeChanged: scheduleSave()
    onSearchDescriptionsChanged: scheduleSave()
    onShowRecentsFirstChanged: scheduleSave()
    onRecentLimitChanged: scheduleSave()
    onRecentIdsChanged: scheduleSave()
    onShowIconsChanged: scheduleSave()
    onAnimateResultsChanged: scheduleSave()
    onShrinkForFewResultsChanged: scheduleSave()
    onViewModeChanged: scheduleSave()
    onGridColumnsChanged: scheduleSave()
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

    Connections {
        target: SettingsStore
        function onSettingsLoaded() { root._migrateWidth() }
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
            shrinkForFewResults: shrinkForFewResults,
            viewMode: viewMode,
            gridColumns: gridColumns,
            inlineCalculator: inlineCalculator,
            clipboardHistory: clipboardHistory,
            clipboardLimit: clipboardLimit,
            features: features,
            triggerEmoji: triggerEmoji,
            triggerSnippets: triggerSnippets,
            triggerNotes: triggerNotes
        }, null, 2))
    }

    // Back to the defaults. The recent apps history is not an option, so it stays (use Clear for that).
    function resetToDefaults() {
        _loading = true
        maxResults = defaults.maxResults
        matchMode = defaults.matchMode
        searchDescriptions = defaults.searchDescriptions
        showRecentsFirst = defaults.showRecentsFirst
        recentLimit = defaults.recentLimit
        showIcons = defaults.showIcons
        animateResults = defaults.animateResults
        shrinkForFewResults = defaults.shrinkForFewResults
        viewMode = defaults.viewMode
        gridColumns = defaults.gridColumns
        inlineCalculator = defaults.inlineCalculator
        clipboardHistory = defaults.clipboardHistory
        clipboardLimit = defaults.clipboardLimit
        features = defaults.features
        triggerEmoji = defaults.triggerEmoji
        triggerSnippets = defaults.triggerSnippets
        triggerNotes = defaults.triggerNotes
        _loading = false
        saveNow()
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

    // Runs once, as soon as both this file and the shell settings are loaded. The launcher was never
    // narrower than the island's minimum expanded width, so that floor is kept to look the same.
    function _migrateWidth() {
        if (root._legacyWidthScale <= 0 || !SettingsStore.ready) return
        var px = Math.max(ShellState.islandMinExpandedWidth, ShellState.launcherWidth * root._legacyWidthScale)
        ShellState.launcherWidth = Math.max(300, Math.min(1000, Math.round(px / 10) * 10))
        root._legacyWidthScale = 0
        root.scheduleSave()
    }

    function applyJson(txt) {
        if (!txt || txt.trim() === "") { saveNow(); return }

        var d
        try {
            d = JSON.parse(txt)
        } catch (e) {
            console.warn("LauncherState: bad settings file, using defaults", e)
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
        shrinkForFewResults = _bool(d.shrinkForFewResults, shrinkForFewResults)
        viewMode = _choice(d.viewMode, ["List", "Grid"], viewMode)
        gridColumns = _num(d.gridColumns, 3, 6, gridColumns)
        inlineCalculator = _bool(d.inlineCalculator, inlineCalculator)
        clipboardHistory = _bool(d.clipboardHistory, clipboardHistory)
        clipboardLimit = _num(d.clipboardLimit, 10, 100, clipboardLimit)

        if (typeof d.launcherWidth === "string") {
            root._legacyWidthScale = d.launcherWidth === "Compact" ? 0.8 : (d.launcherWidth === "Wide" ? 1.25 : 1.0)
        }

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

        root._migrateWidth()
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