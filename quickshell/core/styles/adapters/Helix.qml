pragma Singleton
import QtQuick
import Quickshell.Io
import ".."
import "../../state"

Item {
    id: root
    readonly property string path: "$HOME/.config/helix/themes/hermit.toml"
    readonly property bool active: ShellState.templatesEnabled && ShellState.templateHelix
    Process { id: proc }

    function buildToml() {
        function p(k, v) { return k + ' = "' + Colors.toHex(v) + '"\n' }
        return '"ui.background" = { bg = "bg" }\n' +
               '"ui.text" = "fg"\n' +
               '"ui.cursor" = { fg = "bg", bg = "accent" }\n' +
               '"ui.selection" = { bg = "surface" }\n' +
               '"ui.linenr" = "muted"\n' +
               '"ui.linenr.selected" = "fg"\n' +
               '"ui.statusline" = { fg = "fg", bg = "surface" }\n' +
               '"ui.statusline.inactive" = { fg = "muted", bg = "surface" }\n' +
               '"ui.menu" = { fg = "fg", bg = "surface" }\n' +
               '"ui.menu.selected" = { fg = "bg", bg = "accent" }\n' +
               '"ui.popup" = { bg = "surface" }\n' +
               '"ui.window" = "border"\n' +
               '"comment" = "muted"\n"keyword" = "purple"\n"string" = "green"\n"constant" = "yellow"\n' +
               '"function" = "blue"\n"type" = "yellow"\n"variable" = "fg"\n"operator" = "cyan"\n' +
               '"error" = "red"\n"warning" = "yellow"\n"info" = "blue"\n"hint" = "cyan"\n\n' +
               '[palette]\n' + p("bg", Colors.bg) + p("surface", Colors.bgsur) + p("fg", Colors.fg) +
               p("muted", Colors.fgMuted) + p("border", Colors.border) + p("accent", Colors.accent) +
               p("red", Colors.red) + p("green", Colors.green) + p("yellow", Colors.yellow) +
               p("blue", Colors.blue) + p("purple", Colors.purple) + p("cyan", Colors.cyan)
    }

    function apply() {
        if (!Colors.loaded || !root.active) return;
        proc.command = ["bash", "-c",
            'mkdir -p "$HOME/.config/helix/themes" && printf "%s" \'' + root.buildToml() + '\' > /tmp/helix-theme.tmp && mv /tmp/helix-theme.tmp "' + root.path + '"; pkill -USR1 hx || true']
        proc.running = true
    }

    Connections { target: Colors; function onActivePaletteChanged() { root.apply() } }
    onActiveChanged: root.apply()
}