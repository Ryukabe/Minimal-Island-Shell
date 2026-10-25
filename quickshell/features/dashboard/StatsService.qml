// features/dashboard/StatsService.qml — live system numbers for the System stats card.
// One shell command per tick; it only runs while a stats card is on screen (viewers > 0).
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../../core/shell"

QtObject {
    id: root

    // Cards on screen register here; polling stops at 0.
    property int viewers: 0

    property real cpu: 0
    property real memory: 0
    property real memUsedKb: 0
    property real memTotalKb: 0
    property real gpu: -1
    property real rxBps: 0
    property real txBps: 0
    property int battery: -1
    property string batteryStatus: ""
    property real tempC: -1

    readonly property bool hasGpu: gpu >= 0
    readonly property bool hasBattery: battery >= 0
    readonly property bool hasTemp: tempC >= 0
    readonly property bool charging: batteryStatus === "Charging"

    // Always reassigned (never pushed) so change signals fire.
    property var cpuHistory: []
    property var gpuHistory: []
    property var memHistory: []
    property var netHistory: []
    property var batteryHistory: []
    property var tempHistory: []

    property real _prevTotal: 0
    property real _prevIdle: 0
    property real _prevRx: -1
    property real _prevTx: -1
    property real _prevMs: 0

    onViewersChanged: {
        if (viewers === 0) {
            _prevTotal = 0
            _prevRx = -1
        }
    }

    // Every source is detected, nothing is hardcoded to one machine:
    // battery = first BAT*, temperature = hottest thermal zone, GPU = nvidia-smi if present,
    // else the AMD sysfs counter, else "not detected". Network = every interface except lo.
    readonly property string _script: [
        "echo \"cpu $(head -n1 /proc/stat)\"",
        "echo \"mem $(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{print t, a}' /proc/meminfo)\"",
        "echo \"net $(awk 'NR>2 && $1 !~ /^lo:/ {r+=$2; t+=$10} END{print r+0, t+0}' /proc/net/dev)\"",
        "b=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1)",
        "s=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n1)",
        "echo \"bat ${b:--1} ${s:-None}\"",
        "t=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | sort -n | tail -n1)",
        "echo \"temp ${t:--1}\"",
        "g=-1",
        "if command -v nvidia-smi >/dev/null 2>&1; then g=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1)",
        "else f=$(ls /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -n1); if [ -n \"$f\" ]; then g=$(cat \"$f\" 2>/dev/null); fi",
        "fi",
        "echo \"gpu ${g:--1}\""
    ].join("\n")

    function _push(arr, v) {
        var n = Math.max(2, ShellState.dashboardStatsGraphSamples)
        var a = arr.slice()
        a.push(v)
        while (a.length > n) a.shift()
        return a
    }

    function _parse(out) {
        var now = Date.now()
        var lines = out.split("\n")
        for (var i = 0; i < lines.length; i++) {
            var p = lines[i].trim().split(/\s+/)
            if (p.length < 2) continue

            if (p[0] === "cpu") {
                // "cpu cpu user nice system idle iowait irq softirq steal ..."
                var v = p.slice(2).map(Number)
                var idle = (v[3] || 0) + (v[4] || 0)
                var total = 0
                for (var k = 0; k < Math.min(8, v.length); k++) total += v[k]
                if (root._prevTotal > 0) {
                    var dt = total - root._prevTotal
                    var di = idle - root._prevIdle
                    if (dt > 0) root.cpu = Math.max(0, Math.min(100, (1 - di / dt) * 100))
                }
                root._prevTotal = total
                root._prevIdle = idle
            } else if (p[0] === "mem") {
                var tot = Number(p[1])
                var avail = Number(p[2])
                if (tot > 0) {
                    root.memTotalKb = tot
                    root.memUsedKb = tot - avail
                    root.memory = (tot - avail) / tot * 100
                }
            } else if (p[0] === "net") {
                var rx = Number(p[1])
                var tx = Number(p[2])
                var sec = (now - root._prevMs) / 1000
                if (root._prevRx >= 0 && sec > 0) {
                    root.rxBps = Math.max(0, (rx - root._prevRx) / sec)
                    root.txBps = Math.max(0, (tx - root._prevTx) / sec)
                }
                root._prevRx = rx
                root._prevTx = tx
            } else if (p[0] === "bat") {
                var cap = Number(p[1])
                root.battery = isNaN(cap) ? -1 : cap
                root.batteryStatus = p[2] || ""
            } else if (p[0] === "temp") {
                var milli = Number(p[1])
                root.tempC = (isNaN(milli) || milli <= 0) ? -1 : milli / 1000
            } else if (p[0] === "gpu") {
                var g = Number(p[1])
                root.gpu = (isNaN(g) || g < 0) ? -1 : g
            }
        }
        root._prevMs = now

        root.cpuHistory = root._push(root.cpuHistory, root.cpu)
        root.memHistory = root._push(root.memHistory, root.memory)
        root.netHistory = root._push(root.netHistory, root.rxBps + root.txBps)
        if (root.hasGpu) root.gpuHistory = root._push(root.gpuHistory, root.gpu)
        if (root.hasBattery) root.batteryHistory = root._push(root.batteryHistory, root.battery)
        if (root.hasTemp) root.tempHistory = root._push(root.tempHistory, root.tempC)
    }

    function formatRate(bps) {
        var units = ["B/s", "KB/s", "MB/s", "GB/s"]
        var v = bps
        var i = 0
        while (v >= 1024 && i < units.length - 1) { v /= 1024; i++ }
        return (i === 0 ? Math.round(v) : v.toFixed(1)) + " " + units[i]
    }

    function formatTemp(c) {
        return ShellState.systemTempUnit === "°F" ? Math.round(c * 9 / 5 + 32) + "°F" : Math.round(c) + "°C"
    }

    function formatGb(kb) { return (kb / 1048576).toFixed(1) }

    property Process _proc: Process {
        command: ["sh", "-c", root._script]
        stdout: StdioCollector { onStreamFinished: root._parse(text) }
    }

    property Timer _timer: Timer {
        interval: Math.max(500, ShellState.dashboardStatsIntervalSec * 1000)
        repeat: true
        running: root.viewers > 0
        triggeredOnStart: true
        onTriggered: if (!root._proc.running) root._proc.running = true
    }
}