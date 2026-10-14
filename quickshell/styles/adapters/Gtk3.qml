// styles/adapters/Gtk3.qml
pragma Singleton
import QtQuick
import Quickshell.Io
import ".."
import "../../services"

Item {
    id: root

    readonly property string dir: "$HOME/.config/gtk-3.0"
    readonly property string cssPath: root.dir + "/gtk.css"
    // Extra CSS files (living next to gtk.css) that get re-imported after every write.
    readonly property var imports: ["hermit-thunar.css"]
    readonly property bool active: ShellState.templatesEnabled && ShellState.templateGtk3

    Process {
        id: proc
        stderr: SplitParser {
            onRead: data => console.log("[Gtk3] write stderr:", data)
        }
    }

    function buildCss() {
        return "@define-color theme_bg_color " + Colors.toHex(Colors.bg) + ";\n" +
               "@define-color theme_fg_color " + Colors.toHex(Colors.fg) + ";\n" +
               "@define-color theme_base_color " + Colors.toHex(Colors.bgsur) + ";\n" +
               "@define-color theme_text_color " + Colors.toHex(Colors.fg) + ";\n" +
               "@define-color theme_selected_bg_color " + Colors.toHex(Colors.accent) + ";\n" +
               "@define-color theme_selected_fg_color " + Colors.toHex(Colors.bg) + ";\n" +
               "@define-color theme_unfocused_bg_color " + Colors.toHex(Colors.bg) + ";\n" +
               "@define-color theme_unfocused_fg_color " + Colors.toHex(Colors.fgMuted) + ";\n" +
               "@define-color theme_tooltip_bg_color " + Colors.toHex(Colors.bgsur) + ";\n" +
               "@define-color theme_tooltip_fg_color " + Colors.toHex(Colors.fg) + ";\n" +
               "@define-color content_view_bg " + Colors.toHex(Colors.bgsur) + ";\n" +
               "@define-color insensitive_bg_color " + Colors.toHex(Colors.bg) + ";\n" +
               "@define-color insensitive_fg_color " + Colors.toHex(Colors.fgMuted) + ";\n" +
               "@define-color borders " + Colors.toHex(Colors.border) + ";\n" +
               "@define-color unfocused_borders " + Colors.toHex(Colors.border) + ";\n" +
               "@define-color wm_bg " + Colors.toHex(Colors.bgsur) + ";\n" +
               "@define-color wm_unfocused_bg " + Colors.toHex(Colors.bg) + ";\n" +
               "@define-color hm_bg " + Colors.toHex(Colors.bg) + ";\n" +
               "@define-color hm_fg " + Colors.toHex(Colors.fg) + ";\n" +
               "@define-color hm_surface " + Colors.toHex(Colors.bgsur) + ";\n" +
               "@define-color hm_accent " + Colors.toHex(Colors.accent) + ";\n" +
               "@define-color hm_accent_light " + Colors.toHex(Qt.lighter(Colors.accent, 1.2)) + ";\n" +
               "@define-color hm_select mix(@hm_surface, @hm_accent, 0.30);\n"
    }

    function apply() {
        if (!Colors.loaded || !root.active) return;
        var tmp = "/tmp/gtk3-theme.css.tmp"
        var script = 'mkdir -p "' + root.dir + '" && printf "%s" \'' + root.buildCss() + '\' > ' + tmp
        for (var i = 0; i < root.imports.length; i++) {
            var f = root.imports[i]
            script += ' && { [ -f "' + root.dir + '/' + f + '" ] && printf "@import \\"' + f + '\\";\\n" >> ' + tmp + '; true; }'
        }
        script += ' && mv ' + tmp + ' "' + root.cssPath + '"'
        proc.command = ["bash", "-c", script]
        proc.running = true
    }

    Connections {
        target: Colors
        function onActivePaletteChanged() { root.apply() }
    }

    onActiveChanged: root.apply()
}