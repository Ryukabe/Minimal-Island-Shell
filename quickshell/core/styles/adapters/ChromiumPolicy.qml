import QtQuick
import Quickshell.Io
import ".."
import "../../shell"

// Not a singleton: Chrome.qml / Brave.qml / Helium.qml each instantiate one of these.
//
// How it works: Chromium-family browsers read "managed policies" from JSON files in a
// system directory. We write BrowserThemeColor (+ BrowserColorScheme) into our own file
// there, then ask the running browser to re-read policies with --refresh-platform-policy.
// The target file must be created once, owned by you (see one-time setup), because the
// directory itself stays root-owned and we can only overwrite the file in place.
Item {
    id: root

    property bool active: false
    property string label: "browser"
    property string policyDir: ""
    property var binaries: []     // candidate executables, first one found on PATH is used
    property var procNames: []    // process names (pgrep -x) that mean "browser is running"

    property bool pending: false

    Process {
        id: proc
        onRunningChanged: {
            if (!running && root.pending) {
                root.pending = false
                root.apply()
            }
        }
        onExited: (code, status) => {
            if (code === 3)
                console.warn("[" + root.label + "] " + root.policyDir + "/hermit-color.json is missing or not writable; run the one-time setup")
        }
    }

    function hexOf(c) { return Colors.toHex(c).substring(0, 7) }

    function isDark() {
        var h = hexOf(Colors.bg)
        var r = parseInt(h.substring(1, 3), 16) / 255
        var g = parseInt(h.substring(3, 5), 16) / 255
        var b = parseInt(h.substring(5, 7), 16) / 255
        return (0.2126 * r + 0.7152 * g + 0.0722 * b) < 0.5
    }

    function apply() {
        if (!Colors.loaded || !root.active) return
        if (proc.running) { root.pending = true; return }

        var json = JSON.stringify({
            BrowserThemeColor: hexOf(Colors.bg),
            BrowserColorScheme: isDark() ? "dark" : "light"
        }, null, 2) + "\n"

        var script =
            'f="' + root.policyDir + '/hermit-color.json"\n' +
            'if [ ! -w "$f" ]; then exit 3; fi\n' +
            // overwrite in place (no rename): the directory is root-owned
            'cat > "$f" <<\'POLICY_EOF\'\n' +
            json +
            'POLICY_EOF\n' +
            'bin=""\n' +
            'for b in ' + root.binaries.join(" ") + '; do\n' +
            '  if command -v "$b" >/dev/null 2>&1; then bin="$b"; break; fi\n' +
            'done\n' +
            'running=0\n' +
            'for n in ' + root.procNames.join(" ") + '; do\n' +
            '  if pgrep -x "$n" >/dev/null 2>&1; then running=1; fi\n' +
            'done\n' +
            // only poke the browser if it is already running, so we never launch one
            'if [ -n "$bin" ] && [ "$running" = 1 ]; then\n' +
            '  timeout 5 "$bin" --refresh-platform-policy --no-startup-window >/dev/null 2>&1 || true\n' +
            'fi\n'

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
