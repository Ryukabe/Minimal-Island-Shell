// pages/about/SystemInfoService.qml — reads hardware and OS info for the About page.
// Plain component (no qmldir). SettingsApp.qml creates one and hands it to About.qml.
// Needs on PATH: free, df, uptime (procps/coreutils), lspci (pciutils), quickshell, hyprctl.
// memoryUsed and diskUsed are "used / total" strings; About splits them on " / ".
import QtQuick
import Quickshell.Io

Item {
    id: root
    visible: false

    property string hostname: ""
    property string cpuName: ""
    property string gpuName: ""
    property string osName: ""
    property string kernel: ""
    property string uptime: ""
    property string memoryUsed: ""
    property string diskUsed: ""
    property string quickshellVersion: ""
    property string hyprlandVersion: ""

    readonly property var _keys: [
        "hostname", "cpuName", "gpuName", "osName", "kernel", "uptime",
        "memoryUsed", "diskUsed", "quickshellVersion", "hyprlandVersion"
    ]

    // One shell line per value: "key=value". Unquoted echo keeps each value on one line.
    readonly property var _probes: [
        "echo hostname=$(cat /proc/sys/kernel/hostname)",
        "echo cpuName=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed -E 's/[(](R|TM)[)]//g; s/ +/ /g')",
        "echo gpuName=$(lspci 2>/dev/null | grep -iE 'vga|3d controller|display controller' | sed -E 's/^[^ ]+ [^:]+: //; s/ [(]rev [^)]*[)]//; s/.*[[]([^]]*)[]].*/\\1/' | paste -sd'|' - | sed 's/|/ + /g')",
        "echo osName=$(. /etc/os-release 2>/dev/null && echo $PRETTY_NAME)",
        "echo kernel=$(uname -r)",
        "echo uptime=$(uptime -p | sed 's/^up //')",
        "echo memoryUsed=$(free -b | awk '/^Mem:/ {printf \"%.1f GiB / %.1f GiB\", $3/1073741824, $2/1073741824}')",
        "echo diskUsed=$(df -B1 / | awk 'NR==2 {printf \"%.0f GiB / %.0f GiB\", $3/1073741824, $2/1073741824}')",
        "echo quickshellVersion=$(quickshell --version 2>/dev/null | head -1 | sed -E 's/^quickshell +//; s/,.*//')",
        "echo hyprlandVersion=$(hyprctl version 2>/dev/null | head -1 | sed -E 's/^Hyprland +//; s/ built.*//; s/,.*//')"
    ]

    function refresh() {
        if (!probe.running) probe.running = true
    }

    Component.onCompleted: root.refresh()

    Process {
        id: probe
        command: ["sh", "-c", root._probes.join("; ")]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n")
                for (let i = 0; i < lines.length; i++) {
                    const eq = lines[i].indexOf("=")
                    if (eq < 1) continue
                    const key = lines[i].substring(0, eq)
                    if (root._keys.indexOf(key) < 0) continue
                    root[key] = lines[i].substring(eq + 1).trim()
                }
            }
        }
    }
}