// services/LauncherSettings.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ---- Search ----
    property int maxResults: 8                  // cap on SEARCH results (browsing with no query shows every app)
    property string matchMode: "Fuzzy"          // "Fuzzy" | "Prefix"
    property bool searchDescriptions: true      // also match Comment / GenericName / Keywords

    // ---- Recent apps ----
    property bool showRecentsFirst: true
    property int recentLimit: 10
    property var recentIds: []                  // newest first, up to 20 stored

    // ---- Appearance ----
    property bool showIcons: true
    property bool animateResults: true
    property string launcherWidth: "Normal"     // "Compact" | "Normal" | "Wide"
    property bool shrinkForFewResults: true

    // ---- Extras ----
    property bool inlineCalculator: true        // stored only, no calculator exists yet
    property bool clipboardHistory: true        // gates the ":" clipboard trigger
    property int clipboardLimit: 100            // how many clipboard entries are shown

    // Multiplier applied to ShellState.launcherWidth
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

    FileView {
        id: file
        path: Quickshell.env("HOME") + "/.config/quickshell/launcher-settings.json"
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
            clipboardLimit: clipboardLimit
        }, null, 2))
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