// features/dashboard/DashboardDataService.qml — what the list-style Dashboard components keep:
// countdown dates, study subjects and the checklist. One JSON file, saved shortly after a change.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    // Always reassign these (never push) so change signals fire.
    property var countdowns: []   // { id, label, date: "YYYY-MM-DD" }
    property var subjects: []     // { id, name, percent: 0-100 }
    property var checklist: []    // { id, text, done }

    property bool _loaded: false
    property int _idCounter: 0

    readonly property string _home: Quickshell.env("HOME")

    property FileView dataFile: FileView {
        path: root._home + "/.config/quickshell/state/dashboard-data.json"
        printErrors: false
        onLoaded: root._load(text())
        onLoadFailed: root._loaded = true
    }

    property Timer saveTimer: Timer {
        interval: 300
        onTriggered: root.dataFile.setText(JSON.stringify(root._state(), null, 2))
    }

    // ---------- helpers ----------
    function _state() { return { countdowns: root.countdowns, subjects: root.subjects, checklist: root.checklist } }
    // Never saves before the file has been read, so an early change cannot wipe saved data.
    function _changed() { if (root._loaded) root.saveTimer.restart() }
    function _newId() { root._idCounter++; return Date.now() + "-" + root._idCounter }
    function _list(value) { return Array.isArray(value) ? value : [] }
    function _pct(v) { return Math.max(0, Math.min(100, Math.round(Number(v)) || 0)) }

    function isValidDate(str) {
        var m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(String(str).trim())
        if (!m) return false
        var y = parseInt(m[1])
        var mo = parseInt(m[2])
        var d = parseInt(m[3])
        var dt = new Date(y, mo - 1, d)
        return dt.getFullYear() === y && dt.getMonth() === mo - 1 && dt.getDate() === d
    }

    function _load(txt) {
        var data = {}
        try {
            data = JSON.parse(txt) || {}
        } catch (e) {
            console.warn("DashboardDataService: bad saved data, starting empty", e)
        }
        root.countdowns = root._list(data.countdowns)
            .filter(function (c) { return c && root.isValidDate(String(c.date)) })
            .map(function (c) { return { id: String(c.id), label: String(c.label || ""), date: String(c.date) } })
        root.subjects = root._list(data.subjects)
            .filter(function (s) { return s && s.name })
            .map(function (s) { return { id: String(s.id), name: String(s.name), percent: root._pct(s.percent) } })
        root.checklist = root._list(data.checklist)
            .filter(function (t) { return t && t.text })
            .map(function (t) { return { id: String(t.id), text: String(t.text), done: t.done === true } })
        root._loaded = true
    }

    // ---------- countdowns ----------
    function addCountdown(label, date) {
        var l = String(label).trim()
        var d = String(date).trim()
        if (l === "" || !root.isValidDate(d)) return false
        root.countdowns = root.countdowns.concat([{ id: root._newId(), label: l, date: d }])
        root._changed()
        return true
    }

    function removeCountdown(id) {
        root.countdowns = root.countdowns.filter(function (c) { return c.id !== id })
        root._changed()
    }

    // ---------- study subjects ----------
    function addSubject(name) {
        var n = String(name).trim()
        if (n === "") return false
        root.subjects = root.subjects.concat([{ id: root._newId(), name: n, percent: 0 }])
        root._changed()
        return true
    }

    function setSubjectPercent(id, percent) {
        var p = root._pct(percent)
        root.subjects = root.subjects.map(function (s) {
            return s.id === id ? { id: s.id, name: s.name, percent: p } : s
        })
        root._changed()
    }

    function removeSubject(id) {
        root.subjects = root.subjects.filter(function (s) { return s.id !== id })
        root._changed()
    }

    // ---------- checklist ----------
    function addItem(text) {
        var t = String(text).trim()
        if (t === "") return false
        root.checklist = root.checklist.concat([{ id: root._newId(), text: t, done: false }])
        root._changed()
        return true
    }

    function toggleItem(id) {
        root.checklist = root.checklist.map(function (t) {
            return t.id === id ? { id: t.id, text: t.text, done: !t.done } : t
        })
        root._changed()
    }

    function removeItem(id) {
        root.checklist = root.checklist.filter(function (t) { return t.id !== id })
        root._changed()
    }

    function clearDone() {
        root.checklist = root.checklist.filter(function (t) { return !t.done })
        root._changed()
    }
}