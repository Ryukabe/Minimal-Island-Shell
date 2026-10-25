pragma Singleton
import QtQuick
import Quickshell.Io
import ".."
import "../../shell"

Item {
    id: root

    readonly property bool active: ShellState.templatesEnabled && ShellState.templateBtop

    // Kitty runs at background_opacity 0.75. A solid main_bg paints an opaque slab
    // over that, so by default btop lets the terminal background show through.
    // Set to false to paint Colors.bg instead.
    readonly property bool transparentBg: true

    // If the palette changes mid-apply, run once more when the current run ends.
    property bool pending: false

    Process {
        id: proc
        onRunningChanged: {
            if (!running && root.pending) {
                root.pending = false
                root.apply()
            }
        }
    }

    function buildTheme() {
        function t(k, v) { return 'theme[' + k + ']="' + Colors.toHex(v) + '"\n' }
        function g(name, a, b, c) { return t(name + "_start", a) + t(name + "_mid", b) + t(name + "_end", c) }

        var bg = root.transparentBg ? 'theme[main_bg]=""\n' : t("main_bg", Colors.bg)

        return bg + t("main_fg", Colors.fg) + t("title", Colors.fg) +
               t("hi_fg", Colors.accent) + t("selected_bg", Colors.bgSurface) + t("selected_fg", Colors.accent) +
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
               g("upload", Colors.green, Colors.yellow, Colors.red) +
               g("process", Colors.green, Colors.yellow, Colors.red)
    }

    function apply() {
        if (!Colors.loaded || !root.active) return
        if (proc.running) { root.pending = true; return }

        var script =
            'dir="$HOME/.config/btop/themes"\n' +
            'f="$dir/hermit.theme"\n' +
            'mkdir -p "$dir"\n' +
            // write atomically so btop never reads a half-written theme
            'cat > "$f.tmp" <<\'BTOP_EOF\'\n' +
            buildTheme() +
            'BTOP_EOF\n' +
            'mv "$f.tmp" "$f"\n' +
            // make sure btop actually uses the theme (no-op if already set)
            'conf="$HOME/.config/btop/btop.conf"\n' +
            'if [ -f "$conf" ] && ! grep -q \'^color_theme *= *"hermit"\' "$conf"; then\n' +
            '  sed -i \'s|^color_theme *=.*|color_theme = "hermit"|\' "$conf"\n' +
            'fi\n' +
            // SIGUSR2 = reload config + theme in a running btop
            'pkill -USR2 -x btop || true\n'

        proc.command = ["sh", "-c", script]
        proc.running = true
    }

    Connections {
        target: Colors
        function onActivePaletteChanged() { root.apply() }
        function onLoadedChanged() { root.apply() }
    }

    onActiveChanged: root.apply()
    Component.onCompleted: root.apply()
}
