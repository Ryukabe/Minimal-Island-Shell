pragma Singleton
import QtQuick
import Quickshell.Io
import ".."
import "../../shell"

Item {
    id: root
    readonly property string path: "$HOME/.config/qt6ct/colors/hermit.conf"
    readonly property bool active: ShellState.templatesEnabled && ShellState.templateQt6ct
    Process { id: proc }

    // 21 roles, in Qt's QPalette order.
    function roles(disabled) {
        function q(v) { return "#ff" + Colors.toHex(v).substring(1) }
        var text = disabled ? Colors.fgMuted : Colors.fg
        return [
            text, Colors.bgsur, Qt.lighter(Colors.bgsur, 1.3), Qt.lighter(Colors.bgsur, 1.15),
            Qt.darker(Colors.bgsur, 1.3), Qt.darker(Colors.bgsur, 1.15), text, Colors.fg, text,
            Colors.bgsur, Colors.bg, "#000000", Colors.accent, Colors.bg, Colors.blue, Colors.purple,
            Colors.bg, Colors.bg, Colors.bgsur, Colors.fg, Colors.fgMuted
        ].map(function (v) { return typeof v === "string" ? "#ff" + v.substring(1) : q(v) }).join(", ")
    }

    function buildConf() {
        return "[ColorScheme]\n" +
               "active_colors=" + root.roles(false) + "\n" +
               "disabled_colors=" + root.roles(true) + "\n" +
               "inactive_colors=" + root.roles(false) + "\n"
    }

    function apply() {
        if (!Colors.loaded || !root.active) return;
        proc.command = ["bash", "-c",
            'mkdir -p "$HOME/.config/qt6ct/colors" && printf "%s" \'' + root.buildConf() + '\' > /tmp/qt6ct-theme.tmp && mv /tmp/qt6ct-theme.tmp "' + root.path + '"']
        proc.running = true
    }

    Connections { target: Colors; function onActivePaletteChanged() { root.apply() } }
    onActiveChanged: root.apply()
}