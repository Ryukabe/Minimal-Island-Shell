// services/CaffeineService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property bool enabled: false

    Process {
        id: inhibitProc
        command: ["systemd-inhibit", "--what=idle:sleep:handle-lid-switch", "--who=HyprDF", "--why=Caffeine mode active", "sleep", "infinity"]

        onRunningChanged: root.enabled = running
        onExited: root.enabled = false
    }

    function toggle() {
        inhibitProc.running = !inhibitProc.running
    }
}