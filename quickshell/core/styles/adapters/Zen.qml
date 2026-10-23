pragma Singleton
import QtQuick
import Quickshell.Io
import ".."
import "../../shell"

// Zen is Firefox-based and has no supported way to recolor a running window from outside.
// This writes the colors to ~/.cache/hermit/zen-userChrome.css and makes sure every Zen
// profile's chrome/userChrome.css imports it. New colors show up the next time Zen starts.
Item {
    id: root

    readonly property bool active: ShellState.templatesEnabled && ShellState.templateZen

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

    function buildCss() {
        var h = Colors.toHex
        var vars = [
            // Zen's own variables (starting set, refine in the Browser Toolbox if something is off)
            "--zen-primary-color: "     + h(Colors.accent),
            "--zen-colors-primary: "    + h(Colors.bgSurface),
            "--zen-colors-secondary: "  + h(Colors.bg),
            "--zen-colors-tertiary: "   + h(Colors.bg),
            "--zen-colors-border: "     + h(Colors.border),
            "--zen-colors-hover: "      + h(Colors.surface),
            // generic Firefox chrome variables
            "--toolbar-bgcolor: "       + h(Colors.bgSurface),
            "--toolbar-color: "         + h(Colors.fg),
            "--toolbar-field-background-color: " + h(Colors.bg),
            "--toolbar-field-color: "   + h(Colors.fg),
            "--lwt-text-color: "        + h(Colors.fg),
            "--lwt-accent-color: "      + h(Colors.bg)
        ]
        return ":root {\n  " + vars.join(" !important;\n  ") + " !important;\n}\n"
    }

    function apply() {
        if (!Colors.loaded || !root.active) return
        if (proc.running) { root.pending = true; return }

        var script =
            'css="$HOME/.cache/hermit/zen-userChrome.css"\n' +
            'mkdir -p "$(dirname "$css")"\n' +
            'cat > "$css.tmp" <<\'ZEN_EOF\'\n' +
            buildCss() +
            'ZEN_EOF\n' +
            'mv "$css.tmp" "$css"\n' +
            // hook the file into every Zen profile we can find (native, config-dir and flatpak layouts)
            'for d in "$HOME"/.zen/*/ "$HOME"/.config/zen/*/ "$HOME"/.var/app/app.zen_browser.zen/.zen/*/; do\n' +
            '  [ -f "$d/prefs.js" ] || continue\n' +
            '  mkdir -p "$d/chrome"\n' +
            '  uc="$d/chrome/userChrome.css"\n' +
            '  if ! grep -qs "hermit/zen-userChrome.css" "$uc"; then\n' +
            '    printf \'/* hermit-shell */\\n@import "%s";\\n\' "$css" >> "$uc"\n' +
            '  fi\n' +
            // Zen only loads userChrome.css if this pref is on
            '  if ! grep -qs "legacyUserProfileCustomizations.stylesheets" "$d/user.js"; then\n' +
            '    printf \'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);\\n\' >> "$d/user.js"\n' +
            '  fi\n' +
            'done\n'

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
