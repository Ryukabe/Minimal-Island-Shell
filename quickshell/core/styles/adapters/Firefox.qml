pragma Singleton
import QtQuick
import Quickshell.Io
import ".."
import "../../shell"

Item {
    id: root
    readonly property bool active: ShellState.templatesEnabled && ShellState.templateFirefox
    Process { id: proc }

    function buildCss() {
        function v(k, c) { return "  --hermit-" + k + ": " + Colors.toHex(c) + ";\n" }
        return ":root {\n" + v("bg", Colors.bg) + v("surface", Colors.bgsur) + v("fg", Colors.fg) +
               v("muted", Colors.fgMuted) + v("border", Colors.border) + v("accent", Colors.accent) + "}\n"
    }

    function apply() {
        if (!Colors.loaded || !root.active) return;
        proc.command = ["bash", "-c",
            'for d in "$HOME"/.mozilla/firefox/*.default*/; do mkdir -p "$d/chrome" && printf "%s" \'' + root.buildCss() + '\' > "$d/chrome/hermit-colors.css"; done']
        proc.running = true
    }

    Connections { target: Colors; function onActivePaletteChanged() { root.apply() } }
    onActiveChanged: root.apply()
}