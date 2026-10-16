// features/lockscreen/WeatherService.qml — forecast for the one picked location (LocationService).
// There is no city search here any more: pick or detect a location in Language & Region
// and the forecast follows by itself.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../../core/shell"

Item {
    id: root

    readonly property string statePath: Quickshell.env("HOME") + "/.config/quickshell/state/weather.json"
    property bool _loaded: false

    // The place, taken from LocationService ("City, Region, Country").
    readonly property bool hasPlace: LocationService.hasLocation
    readonly property real latitude: LocationService.latitude
    readonly property real longitude: LocationService.longitude
    readonly property string placeName: {
        var l = LocationService.label
        var i = l.indexOf(",")
        return i < 0 ? l : l.slice(0, i).trim()
    }
    readonly property string placeRegion: {
        var l = LocationService.label
        var i = l.indexOf(",")
        return i < 0 ? "" : l.slice(i + 1).trim()
    }

    // Last forecast (cached so an offline start still shows something)
    property bool hasData: false
    property real tempC: 0
    property real feelsC: 0
    property real highC: 0
    property real lowC: 0
    property int code: 0
    property var hourly: []          // [{ hour: 15, tempC: 31.2, code: 2 }]
    property real updatedAt: 0       // ms since epoch

    // Coordinates the stored forecast belongs to, so another place's data is never shown.
    property real _cacheLat: 0
    property real _cacheLon: 0
    property bool _again: false      // the place changed while a request was running

    readonly property string conditionText: root.describe(root.code)

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
    // Follows Language & Region > Weather temperature (ShellState.weatherUnit), so bindings
    // using this update when the unit changes.
    function fmt(c) {
        var v = ShellState.weatherUnit === "°F" ? c * 9 / 5 + 32 : c
        return Math.round(v) + "°"
    }

    function _matchesCache() {
        return Math.abs(root._cacheLat - root.latitude) < 0.0001
            && Math.abs(root._cacheLon - root.longitude) < 0.0001
    }

    function refresh() {
        if (!root.hasPlace) return
        if (forecastProc.running) { root._again = true; return }
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
        if (!root.hasPlace) return
        if (!root.hasData || Date.now() - root.updatedAt > 10 * 60 * 1000) root.refresh()
    }

    // The location was picked, detected or cleared.
    function _placeChanged() {
        if (!root._loaded) return
        if (!root.hasPlace) {
            root.hasData = false
            root.hourly = []
            root.save()
            return
        }
        if (!root._matchesCache()) root.hasData = false
        root.refresh()
    }

    function _onForecast(txt) {
        if (root._again) {                      // answer is for the old place: drop it, ask again
            root._again = false
            retryTimer.restart()
            return
        }

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
        root._cacheLat = root.latitude
        root._cacheLon = root.longitude
        root.updatedAt = Date.now()
        root.hasData = true
        root.save()
    }

    // "latitude"/"longitude" in the file are the coordinates of the saved forecast.
    function _apply(d) {
        if (d.latitude !== undefined) root._cacheLat = d.latitude
        if (d.longitude !== undefined) root._cacheLon = d.longitude
        if (d.tempC !== undefined) root.tempC = d.tempC
        if (d.feelsC !== undefined) root.feelsC = d.feelsC
        if (d.highC !== undefined) root.highC = d.highC
        if (d.lowC !== undefined) root.lowC = d.lowC
        if (d.code !== undefined) root.code = d.code
        if (d.hourly !== undefined) root.hourly = d.hourly
        if (d.updatedAt !== undefined) root.updatedAt = d.updatedAt
        // Only trust the saved forecast if it was for the place that is picked now.
        root.hasData = d.hasData === true && root.hasPlace && root._matchesCache()
    }

    function save() {
        if (!root._loaded) return
        var data = {
            latitude: root._cacheLat, longitude: root._cacheLon,
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
        onLoadFailed: {
            root._loaded = true
            root.refreshIfStale()
        }
    }

    // Choosing a city sets latitude and longitude one after the other; wait for both.
    Timer {
        id: placeDebounce
        interval: 300
        onTriggered: root._placeChanged()
    }

    Connections {
        target: LocationService
        function onLatitudeChanged() { placeDebounce.restart() }
        function onLongitudeChanged() { placeDebounce.restart() }
        function onHasLocationChanged() { placeDebounce.restart() }
    }

    Timer {
        id: retryTimer
        interval: 300
        onTriggered: root.refresh()
    }

    Timer {
        interval: 30 * 60 * 1000
        repeat: true
        running: root.hasPlace
        onTriggered: root.refresh()
    }

    Process {
        id: forecastProc
        stdout: StdioCollector { onStreamFinished: root._onForecast(text) }
    }

    Process { id: saveProc }
}