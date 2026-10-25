// features/lockscreen/LocationService.qml — the one picked location: weather coordinates + clock time zone.
// The choice lives in ShellState.location* (persisted); this service searches cities,
// detects the computer's location from its IP, writes the choice, and converts times for every clock.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../../core/shell"

Singleton {
    id: root

    readonly property string geocodingUrl: "https://geocoding-api.open-meteo.com/v1/search"
    readonly property string ipLookupUrl: "https://ipwho.is/"
    readonly property int searchResultCount: 10
    readonly property int searchDebounceMs: 350
    readonly property int detectTimeoutMs: 20000
    readonly property int offsetRefreshMs: 60000

    // ---- The picked location (read these from weather and clock code) ----
    readonly property bool hasLocation: ShellState.locationLabel !== ""
    readonly property string label: ShellState.locationLabel
    readonly property real latitude: ShellState.locationLatitude
    readonly property real longitude: ShellState.locationLongitude
    readonly property string timezone: ShellState.locationTimezone

    // ---- Time zone offset ----
    property int offsetMinutes: 0
    property bool offsetKnown: false
    // True once the offset of the picked time zone is known; until then clocks show system time.
    readonly property bool active: timezone !== "" && offsetKnown

    readonly property string offsetLabel: {
        if (!active) return ""
        var a = Math.abs(offsetMinutes)
        var hh = ("0" + Math.floor(a / 60)).slice(-2)
        var mm = ("0" + (a % 60)).slice(-2)
        return "UTC" + (offsetMinutes < 0 ? "-" : "+") + hh + ":" + mm
    }

    // Returns a Date whose local fields (hours, minutes, ...) show the wall time at the picked
    // location, so Qt.formatDateTime(LocationService.localize(clock.date), fmt) just works.
    // Reads `active` and `offsetMinutes` so bindings update when either changes.
    function localize(date) {
        if (!date || !active) return date
        var u = new Date(date.getTime() + offsetMinutes * 60000)
        return new Date(u.getUTCFullYear(), u.getUTCMonth(), u.getUTCDate(),
                        u.getUTCHours(), u.getUTCMinutes(), u.getUTCSeconds())
    }

    onTimezoneChanged: {
        offsetKnown = false
        refreshOffset()
    }

    Component.onCompleted: refreshOffset()

    function refreshOffset() {
        offsetProc.running = false
        if (timezone === "") {
            offsetKnown = false
            return
        }
        // First line echoes the zone so output from a stale run can be recognised and ignored.
        offsetProc.command = ["sh", "-c", 'echo "$1"; TZ="$1" date +%z', "sh", timezone]
        offsetProc.running = true
    }

    function _parseOffset(text) {
        var lines = text.trim().split("\n")
        if (lines.length < 2 || lines[0] !== root.timezone) return
        var m = lines[1].match(/^([+-])(\d{2})(\d{2})$/)
        if (!m) return
        var mins = parseInt(m[2]) * 60 + parseInt(m[3])
        offsetMinutes = m[1] === "-" ? -mins : mins
        offsetKnown = true
    }

    Process {
        id: offsetProc
        stdout: StdioCollector {
            onStreamFinished: root._parseOffset(text)
        }
    }

    // Keeps the offset right across daylight saving changes.
    Timer {
        interval: root.offsetRefreshMs
        repeat: true
        running: root.timezone !== ""
        onTriggered: root.refreshOffset()
    }

    // ---- City search (for the select page) ----
    property var _byKey: ({})
    property int _seq: 0
    property string _query: ""
    property var _done: null

    // done(items | null, status): null keeps the list on screen while a new search runs.
    function search(query, done) {
        _done = done
        _query = (query || "").trim()
        _seq++
        debounce.stop()
        if (_query.length < 2) {
            done([], "Type at least 2 letters")
            return
        }
        done(null, "Searching...")
        debounce.restart()
    }

    Timer {
        id: debounce
        interval: root.searchDebounceMs
        onTriggered: root._run()
    }

    function _run() {
        var seq = root._seq
        var done = root._done
        var xhr = new XMLHttpRequest()
        var url = root.geocodingUrl + "?name=" + encodeURIComponent(root._query)
            + "&count=" + root.searchResultCount + "&language=en&format=json"

        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (seq !== root._seq || !done) return   // a newer search replaced this one

            if (xhr.status !== 200) {
                done([], "Search failed. Check your internet connection")
                return
            }

            var data
            try { data = JSON.parse(xhr.responseText) }
            catch (e) { done([], "Search failed"); return }

            var found = data.results || []
            var map = {}
            var items = []
            for (var i = 0; i < found.length; i++) {
                var r = found[i]
                var text = root._makeLabel(r.name, r.admin1, r.country)
                var key = r.latitude.toFixed(4) + "," + r.longitude.toFixed(4)
                if (map[key]) continue
                map[key] = {
                    label: text,
                    latitude: r.latitude,
                    longitude: r.longitude,
                    timezone: r.timezone || ""
                }
                items.push({ value: key, label: text })
            }
            root._byKey = map
            done(items, items.length === 0 ? "No cities found" : "")
        }

        xhr.open("GET", url)
        xhr.send()
    }

    // "City, Region, Country" (region skipped when it repeats the city name).
    function _makeLabel(city, region, country) {
        var parts = [city]
        if (region && region !== city) parts.push(region)
        if (country) parts.push(country)
        return parts.join(", ")
    }

    // ---- Automatic detection (from this computer's public IP) ----
    // City-level only, and a VPN shows the VPN's city. Runs only when asked.
    property bool detecting: false
    property string detectStatus: ""
    property int _detectSeq: 0

    function detect() {
        if (detecting) return
        detecting = true
        detectStatus = "Looking up your location..."
        var seq = ++_detectSeq
        detectTimeout.restart()

        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (seq !== root._detectSeq) return     // timed out already
            detectTimeout.stop()
            root.detecting = false

            if (xhr.status !== 200) {
                root.detectStatus = "Couldn't reach the lookup service. Check your internet connection"
                return
            }

            var d
            try { d = JSON.parse(xhr.responseText) }
            catch (e) { root.detectStatus = "The lookup service sent something unexpected"; return }

            if (!d || d.latitude === undefined || d.longitude === undefined || !d.city) {
                root.detectStatus = "Couldn't work out your location. Pick a city instead"
                return
            }

            var text = root._makeLabel(d.city, d.region, d.country)
            root._write(text, d.latitude, d.longitude, (d.timezone && d.timezone.id) ? d.timezone.id : "")
            root.detectStatus = "Detected: " + text
        }

        xhr.open("GET", root.ipLookupUrl)
        xhr.send()
    }

    Timer {
        id: detectTimeout
        interval: root.detectTimeoutMs
        onTriggered: {
            root._detectSeq++                       // ignore a late answer
            root.detecting = false
            root.detectStatus = "The lookup took too long. Try again"
        }
    }

    // ---- Writing the choice ----
    function _write(text, lat, lon, tz) {
        ShellState.locationLabel = text
        ShellState.locationLatitude = lat
        ShellState.locationLongitude = lon
        ShellState.locationTimezone = tz
    }

    function choose(key) {
        if (key === "") { clear(); return }
        var r = _byKey[key]
        if (!r) return
        detectStatus = ""
        _write(r.label, r.latitude, r.longitude, r.timezone)
    }

    function clear() {
        detectStatus = ""
        _write(ShellState.defaults.locationLabel,
               ShellState.defaults.locationLatitude,
               ShellState.defaults.locationLongitude,
               ShellState.defaults.locationTimezone)
    }
}