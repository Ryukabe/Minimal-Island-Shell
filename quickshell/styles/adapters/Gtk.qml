// styles/adapters/Gtk.qml
pragma Singleton
import QtQuick
import Quickshell.Io
import ".."
import "../../services"

Item {
    id: root

    readonly property string gtk3CssPath: "$HOME/.config/gtk-3.0/gtk.css"
    readonly property string gtk4CssPath: "$HOME/.config/gtk-4.0/gtk.css"
    readonly property bool gtk3Active: ShellState.templatesEnabled && ShellState.templateGtk3
    readonly property bool gtk4Active: ShellState.templatesEnabled && ShellState.templateGtk4

    Process {
        id: gtk3Proc
        stderr: SplitParser {
            onRead: data => console.log("[Gtk] gtk3 write stderr:", data)
        }
    }
    Process {
        id: gtk4Proc
        stderr: SplitParser {
            onRead: data => console.log("[Gtk] gtk4 write stderr:", data)
        }
    }

    function buildGtk3Css() {
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
               "@define-color wm_unfocused_bg " + Colors.toHex(Colors.bg) + ";\n"
    }

    function buildGtk4Css() {
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
        if (!Colors.loaded) return;

        if (root.gtk3Active) {
            gtk3Proc.command = ["bash", "-c",
                'mkdir -p "$HOME/.config/gtk-3.0" && printf "%s" \'' + root.buildGtk3Css() + '\' > /tmp/gtk3-theme.css.tmp && mv /tmp/gtk3-theme.css.tmp "' + root.gtk3CssPath + '"']
            gtk3Proc.running = true
        }

        if (root.gtk4Active) {
            gtk4Proc.command = ["bash", "-c",
                'mkdir -p "$HOME/.config/gtk-4.0" && printf "%s" \'' + root.buildGtk4Css() + '\' > /tmp/gtk4-theme.css.tmp && mv /tmp/gtk4-theme.css.tmp "' + root.gtk4CssPath + '"']
            gtk4Proc.running = true
        }
    }

    Connections {
        target: Colors
        function onActivePaletteChanged() { root.apply() }
    }

    onGtk3ActiveChanged: if (gtk3Active) root.apply()
    onGtk4ActiveChanged: if (gtk4Active) root.apply()
}
