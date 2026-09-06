// settings/services/SystemInfoService.qml — read-only device/OS info, no fake data
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string hostname: ""
    property string osName: ""
    property string kernel: ""
    property string uptime: ""
    property string memoryUsed: ""
    property string diskUsed: ""

    function refresh() {
        hostnameProc.running = true
        osReleaseProc.running = true
        kernelProc.running = true
        uptimeProc.running = true
        memProc.running = true
        diskProc.running = true
    }

    Component.onCompleted: refresh()

    Process {
        id: hostnameProc
        command: ["hostname"]
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
}