// styles/adapters/Gtk4.qml
pragma Singleton
import QtQuick
import Quickshell.Io
import ".."
import "../../shell"

Item {
    id: root

    readonly property string cssPath: "$HOME/.config/gtk-4.0/gtk.css"
    readonly property bool active: ShellState.templatesEnabled && ShellState.templateGtk4

    Process {
        id: proc
        stderr: SplitParser {
            onRead: data => console.log("[Gtk4] write stderr:", data)
        }
    }

    function buildCss() {
        return "@define-color window_bg_color " + Colors.toHex(Colors.bg) + ";\n" +
               "@define-color window_fg_color " + Colors.toHex(Colors.fg) + ";\n" +
               "@define-color view_bg_color " + Colors.toHex(Colors.bgsur) + ";\n" +
               "@define-color view_fg_color " + Colors.toHex(Colors.fg) + ";\n" +
               "@define-color accent_bg_color " + Colors.toHex(Colors.accent) + ";\n" +
               "@define-color accent_fg_color " + Colors.toHex(Colors.bg) + ";\n" +
               "@define-color accent_color " + Colors.toHex(Colors.accent) + ";\n" +
               "@define-color headerbar_bg_color " + Colors.toHex(Colors.bgsur) + ";\n" +
               "@define-color headerbar_fg_color " + Colors.toHex(Colors.fg) + ";\n" +
               "@define-color headerbar_backdrop_color " + Colors.toHex(Colors.bg) + ";\n" +
               "@define-color popover_bg_color " + Colors.toHex(Colors.bgsur) + ";\n" +
               "@define-color popover_fg_color " + Colors.toHex(Colors.fg) + ";\n" +
               "@define-color dialog_bg_color " + Colors.toHex(Colors.bgsur) + ";\n" +
               "@define-color dialog_fg_color " + Colors.toHex(Colors.fg) + ";\n" +
               "@define-color card_bg_color " + Colors.toHex(Colors.bgsur) + ";\n" +
               "@define-color card_fg_color " + Colors.toHex(Colors.fg) + ";\n" +
               "@define-color sidebar_bg_color " + Colors.toHex(Colors.bgsur) + ";\n" +
               "@define-color sidebar_fg_color " + Colors.toHex(Colors.fg) + ";\n" +
               "@define-color sidebar_backdrop_color " + Colors.toHex(Colors.bg) + ";\n"
    }

    function apply() {
        if (!Colors.loaded || !root.active) return;
        proc.command = ["bash", "-c",
            'mkdir -p "$HOME/.config/gtk-4.0" && printf "%s" \'' + root.buildCss() + '\' > /tmp/gtk4-theme.css.tmp && mv /tmp/gtk4-theme.css.tmp "' + root.cssPath + '"']
        proc.running = true
    }

    Connections {
        target: Colors
        function onActivePaletteChanged() { root.apply() }
    }

    onActiveChanged: root.apply()
}