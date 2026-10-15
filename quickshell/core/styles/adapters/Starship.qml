pragma Singleton
import QtQuick
import Quickshell.Io
import ".."
import "../../../services"
import "../../state"

Item {
    id: root
    readonly property string base: "$HOME/.config/starship.base.toml"
    readonly property string out: "$HOME/.config/starship.toml"
    readonly property bool active: ShellState.templatesEnabled && ShellState.templateStarship
    Process { id: proc }

    function buildPalette() {
        function p(k, v) { return k + ' = "' + Colors.toHex(v) + '"\n' }
        return "\n[palettes.hermit]\n" +
               p("hm_bg", Colors.bg) + p("hm_fg", Colors.fg) + p("hm_muted", Colors.fgMuted) +
               p("hm_accent", Colors.accent) + p("hm_red", Colors.red) + p("hm_green", Colors.green) +
               p("hm_yellow", Colors.yellow) + p("hm_blue", Colors.blue) +
               p("hm_purple", Colors.purple) + p("hm_cyan", Colors.cyan)
    }

    function apply() {
        if (!Colors.loaded || !root.active) return;
        var tmp = "/tmp/starship-theme.tmp"
        proc.command = ["bash", "-c",
            '[ -f "' + root.base + '" ] && cat "' + root.base + '" > ' + tmp +
            ' && printf "%s" \'' + root.buildPalette() + '\' >> ' + tmp +
            ' && mv ' + tmp + ' "' + root.out + '"']
        proc.running = true
    }

    Connections { target: Colors; function onActivePaletteChanged() { root.apply() } }
    onActiveChanged: root.apply()
}