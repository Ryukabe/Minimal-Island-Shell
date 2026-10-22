// styles/adapters/Gtk4.qml
pragma Singleton
import QtQuick
import Quickshell.Io
import ".."
import "../../shell"

Item {
    id: root

    readonly property string dir: "$HOME/.config/gtk-4.0"
    readonly property string cssPath: root.dir + "/gtk.css"
    readonly property bool active: ShellState.templatesEnabled && ShellState.templateGtk4

    Process {
        id: proc
        stderr: SplitParser {
            onRead: data => console.log("[Gtk4] write stderr:", data)
        }
    }

    function def(name, color) {
        return "@define-color " + name + " " + Colors.toHex(color) + ";\n"
    }

    function buildCss() {
        return def("window_bg_color", Colors.bg) +
               def("window_fg_color", Colors.fg) +
               def("view_bg_color", Colors.bgsur) +
               def("view_fg_color", Colors.fg) +
               def("card_bg_color", Colors.bgsur) +
               def("card_fg_color", Colors.fg) +
               def("dialog_bg_color", Colors.bg) +
               def("dialog_fg_color", Colors.fg) +
               def("popover_bg_color", Colors.bgsur) +
               def("popover_fg_color", Colors.fg) +
               def("headerbar_bg_color", Colors.bg) +
               def("headerbar_fg_color", Colors.fg) +
               def("headerbar_border_color", Colors.bg) +
               def("headerbar_backdrop_color", Colors.bg) +
               def("sidebar_bg_color", Colors.bg) +
               def("sidebar_fg_color", Colors.fg) +
               def("sidebar_backdrop_color", Colors.bg) +
               def("sidebar_border_color", Colors.bg) +
               def("accent_bg_color", Colors.accent) +
               def("accent_fg_color", Colors.bg) +
               def("accent_color", Qt.lighter(Colors.accent, 1.2)) +
               def("destructive_bg_color", Colors.red) +
               def("destructive_fg_color", Colors.bg) +
               def("destructive_color", Colors.red) +
               def("error_bg_color", Colors.red) +
               def("error_fg_color", Colors.bg) +
               def("error_color", Colors.red) +
               def("success_bg_color", Colors.green) +
               def("success_fg_color", Colors.bg) +
               def("success_color", Colors.green) +
               def("warning_bg_color", Colors.yellow) +
               def("warning_fg_color", Colors.bg) +
               def("warning_color", Colors.yellow)
    }

    function apply() {
        if (!Colors.loaded || !root.active) return;
        var tmp = "/tmp/gtk4-theme.css.tmp"
        var script = 'mkdir -p "' + root.dir + '" && printf "%s" \'' + root.buildCss() + '\' > ' + tmp +
                     ' && mv ' + tmp + ' "' + root.cssPath + '"'
        proc.command = ["bash", "-c", script]
        proc.running = true
    }

    Connections {
        target: Colors
        function onActivePaletteChanged() { root.apply() }
    }

    onActiveChanged: root.apply()
}