pragma Singleton
import QtQuick
import Quickshell.Io
import ".."
import "../../shell"

Item {
    id: root

    readonly property bool active: ShellState.templatesEnabled && ShellState.templateKitty

    // If the palette changes while a previous apply is still running,
    // remember it and run once more when that one finishes.
    property bool pending: false

    Process {
        id: kittyProc
        onRunningChanged: {
            if (!running && root.pending) {
                root.pending = false
                root.apply()
            }
        }
    }

    function hex(c) { return Colors.toHex(c) }

    // Contents of ~/.config/kitty/colors/colors.conf
    function buildConf() {
        var lines = [
            "background "              + hex(Colors.bg),
            "foreground "              + hex(Colors.fg),
            "cursor "                  + hex(Colors.accent),
            "cursor_text_color "       + hex(Colors.bg),
            "selection_background "    + hex(Colors.accent),
            "selection_foreground "    + hex(Colors.bg),
            "url_color "               + hex(Colors.accent),

            "active_border_color "     + hex(Colors.accent),
            "inactive_border_color "   + hex(Colors.border),
            "bell_border_color "       + hex(Colors.yellow),

            "tab_bar_background "      + hex(Colors.bg),
            "active_tab_foreground "   + hex(Colors.bg),
            "active_tab_background "   + hex(Colors.accent),
            "inactive_tab_foreground " + hex(Colors.fgMuted),
            "inactive_tab_background " + hex(Colors.bgSurface),

            "color0 "  + hex(Colors.black),
            "color1 "  + hex(Colors.red),
            "color2 "  + hex(Colors.green),
            "color3 "  + hex(Colors.yellow),
            "color4 "  + hex(Colors.blue),
            "color5 "  + hex(Colors.purple),
            "color6 "  + hex(Colors.cyan),
            "color7 "  + hex(Colors.fgMuted),
            "color8 "  + hex(Colors.brightBlack),
            "color9 "  + hex(Colors.brightRed),
            "color10 " + hex(Colors.brightGreen),
            "color11 " + hex(Colors.brightYellow),
            "color12 " + hex(Colors.brightBlue),
            "color13 " + hex(Colors.brightPurple),
            "color14 " + hex(Colors.brightCyan),
            "color15 " + hex(Colors.brightWhite)
        ]
        return lines.join("\n") + "\n"
    }

    function apply() {
        if (!Colors.loaded || !root.active) return
        if (kittyProc.running) { root.pending = true; return }

        var script =
            'dir="$HOME/.config/kitty/colors"\n' +
            'f="$dir/colors.conf"\n' +
            'mkdir -p "$dir"\n' +
            // 1) persist: new kitty windows read this via `include colors/colors.conf`
            'cat > "$f.tmp" <<\'KITTY_COLORS_EOF\'\n' +
            buildConf() +
            'KITTY_COLORS_EOF\n' +
            'mv "$f.tmp" "$f"\n' +
            // 2) live: recolor every running kitty instance (one socket per instance)
            'for s in /tmp/kitty-theme-socket*; do\n' +
            '  [ -S "$s" ] && kitty @ --to "unix:$s" set-colors -a -c "$f" >/dev/null 2>&1 &\n' +
            'done\n' +
            'wait\n'

        kittyProc.command = ["sh", "-c", script]
        kittyProc.running = true
    }

    Connections {
        target: Colors
        function onActivePaletteChanged() { root.apply() }
        function onLoadedChanged() { root.apply() }
    }

    onActiveChanged: root.apply()
    Component.onCompleted: root.apply()
}
