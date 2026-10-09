// pages/about/SystemInfoService.qml — read-only device / OS info, no fake data.
// Not a singleton (no qmldir): SettingsApp.qml creates one instance and hands it to the About page.
// Anything that can't be read stays an empty string and the page shows "—".
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string hostname: ""
    property string osName: ""
    property string kernel: ""
    property string uptime: ""
    property string memoryUsed: ""      // "used / total"
    property string diskUsed: ""        // "used / total"
    property string cpuName: ""
    property string gpuName: ""
    property string hyprlandVersion: ""
    property string quickshellVersion: ""

    function refresh() {
        hostnameProc.running = true
        osReleaseProc.running = true
        kernelProc.running = true
        uptimeProc.running = true
        memProc.running = true
        diskProc.running = true
        cpuProc.running = true
        gpuProc.running = true
        hyprlandProc.running = true
        quickshellProc.running = true
    }

    Component.onCompleted: refresh()

    // Reads /etc/hostname directly rather than shelling out to the
    // `hostname` binary, which isn't guaranteed to be installed.
    Process {
        id: hostnameProc
        command: ["cat", "/etc/hostname"]
        stdout: StdioCollector { onStreamFinished: root.hostname = text.trim() }
    }

    Process {
        id: osReleaseProc
        command: ["sh", "-c", "grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '\"'"]
        stdout: StdioCollector { onStreamFinished: root.osName = text.trim() }
    }

    Process {
        id: kernelProc
        command: ["uname", "-r"]
        stdout: StdioCollector { onStreamFinished: root.kernel = text.trim() }
    }

    Process {
        id: uptimeProc
        command: ["uptime", "-p"]
        stdout: StdioCollector { onStreamFinished: root.uptime = text.trim() }
    }

    Process {
        id: memProc
        command: ["sh", "-c", "free -h | awk '/^Mem:/ {print $3\" / \"$2}'"]
        stdout: StdioCollector { onStreamFinished: root.memoryUsed = text.trim() }
    }

    Process {
        id: diskProc
        command: ["sh", "-c", "df -h / | awk 'NR==2 {print $3\" / \"$2}'"]
        stdout: StdioCollector { onStreamFinished: root.diskUsed = text.trim() }
    }

    // ---- added for the Windows-style tiles and the Software card ----

    Process {
        id: cpuProc
        command: ["sh", "-c", "grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | tr -s ' '"]
        stdout: StdioCollector { onStreamFinished: root.cpuName = text.trim() }
    }

    // Needs pciutils (lspci). If it's missing the tile simply shows "—".
    Process {
        id: gpuProc
        command: ["sh", "-c", "lspci 2>/dev/null | grep -iE 'vga|3d|display' | head -n1 | sed -e 's/^[^ ]* [^:]*: //' -e 's/ (rev [0-9a-f]*)//'"]
        stdout: StdioCollector { onStreamFinished: root.gpuName = text.trim() }
    }

    Process {
        id: hyprlandProc
        command: ["sh", "-c", "hyprctl version 2>/dev/null | grep -m1 -oE '[0-9]+\\.[0-9]+\\.[0-9]+'"]
        stdout: StdioCollector { onStreamFinished: root.hyprlandVersion = text.trim() }
    }

    Process {
        id: quickshellProc
        command: ["sh", "-c", "(quickshell --version || qs --version) 2>/dev/null | head -n1 | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+' | head -n1"]
        stdout: StdioCollector { onStreamFinished: root.quickshellVersion = text.trim() }
    }
}
