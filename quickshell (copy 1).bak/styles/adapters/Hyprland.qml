pragma Singleton
import QtQuick
import Quickshell.Io
import ".."
import "../../services"

Item {
    id: root
    Process { id: activeProc }
    Process { id: inactiveProc }

    readonly property bool active: ShellState.templatesEnabled && ShellState.templateHyprland

    function apply() {
        if (!Colors.loaded || !root.active) return;
        activeProc.command = ["hyprctl", "keyword", "general:col.active_border", "rgba(" + Colors.toHex(Colors.accent).substring(1) + "ff)"]
        activeProc.running = true
        inactiveProc.command = ["hyprctl", "keyword", "general:col.inactive_border", "rgba(" + Colors.toHex(Colors.border).substring(1) + "ff)"]
        inactiveProc.running = true
    }

    Connections {
        target: Colors
        function onActivePaletteChanged() { root.apply() }
    }

    onActiveChanged: root.apply()
}