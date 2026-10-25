// core/SettingsPicker.qml — state of the select page (one at a time).
// Any page opens it through PickerRow; the single PickerSheet in SettingsApp.qml shows it.
// Two modes: local (the sheet filters `items` as you type) and remote (`onSearch` is called
// as you type and the page replaces the list through setItems / status).
pragma Singleton
import QtQuick

QtObject {
    id: root

    property bool opened: false
    property string title: ""
    property string searchHint: "Search..."
    property var items: []            // [{ value, label }]
    property string selectedValue: ""
    property bool remote: false
    property string status: ""        // shown when a remote list is empty
    property string initialQuery: ""  // search text the sheet starts with
    property var _onPick: null
    property var _onSearch: null

    function _normalize(src) {
        var list = []
        for (var i = 0; i < src.length; i++) {
            var it = src[i]
            if (typeof it === "string") list.push({ value: it, label: it })
            else list.push({ value: it.value, label: it.label !== undefined ? it.label : it.value })
        }
        return list
    }

    // options: { title, searchHint, items (strings or { value, label }), selectedValue,
    //            initialQuery, onPick(value), onSearch(query) (makes the sheet remote) }
    function open(options) {
        title = options.title || ""
        searchHint = options.searchHint || "Search..."
        items = _normalize(options.items || [])
        selectedValue = options.selectedValue !== undefined ? options.selectedValue : ""
        initialQuery = options.initialQuery || ""
        status = ""
        _onPick = options.onPick || null
        _onSearch = typeof options.onSearch === "function" ? options.onSearch : null
        remote = _onSearch !== null
        opened = true
    }

    function setItems(list) {
        items = _normalize(list || [])
    }

    function search(query) {
        if (_onSearch) _onSearch(query)
    }

    function close() {
        opened = false
        _onPick = null
        _onSearch = null
    }

    function pick(value) {
        var cb = _onPick
        close()
        if (cb) cb(value)
    }
}