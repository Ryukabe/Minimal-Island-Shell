// styles/adapters/Gtk.qml
pragma Singleton

import QtQuick
import Quickshell.Io
import ".."

Item {
    id: root

    readonly property string gtk3CssPath: "$HOME/.config/gtk-3.0/gtk.css"
    readonly property string gtk4CssPath: "$HOME/.config/gtk-4.0/gtk.css"

    // Prevent the initial Colors load from immediately killing Nautilus.
    // A real theme/palette change after startup will restart it.
    property bool _startupReady: false
    property string _lastGtk3Css: ""
    property string _lastGtk4Css: ""

    Component.onCompleted: {
        Qt.callLater(function() {
            root._startupReady = true
        })
    }

    Process {
        id: gtk3Proc

        stderr: SplitParser {
            onRead: data => {
                if (data.trim().length > 0)
                    console.log("[Gtk] gtk3 write stderr:", data.trim())
            }
        }
    }

    Process {
        id: gtk4Proc

        stderr: SplitParser {
            onRead: data => {
                if (data.trim().length > 0)
                    console.log("[Gtk] gtk4 write stderr:", data.trim())
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                return

            // Once the GTK4 stylesheet is safely written, restart Nautilus
            // so it reloads the new libadwaita/GTK4 colors.
            if (root._startupReady)
                root.restartNautilus()
        }
    }

    Process {
        id: restartNautilusProc

        stderr: SplitParser {
            onRead: data => {
                if (data.trim().length > 0)
                    console.log("[Gtk] Nautilus restart stderr:", data.trim())
            }
        }
    }

    // GTK3 / legacy-Adwaita symbolic names.
    //
    // The old version only defined symbolic colors. That does not force
    // every GTK3 application/theme to actually use them. The explicit
    // selectors below make the common GTK3/Adwaita surfaces follow the
    // current Quickshell palette as well.
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
               "@define-color wm_unfocused_bg " + Colors.toHex(Colors.bg) + ";\n" +

               "/* Main GTK3 surfaces */\n" +
               "window,\n" +
               ".background,\n" +
               window.background,\n" +
               "scrolledwindow,\n" +
               "viewport {\n" +
               "  background-color: @theme_bg_color;\n" +
               "  color: @theme_fg_color;\n" +
               "}\n" +

               "/* Content areas */\n" +
               ".view,\n" +
               "textview,\n" +
               "treeview,\n" +
               "iconview,\n" +
               "flowbox,\n" +
               "list,\n" +
               "entry {\n" +
               "  background-color: @theme_base_color;\n" +
               "  color: @theme_text_color;\n" +
               "}\n" +

               "/* Header bars / title bars */\n" +
               "headerbar,\n" +
               ".titlebar {\n" +
               "  background-color: @wm_bg;\n" +
               "  color: @theme_fg_color;\n" +
               "}\n" +

               "/* Buttons and common controls */\n" +
               "button,\n" +
               "combobox,\n" +
               "spinbutton,\n" +
               "checkbutton,\n" +
               "radiobutton {\n" +
               "  color: @theme_fg_color;\n" +
               "}\n" +

               "/* GTK3 sidebars */\n" +
               ".sidebar,\n" +
               "placessidebar,\n" +
               "stacksidebar {\n" +
               "  background-color: @theme_bg_color;\n" +
               "  color: @theme_fg_color;\n" +
               "}\n" +

               "/* Sidebar rows stay readable but retain the darker panel */\n" +
               ".sidebar row,\n" +
               "placessidebar row,\n" +
               "stacksidebar row {\n" +
               "  background-color: transparent;\n" +
               "  color: @theme_fg_color;\n" +
               "}\n" +

               "/* Selected rows */\n" +
               ".sidebar row:selected,\n" +
               "placessidebar row:selected,\n" +
               "stacksidebar row:selected,\n" +
               "treeview.view:selected,\n" +
               "iconview:selected {\n" +
               "  background-color: @theme_selected_bg_color;\n" +
               "  color: @theme_selected_fg_color;\n" +
               "}\n" +

               "/* Separators / borders */\n" +
               "separator,\n" +
               ".separator {\n" +
               "  background-color: @borders;\n" +
               "}\n"
    }

    // GTK4 / libadwaita named-color scheme plus explicit widget selectors.
    //
    // sidebarBg is deliberately darker than the main surface so Nautilus
    // and other GTK4/libadwaita apps do not become one flat block of color.
    function buildGtk4Css() {
        var sidebarBg = Qt.darker(Colors.bgsur, 1.18)
        var sidebarHover = Qt.lighter(sidebarBg, 1.08)

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
               "@define-color sidebar_bg_color " + Colors.toHex(sidebarBg) + ";\n" +
               "@define-color sidebar_fg_color " + Colors.toHex(Colors.fg) + ";\n" +
               "@define-color sidebar_backdrop_color " + Colors.toHex(Colors.bg) + ";\n" +

               "/* Main GTK4/libadwaita surfaces */\n" +
               "window,\n" +
               "window.background,\n" +
               ".background,\n" +
               "viewport,\n" +
               "scrolledwindow {\n" +
               "  background-color: @window_bg_color;\n" +
               "  color: @window_fg_color;\n" +
               "}\n" +

               "/* Content/view areas */\n" +
               "view,\n" +
               ".view,\n" +
               "textview,\n" +
               "list,\n" +
               "gridview {\n" +
               "  background-color: @view_bg_color;\n" +
               "  color: @view_fg_color;\n" +
               "}\n" +

               "/* Header bars */\n" +
               "headerbar,\n" +
               ".titlebar {\n" +
               "  background-color: @headerbar_bg_color;\n" +
               "  color: @headerbar_fg_color;\n" +
               "}\n" +

               "/* Darker GTK4/libadwaita navigation sidebars */\n" +
               ".navigation-sidebar,\n" +
               ".navigation-sidebar > viewport,\n" +
               "navigation-sidebar,\n" +
               "placessidebar {\n" +
               "  background-color: @sidebar_bg_color;\n" +
               "  color: @sidebar_fg_color;\n" +
               "}\n" +

               "/* Nautilus and other libadwaita sidebar rows */\n" +
               ".navigation-sidebar row,\n" +
               "navigation-sidebar row,\n" +
               "placessidebar row {\n" +
               "  background-color: transparent;\n" +
               "  color: @sidebar_fg_color;\n" +
               "}\n" +

               ".navigation-sidebar row:hover,\n" +
               "navigation-sidebar row:hover,\n" +
               "placessidebar row:hover {\n" +
               "  background-color: " + Colors.toHex(sidebarHover) + ";\n" +
               "}\n" +

               ".navigation-sidebar row:selected,\n" +
               "navigation-sidebar row:selected,\n" +
               "placessidebar row:selected {\n" +
               "  background-color: " + Colors.toHex(Colors.accent) + ";\n" +
               "  color: " + Colors.toHex(Colors.bg) + ";\n" +
               "}\n" +

               "/* Common GTK4 controls */\n" +
               "button,\n" +
               "entry,\n" +
               "spinbutton,\n" +
               "dropdown,\n" +
               "combobox {\n" +
               "  color: @window_fg_color;\n" +
               "}\n"
    }

    function writeGtkThemes() {
        if (!Colors.loaded)
            return

        var gtk3Css = root.buildGtk3Css()
        var gtk4Css = root.buildGtk4Css()

        // Do not rewrite/restart anything when the generated CSS has not
        // actually changed.
        if (gtk3Css === root._lastGtk3Css &&
            gtk4Css === root._lastGtk4Css) {
            return
        }

        root._lastGtk3Css = gtk3Css
        root._lastGtk4Css = gtk4Css

        // GTK3
        gtk3Proc.running = false
        gtk3Proc.command = [
            "bash",
            "-c",
            "mkdir -p \"$HOME/.config/gtk-3.0\" && " +
            "printf '%s' " + JSON.stringify(gtk3Css) +
            " > /tmp/quickshell-gtk3.css.tmp && " +
            "mv /tmp/quickshell-gtk3.css.tmp " +
            JSON.stringify(root.gtk3CssPath)
        ]
        gtk3Proc.running = true

        // GTK4
        gtk4Proc.running = false
        gtk4Proc.command = [
            "bash",
            "-c",
            "mkdir -p \"$HOME/.config/gtk-4.0\" && " +
            "printf '%s' " + JSON.stringify(gtk4Css) +
            " > /tmp/quickshell-gtk4.css.tmp && " +
            "mv /tmp/quickshell-gtk4.css.tmp " +
            JSON.stringify(root.gtk4CssPath)
        ]
        gtk4Proc.running = true
    }

    function restartNautilus() {
        restartNautilusProc.running = false

        restartNautilusProc.command = [
            "bash",
            "-c",
            "pkill -x nautilus >/dev/null 2>&1 || true; " +
            "sleep 0.20; " +
            "nohup nautilus >/dev/null 2>&1 </dev/null &"
        ]

        restartNautilusProc.running = true

        console.log("[Gtk] Restarting Nautilus to load new GTK4 colors")
    }

    Connections {
        target: Colors

        function onActivePaletteChanged() {
            if (!Colors.loaded)
                return

            root.writeGtkThemes()
        }
    }
}
