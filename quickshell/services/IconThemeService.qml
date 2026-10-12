// services/IconThemeService.qml — installed icon themes + a live name -> file lookup.
// Quickshell.iconPath can't switch theme at runtime, so for a chosen theme this scans the
// theme folder once and answers resolve() itself. Anything it can't find falls back to the
// Qt platform theme.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Folder names of installed icon themes.
    property var themes: []
    // icon name -> absolute file path, for the theme selected in ShellState.appIconTheme.
    property var iconMap: ({})
    property bool loading: false

    readonly property string theme: ShellState.appIconTheme

    // Picker entries: "System default" first, then every installed theme.
    readonly property var pickerItems: [{ value: "", label: "System default" }]
        .concat(themes.map(t => ({ value: t, label: t })))

    // Theme dirs: user folders first (they override /usr/share/icons).
    // Prints the theme name first so stale output from a killed scan can be recognised.
    readonly property string scanScript: [
        'echo "$1"',
        'for b in "$HOME/.local/share/icons" "$HOME/.icons" /usr/share/icons; do',
        '  if [ -d "$b/$1" ]; then',
        '    find -L "$b/$1" -type f -path "*/apps/*" \\( -name "*.svg" -o -name "*.png" \\)',
        '    break',
        '  fi',
        'done'
    ].join("\n")

    // Only folders whose index.theme declares icon Directories (skips cursor-only themes).
    readonly property string themesScript: [
        'for d in /usr/share/icons/* "$HOME/.local/share/icons"/* "$HOME/.icons"/*; do',
        '  [ -f "$d/index.theme" ] && grep -q "^Directories=" "$d/index.theme" && basename "$d"',
        'done | sort -u'
    ].join("\n")

    onThemeChanged: root.reload()

    Component.onCompleted: {
        refreshThemes()
        reload()
    }

    function refreshThemes() {
        themesProc.running = false
        themesProc.command = ["sh", "-c", themesScript]
        themesProc.running = true
    }

    function reload() {
        scan.running = false
        if (theme === "") {
            iconMap = ({})
            loading = false
            return
        }
        loading = true
        scan.command = ["sh", "-c", scanScript, "sh", theme]
        scan.running = true
    }

    // Prefer SVG, then the largest size folder ("scalable" counts as biggest).
    function _parse(text) {
        var lines = text.split("\n")
        if (lines.length === 0 || lines[0] !== root.theme) return

        var best = {}
        for (var i = 1; i < lines.length; i++) {
            var p = lines[i]
            if (p === "") continue
            var file = p.substring(p.lastIndexOf("/") + 1)
            var dot = file.lastIndexOf(".")
            if (dot <= 0) continue
            var name = file.substring(0, dot)
            var m = p.match(/\/(\d+)(?:x\d+)?\//)
            var size = p.indexOf("/scalable/") >= 0 ? 512 : (m ? parseInt(m[1]) : 0)
            var score = (file.endsWith(".svg") ? 100000 : 0) + size
            if (!best[name] || best[name].score < score) best[name] = { score: score, path: p }
        }

        var map = {}
        for (var k in best) map[k] = best[k].path
        iconMap = map
        loading = false
    }

    // Returns an Image.source for an app icon name, or "" if nothing is found.
    function resolve(name) {
        if (!name) return ""
        if (name.startsWith("/")) return "file://" + encodeURI(name)
        var p = iconMap[name] || iconMap[name.toLowerCase()]
        if (p) return "file://" + encodeURI(p)
        return Quickshell.iconPath(name, true)
    }

    Process {
        id: scan
        stdout: StdioCollector {
            onStreamFinished: root._parse(text)
        }
    }

    Process {
        id: themesProc
        stdout: StdioCollector {
            onStreamFinished: root.themes = text.split("\n").filter(s => s !== "")
        }
    }
}