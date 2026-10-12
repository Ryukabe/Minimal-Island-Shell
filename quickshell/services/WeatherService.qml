// services/WeatherService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string statePath: Quickshell.env("HOME") + "/.config/quickshell/state/weather.json"
    property bool _loaded: false

    // Chosen place
    property string placeName: ""
    property string placeRegion: ""
    property real latitude: 0
    property real longitude: 0
    readonly property bool hasPlace: root.placeName !== ""

    // Last forecast (cached so an offline start still shows something)
    property bool hasData: false
    property real tempC: 0
    property real feelsC: 0
    property real highC: 0
    property real lowC: 0
    property int code: 0
    property var hourly: []          // [{ hour: 15, tempC: 31.2, code: 2 }]
    property real updatedAt: 0       // ms since epoch

    readonly property string conditionText: root.describe(root.code)

    // City search (the settings page will use these)
    property var results: []         // [{ name, region, lat, lon }]
    property string searchStatus: "" // "", "searching", "none", "error"

    function describe(c) {
        if (c === 0) return "Clear"
        if (c === 1) return "Mainly clear"
        if (c === 2) return "Partly cloudy"
        if (c === 3) return "Overcast"
        if (c === 45 || c === 48) return "Fog"
        if (c >= 51 && c <= 57) return "Drizzle"
        if (c >= 61 && c <= 67) return "Rain"
        if (c >= 71 && c <= 77) return "Snow"
        if (c >= 80 && c <= 82) return "Showers"
        if (c === 85 || c === 86) return "Snow showers"
        if (c >= 95) return "Thunderstorm"
        return ""
    }

    // Reads LockScreenSettings.weatherFahrenheit, so bindings using this update when the unit changes.
    function fmt(c) {
        var v = LockScreenSettings.weatherFahrenheit ? c * 9 / 5 + 32 : c
        return Math.round(v) + "°"
    }

    function search(query) {
        var q = (query || "").trim()
        if (q === "" || geoProc.running) return
        root.searchStatus = "searching"
        geoProc.command = ["curl", "-sf", "--max-time", "15",
            "https://geocoding-api.open-meteo.com/v1/search?count=5&language=en&format=json&name="
            + encodeURIComponent(q)]
        geoProc.running = true
    }

    function choose(i) {
        var r = root.results[i]
        if (!r) return
        root.placeName = r.name
        root.placeRegion = r.region
        root.latitude = r.lat
        root.longitude = r.lon
        root.hasData = false
        root.results = []
        root.searchStatus = ""
        root.save()
        root.refresh()
    }

    function refresh() {
        if (!root.hasPlace || forecastProc.running) return
        forecastProc.command = ["curl", "-sf", "--max-time", "15",
            "https://api.open-meteo.com/v1/forecast?latitude=" + root.latitude
            + "&longitude=" + root.longitude
            + "&current=temperature_2m,apparent_temperature,weather_code"
            + "&hourly=temperature_2m,weather_code"
            + "&daily=temperature_2m_max,temperature_2m_min"
            + "&forecast_days=2&timezone=auto"]
        forecastProc.running = true
    }

    function refreshIfStale() {
        if (root.hasPlace && Date.now() - root.updatedAt > 10 * 60 * 1000) root.refresh()
    }

    function _onGeo(txt) {
        var list
        try { list = JSON.parse(txt).results || [] }
        catch (e) { root.searchStatus = "error"; return }
        root.results = list.map(function (x) {
            return {
                name: x.name,
                region: [x.admin1, x.country].filter(Boolean).join(", "),
                lat: x.latitude,
                lon: x.longitude
            }
        })
        root.searchStatus = list.length > 0 ? "" : "none"
    }

    function _onForecast(txt) {
        var d
        try { d = JSON.parse(txt) } catch (e) { return }   // offline: keep the cache
        if (!d || !d.current || !d.hourly || !d.daily) return

        root.tempC = d.current.temperature_2m
        root.feelsC = d.current.apparent_temperature
        root.code = d.current.weather_code
        root.highC = d.daily.temperature_2m_max[0]
        root.lowC = d.daily.temperature_2m_min[0]

        var nowHour = d.current.time.slice(0, 13) + ":00"
        var out = []
        for (var i = 0; i < d.hourly.time.length && out.length < 6; i++) {
            if (d.hourly.time[i] > nowHour)
                out.push({
                    hour: parseInt(d.hourly.time[i].slice(11, 13)),
                    tempC: d.hourly.temperature_2m[i],
                    code: d.hourly.weather_code[i]
                })
        }
        root.hourly = out
        root.updatedAt = Date.now()
        root.hasData = true
        root.save()
    }

    function _apply(d) {
        if (d.placeName !== undefined) root.placeName = d.placeName
        if (d.placeRegion !== undefined) root.placeRegion = d.placeRegion
        if (d.latitude !== undefined) root.latitude = d.latitude
        if (d.longitude !== undefined) root.longitude = d.longitude
        if (d.hasData !== undefined) root.hasData = d.hasData
        if (d.tempC !== undefined) root.tempC = d.tempC
        if (d.feelsC !== undefined) root.feelsC = d.feelsC
        if (d.highC !== undefined) root.highC = d.highC
        if (d.lowC !== undefined) root.lowC = d.lowC
        if (d.code !== undefined) root.code = d.code
        if (d.hourly !== undefined) root.hourly = d.hourly
        if (d.updatedAt !== undefined) root.updatedAt = d.updatedAt
    }

    function save() {
        if (!root._loaded) return
        var data = {
            placeName: root.placeName, placeRegion: root.placeRegion,
            latitude: root.latitude, longitude: root.longitude,
            hasData: root.hasData, tempC: root.tempC, feelsC: root.feelsC,
            highC: root.highC, lowC: root.lowC, code: root.code,
            hourly: root.hourly, updatedAt: root.updatedAt
        }
        saveProc.command = ["sh", "-c",
            "mkdir -p \"$(dirname \"$2\")\"; printf '%s' \"$1\" > \"$2\"",
            "sh", JSON.stringify(data), root.statePath]
        saveProc.running = true
    }

    FileView {
        path: root.statePath
        onLoaded: {
            try { root._apply(JSON.parse(text())) }
            catch (e) { console.log("[WeatherService] parse error:", e) }
            root._loaded = true
            root.refreshIfStale()
        }
        onLoadFailed: root._loaded = true
    }

    Timer {
        interval: 30 * 60 * 1000
        repeat: true
        running: root.hasPlace
        onTriggered: root.refresh()
    }

    Process {
        id: geoProc
        stdout: StdioCollector { onStreamFinished: root._onGeo(text) }
    }

    Process {
        id: forecastProc
        stdout: StdioCollector { onStreamFinished: root._onForecast(text) }
    }

    Process { id: saveProc }
}