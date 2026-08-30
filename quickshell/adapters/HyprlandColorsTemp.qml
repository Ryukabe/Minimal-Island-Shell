pragma Singleton
import QtQuick
import Quickshell.Io
import "../styles"

Item {
    id: root
    Process { id: activeProc }
    Process { id: inactiveProc }

    Connections {
        target: Colors
        function onActivePaletteChanged() {
            if (!Colors.loaded) return;
            activeProc.command = ["hyprctl", "keyword", "general:col.active_border", "rgba(" + Colors.toHex(Colors.accent).substring(1) + "ff)"]
            activeProc.running = true
            inactiveProc.command = ["hyprctl", "keyword", "general:col.inactive_border", "rgba(" + Colors.toHex(Colors.border).substring(1) + "ff)"]
            inactiveProc.running = true
        }
    }
}
