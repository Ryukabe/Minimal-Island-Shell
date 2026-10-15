pragma Singleton
import QtQuick
import Quickshell.Io
import ".."
import "../../../services"
import "../../state"

Item {
    id: root
    readonly property string path: "$HOME/.config/btop/themes/hermit.theme"
    readonly property bool active: ShellState.templatesEnabled && ShellState.templateBtop
    Process { id: proc }

    function buildTheme() {
        function t(k, v) { return 'theme[' + k + ']="' + Colors.toHex(v) + '"\n' }
        function g(name, a, b, c) { return t(name + "_start", a) + t(name + "_mid", b) + t(name + "_end", c) }
        return t("main_bg", Colors.bg) + t("main_fg", Colors.fg) + t("title", Colors.fg) +
               t("hi_fg", Colors.accent) + t("selected_bg", Colors.bgsur) + t("selected_fg", Colors.accent) +
               t("inactive_fg", Colors.fgMuted) + t("graph_text", Colors.fgMuted) + t("meter_bg", Colors.border) +
               t("proc_misc", Colors.accent) + t("div_line", Colors.border) +
               t("cpu_box", Colors.border) + t("mem_box", Colors.border) + t("net_box", Colors.border) + t("proc_box", Colors.border) +
               g("temp", Colors.green, Colors.yellow, Colors.red) +
               g("cpu", Colors.green, Colors.yellow, Colors.red) +
               g("free", Colors.red, Colors.yellow, Colors.green) +
               g("cached", Colors.blue, Colors.cyan, Colors.cyan) +
               g("available", Colors.yellow, Colors.green, Colors.green) +
               g("used", Colors.green, Colors.yellow, Colors.red) +
               g("download", Colors.blue, Colors.purple, Colors.purple) +
               g("upload", Colors.green, Colors.yellow, Colors.red)
    }

    function apply() {
        if (!Colors.loaded || !root.active) return;
        proc.command = ["bash", "-c",
            'mkdir -p "$HOME/.config/btop/themes" && printf "%s" \'' + root.buildTheme() + '\' > /tmp/btop-theme.tmp && mv /tmp/btop-theme.tmp "' + root.path + '"; pkill -USR2 btop || true']
        proc.running = true
    }

    Connections { target: Colors; function onActivePaletteChanged() { root.apply() } }
    onActiveChanged: root.apply()
}