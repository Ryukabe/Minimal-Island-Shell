pragma Singleton
import QtQuick
import Quickshell.Io
import ".."
import "../../state"

Item {
    id: root
    // Edit this to your vault's folder, e.g. "$HOME/Documents/MyVault"
    readonly property string vaultPath: ""
    readonly property bool active: ShellState.templatesEnabled && ShellState.templateObsidian && root.vaultPath !== ""
    Process { id: proc }

    function buildCss() {
        function v(k, c) { return "  --" + k + ": " + Colors.toHex(c) + ";\n" }
        return "body {\n" +
               v("background-primary", Colors.bg) + v("background-primary-alt", Colors.bgsur) +
               v("background-secondary", Colors.bgsur) + v("background-secondary-alt", Colors.bg) +
               v("background-modifier-border", Colors.border) +
               v("text-normal", Colors.fg) + v("text-muted", Colors.fgMuted) + v("text-faint", Colors.fgMuted) +
               v("text-accent", Colors.accent) + v("interactive-accent", Colors.accent) + v("text-on-accent", Colors.bg) +
               v("color-red", Colors.red) + v("color-green", Colors.green) + v("color-yellow", Colors.yellow) +
               v("color-blue", Colors.blue) + v("color-purple", Colors.purple) + v("color-cyan", Colors.cyan) +
               "}\n"
    }

    function apply() {
        if (!Colors.loaded || !root.active) return;
        var dir = root.vaultPath + "/.obsidian/snippets"
        proc.command = ["bash", "-c",
            'mkdir -p "' + dir + '" && printf "%s" \'' + root.buildCss() + '\' > /tmp/obsidian-theme.tmp && mv /tmp/obsidian-theme.tmp "' + dir + '/hermit.css"']
        proc.running = true
    }

    Connections { target: Colors; function onActivePaletteChanged() { root.apply() } }
    onActiveChanged: root.apply()
}