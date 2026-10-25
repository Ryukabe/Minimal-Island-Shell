// styles/adapters/Gtk3.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import ".."
import "../../shell"

Item {
    id: root

    // hermit-thunar.css stays where it is; its contents are pasted into the theme.
    readonly property string srcDir: "$HOME/.config/gtk-3.0"
    readonly property var merges: ["hermit-thunar.css"]
    readonly property string themesDir: "$HOME/.themes"
    readonly property bool active: ShellState.templatesEnabled && ShellState.templateGtk3

    property bool _pending: false

    Process {
        id: proc
        stderr: SplitParser {
            onRead: data => console.log("[Gtk3] stderr:", data)
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                console.log("[Gtk3] apply failed, exit code:", exitCode)
            if (root._pending) {
                root._pending = false
                root.apply()
            }
        }
    }

    // Re-apply when you edit the Thunar file by hand.
    FileView {
        path: Quickshell.env("HOME") + "/.config/gtk-3.0/hermit-thunar.css"
        watchChanges: true
        onFileChanged: root.apply()
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
               "@define-color hm_select mix(@hm_surface, @hm_accent, 0.30);\n" +
               "@define-color hm_muted " + Colors.toHex(Colors.fgMuted) + ";\n" +
               "@define-color hm_border " + Colors.toHex(Colors.border) + ";\n" +
               "@define-color hm_red " + Colors.toHex(Colors.red) + ";\n" +
               "@define-color hm_green " + Colors.toHex(Colors.green) + ";\n" +
               "@define-color hm_yellow " + Colors.toHex(Colors.yellow) + ";\n"
    }

    function apply() {
        if (!Colors.loaded || !root.active) return;
        if (proc.running) { root._pending = true; return }

        var base = Colors.lightModeEnabled ? "adw-gtk3" : "adw-gtk3-dark"
        var sh = ""
        sh += "set -e; "
        // Pick the theme that is NOT currently active.
        sh += "cur=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d \"'\"); "
        sh += "if [ \"$cur\" = hermit-a ]; then n=b; else n=a; fi; "
        sh += "t=\"" + root.themesDir + "/hermit-$n\"; "
        sh += "mkdir -p \"$t/gtk-3.0\"; "
        sh += "printf '[Desktop Entry]\\nType=X-GNOME-Metatheme\\nName=hermit-%s\\n\\n[X-GNOME-Metatheme]\\nGtkTheme=hermit-%s\\n' \"$n\" \"$n\" > \"$t/index.theme\"; "
        // Theme gtk.css = adw-gtk3 base + shell colors + Thunar CSS.
        sh += "{ printf '@import url(\"file:///usr/share/themes/" + base + "/gtk-3.0/gtk.css\");\\n'; "
        sh += "printf '%s' '" + root.buildCss() + "'; "
        for (var i = 0; i < root.merges.length; i++) {
            var f = root.srcDir + "/" + root.merges[i]
            sh += "[ -f \"" + f + "\" ] && cat \"" + f + "\"; true; "
        }
        sh += "} > \"$t/gtk-3.0/gtk.css.tmp\"; "
        sh += "mv \"$t/gtk-3.0/gtk.css.tmp\" \"$t/gtk-3.0/gtk.css\"; "
        // The old generated user gtk.css would override the theme, so remove it.
        sh += "u=\"" + root.srcDir + "/gtk.css\"; "
        sh += "if [ -f \"$u\" ] && grep -q hm_bg \"$u\"; then rm -f \"$u\"; fi; "
        // Switch: running GTK3 apps reload the theme live.
        sh += "gsettings set org.gnome.desktop.interface gtk-theme \"hermit-$n\""

        proc.command = ["bash", "-c", sh]
        proc.running = true
    }

    Connections {
        target: Colors
        function onActivePaletteChanged() { root.apply() }
    }

    onActiveChanged: root.apply()
}