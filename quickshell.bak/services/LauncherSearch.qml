// services/LauncherSearch.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Turns the launcher's query into a list of rows. Every non-app row is a plain
// object: { kind, id, name, comment, glyph, ... } where kind is:
//   "copy"  -> copies `value` to the clipboard
//   "exec"  -> runs `argv` detached (optionally asks for a second Enter: `confirm`)
//   "info"  -> hint row, does nothing
// App rows are Quickshell DesktopEntry objects (they have no `kind`).
Singleton {
    id: root

    // ---- async provider state ----
    property var fileResults: []
    property bool filesLoading: false
    property var snippetResults: []
    property bool snippetsLoading: false

    property string armedId: ""

    property string _lastMode: "apps"
    property string _fileArg: ""

    readonly property string _fileScript:
        "if command -v fd >/dev/null 2>&1; then fd --max-results 40 -- \"$1\" \"$HOME\"; " +
        "else find \"$HOME\" -maxdepth 6 -iname \"*$1*\" 2>/dev/null | head -n 40; fi"

    // Notes: append a timestamped line ("running" and "daily" modes), or
    // create a brand-new file with the note as its body ("capture" mode).
    readonly property string _noteAppendScript:
        "mkdir -p \"$(dirname \"$2\")\" && " +
        "printf '- %s %s\\n' \"$(date '+%Y-%m-%d %H:%M')\" \"$1\" >> \"$2\""

    readonly property string _noteCreateScript:
        "mkdir -p \"$(dirname \"$2\")\" && " +
        "printf '%s\\n\\n%s\\n' \"$(date '+%Y-%m-%d %H:%M')\" \"$1\" > \"$2\""

    // Snippets: two levels deep under the snippets folder (category/name.ext).
    // \x1e separates entries, \x1f separates a file's path from its content.
    readonly property string _snippetsScript:
        "find \"$1\" -mindepth 2 -maxdepth 2 -type f 2>/dev/null | while IFS= read -r f; do " +
        "printf '\\x1e%s\\x1f' \"$f\"; cat \"$f\"; done"

    readonly property var systemCommands: [
        { id: "lock",      name: "Lock",      keywords: ["lock"],                                   glyph: "lock",       argv: ["loginctl", "lock-session"],   confirm: false },
        { id: "sleep",     name: "Sleep",     keywords: ["sleep", "suspend"],                       glyph: "bedtime",    argv: ["systemctl", "suspend"],       confirm: false },
        { id: "hibernate", name: "Hibernate", keywords: ["hibernate"],                              glyph: "downloading", argv: ["systemctl", "hibernate"],    confirm: true  },
        { id: "logout",    name: "Log out",   keywords: ["logout", "log out"],                      glyph: "logout",     argv: ["hyprctl", "dispatch", "exit"], confirm: true  },
        { id: "restart",   name: "Restart",   keywords: ["restart", "reboot"],                      glyph: "restart_alt", argv: ["systemctl", "reboot"],       confirm: true  },
        { id: "shutdown",  name: "Shut down", keywords: ["shutdown", "shut down", "power off", "poweroff"], glyph: "power_settings_new", argv: ["systemctl", "poweroff"], confirm: true }
    ]

    readonly property var _units: ({
        mm: ["len", 0.001], cm: ["len", 0.01], m: ["len", 1], km: ["len", 1000],
        "in": ["len", 0.0254], ft: ["len", 0.3048], yd: ["len", 0.9144], mi: ["len", 1609.344],
        mg: ["mass", 1e-6], g: ["mass", 0.001], kg: ["mass", 1], t: ["mass", 1000],
        oz: ["mass", 0.028349523125], lb: ["mass", 0.45359237],
        ml: ["vol", 0.001], l: ["vol", 1], tsp: ["vol", 0.00492892159375], tbsp: ["vol", 0.01478676478125],
        floz: ["vol", 0.0295735295625], cup: ["vol", 0.2365882365], pt: ["vol", 0.473176473],
        qt: ["vol", 0.946352946], gal: ["vol", 3.785411784],
        ms: ["time", 0.001], s: ["time", 1], min: ["time", 60], h: ["time", 3600], d: ["time", 86400], wk: ["time", 604800],
        b: ["data", 1], kb: ["data", 1e3], mb: ["data", 1e6], gb: ["data", 1e9], tb: ["data", 1e12],
        kib: ["data", 1024], mib: ["data", 1048576], gib: ["data", 1073741824], tib: ["data", 1099511627776],
        "m/s": ["speed", 1], "km/h": ["speed", 0.2777777778], mph: ["speed", 0.44704], kn: ["speed", 0.5144444444],
        c: ["temp", 0], f: ["temp", 0], k: ["temp", 0]
    })

    readonly property var _unitAlias: ({
        meter: "m", meters: "m", metre: "m", metres: "m",
        kilometer: "km", kilometers: "km", kilometre: "km", kilometres: "km",
        centimeter: "cm", centimeters: "cm", millimeter: "mm", millimeters: "mm",
        inch: "in", inches: "in", foot: "ft", feet: "ft", yard: "yd", yards: "yd", mile: "mi", miles: "mi",
        kilogram: "kg", kilograms: "kg", kgs: "kg", gram: "g", grams: "g", milligram: "mg", milligrams: "mg",
        pound: "lb", pounds: "lb", lbs: "lb", ounce: "oz", ounces: "oz", tonne: "t", tonnes: "t",
        liter: "l", liters: "l", litre: "l", litres: "l", milliliter: "ml", milliliters: "ml",
        gallon: "gal", gallons: "gal", cups: "cup", teaspoon: "tsp", tablespoon: "tbsp", quart: "qt", pint: "pt",
        second: "s", seconds: "s", sec: "s", secs: "s", minute: "min", minutes: "min", mins: "min",
        hour: "h", hours: "h", hr: "h", hrs: "h", day: "d", days: "d", week: "wk", weeks: "wk",
        byte: "b", bytes: "b", kilobyte: "kb", kilobytes: "kb", megabyte: "mb", megabytes: "mb",
        gigabyte: "gb", gigabytes: "gb", terabyte: "tb", terabytes: "tb",
        kph: "km/h", kmh: "km/h", mps: "m/s", knot: "kn", knots: "kn",
        celsius: "c", centigrade: "c", "°c": "c", fahrenheit: "f", "°f": "f", kelvin: "k"
    })

    readonly property var _emoji: [
        "😀 grinning face|smile happy", "😂 tears of joy|laugh lol funny", "🤣 rolling on the floor laughing|rofl",
        "😊 smiling face|blush happy", "😍 heart eyes|love", "🥰 smiling with hearts|love", "😘 blowing a kiss|kiss",
        "😎 cool|sunglasses", "🤔 thinking|hmm", "😅 sweat smile|nervous", "😢 crying|sad tear", "😭 sobbing|sad cry",
        "😡 angry|mad", "😱 screaming|shock scared", "😴 sleeping|tired zzz", "🙄 eye roll|annoyed", "😉 wink",
        "🙂 slight smile", "🙃 upside down face", "😇 angel|innocent", "🥳 partying face|party celebrate",
        "🤯 mind blown|shocked", "🥺 pleading|puppy eyes", "😬 grimace|awkward", "🤗 hug", "🫡 salute",
        "😐 neutral face", "😑 expressionless", "🤤 drooling", "🤢 nauseated|sick", "🤮 vomiting", "🥵 hot face",
        "🥶 cold face|freezing", "😷 mask|sick", "🤒 fever|thermometer", "😈 devil|smiling imp", "💀 skull|dead",
        "👻 ghost", "🤖 robot", "👽 alien", "💩 poop", "🙈 see no evil|monkey",
        "👍 thumbs up|yes ok", "👎 thumbs down|no", "👏 clap|applause", "🙌 raised hands|hooray", "🙏 folded hands|pray thanks please",
        "🤝 handshake|deal", "💪 flexed biceps|muscle strong", "👋 waving hand|hello bye", "✌️ victory|peace",
        "🤞 crossed fingers|luck", "👌 ok hand", "🫶 heart hands|love", "👀 eyes|look", "🧠 brain",
        "❤️ red heart|love", "💔 broken heart", "💙 blue heart", "💚 green heart", "💛 yellow heart", "🖤 black heart",
        "💜 purple heart", "🧡 orange heart", "💯 hundred points|perfect score", "🔥 fire|hot lit", "✨ sparkles|magic",
        "⭐ star", "🌟 glowing star", "⚡ lightning|zap", "💥 collision|boom", "🎉 party popper|celebrate",
        "🎂 birthday cake", "🎁 gift|present", "🏆 trophy|winner", "🥇 gold medal|first", "🎯 bullseye|target",
        "🚀 rocket|launch", "💡 light bulb|idea", "📚 books|study", "📖 open book|read", "✏️ pencil|write",
        "📝 memo|note", "📅 calendar|date", "⏰ alarm clock|time", "⏳ hourglass|waiting", "💻 laptop|computer",
        "⌨️ keyboard", "🖥️ desktop computer|monitor", "📱 mobile phone", "🎧 headphones|music", "🎵 music note",
        "🎮 game controller|gaming", "📷 camera", "🔒 locked|secure", "🔑 key", "🔍 magnifying glass|search",
        "🔔 bell|notification", "📌 pushpin|pin", "📎 paperclip", "✅ check mark|done yes", "❌ cross mark|no wrong",
        "⚠️ warning", "❓ question mark", "❗ exclamation mark", "➕ plus", "➖ minus", "➡️ right arrow",
        "⬅️ left arrow", "⬆️ up arrow", "⬇️ down arrow", "🔁 repeat|loop", "☕ coffee|tea hot drink",
        "🍕 pizza", "🍔 burger", "🍜 noodles|ramen", "🍎 apple", "🍌 banana", "🍫 chocolate", "🍺 beer",
        "🌞 sun", "🌙 moon|night", "🌈 rainbow", "☁️ cloud", "🌧️ rain", "❄️ snowflake|cold", "🌍 earth|world",
        "🌱 seedling|plant", "🌸 cherry blossom|flower", "🐱 cat", "🐶 dog", "🐧 penguin|linux", "🐍 snake|python",
        "🦊 fox|firefox", "🐢 turtle|slow", "🐝 bee", "🦋 butterfly", "⚽ soccer|football", "🏏 cricket",
        "🏀 basketball", "🚗 car", "✈️ airplane|flight", "🏠 house|home", "💰 money bag", "💸 money with wings|spending",
        "📈 chart increasing|growth", "📉 chart decreasing", "🧪 test tube|chemistry experiment", "🔬 microscope|science",
        "🧬 dna|biology", "⚗️ alembic|chemistry", "🧮 abacus|calculator", "🇧🇩 flag bangladesh"
    ]

    function _on(name) {
        return LauncherSettings.features[name] !== false
    }

    function _info(name, comment, glyph) {
        return { kind: "info", id: "info", name: name, comment: comment, glyph: glyph }
    }

    function _tilde(path) {
        var h = LauncherData.home
        return path.indexOf(h) === 0 ? "~" + path.slice(h.length) : path
    }

    // ---- query parsing ----
    function parse(query) {
        var q = (query || "").replace(/^\s+/, "")
        if (q.length === 0) return { mode: "apps", arg: "" }

        var c = q.charAt(0)
        if (c === ">" && _on("commands")) return { mode: "cmd", arg: q.slice(1).trim() }
        if (c === "?" && _on("web")) return { mode: "web", engine: LauncherData.defaultEngine, arg: q.slice(1).trim() }
        if (c === "/" && _on("files")) return { mode: "files", arg: q.slice(1).trim() }
        if (c === LauncherSettings.triggerEmoji && _on("emoji")) return { mode: "emoji", arg: q.slice(1).trim() }
        if (c === LauncherSettings.triggerSnippets && _on("snippets")) return { mode: "snippets", arg: q.slice(1).trim() }
        if (c === LauncherSettings.triggerNotes && _on("notes")) return { mode: "note", arg: q.slice(1).trim() }

        var m = /^([a-z]+)\s+(.*)$/i.exec(q)
        if (m) {
            var kw = m[1].toLowerCase()
            var rest = m[2].trim()
            if (_on("web") && rest.length > 0 && Object.prototype.hasOwnProperty.call(LauncherData.engines, kw)) {
                return { mode: "web", engine: kw, arg: rest }
            }
        }
        return { mode: "apps", arg: q.trim() }
    }

    function search(query) {
        var p = parse(query)
        var rows
        switch (p.mode) {
        case "cmd":      rows = cmdRows(p); break
        case "web":      rows = webRows(p); break
        case "files":    rows = fileRows(p); break
        case "note":     rows = noteRows(p); break
        case "snippets": rows = snippetRows(p); break
        case "emoji":    rows = emojiRows(p); break
        default:         rows = appRows(p.arg)
        }

        for (var i = 0; i < rows.length; i++) {
            var r = rows[i]
            if (r.confirm && r.id === armedId) r.comment = "Press Enter again to confirm"
        }
        return rows
    }

    function prepare(query) {
        armedId = ""
        var p = parse(query)

        if (p.mode !== _lastMode) {
            _lastMode = p.mode
            if (p.mode !== "files") {
                fileResults = []
                fileDebounce.stop()
            }
            if (p.mode === "snippets") fetchSnippets()
        }

        if (p.mode === "files") {
            if (p.arg.length >= 2) {
                _fileArg = p.arg
                fileDebounce.restart()
            } else {
                fileResults = []
            }
        }
    }

    function activate(item) {
        if (!item) return false
        if (item.kind === "info") return false

        if (item.kind === "copy") {
            copy(item.value)
            return true
        }

        if (item.kind === "exec") {
            if (item.confirm && armedId !== item.id) {
                armedId = item.id
                return false
            }
            armedId = ""
            Quickshell.execDetached(item.argv)
            return true
        }

        AppLauncherService.launch(item)
        return true
    }

    function copy(text) {
        if (!text) return
        Quickshell.execDetached(["wl-copy", "--", String(text)])
    }

    // ---- providers ----
    function appRows(q) {
        if (q.length === 0) return AppLauncherService.filteredApps("")

        var pre = []

        if (LauncherSettings.inlineCalculator) {
            var calc = CalculatorService.evaluate(q)
            if (calc) {
                pre.push({ kind: "copy", id: "calc", name: "= " + calc.text, comment: q + "  ·  Enter to copy",
                           glyph: "calculate", value: calc.text })
            }
        }

        if (_on("units")) {
            var conv = convertRow(q)
            if (conv) pre.push(conv)
        }

        var sys = systemRows(q.toLowerCase())
        var top = sys.filter(r => r.exact)
        var tail = sys.filter(r => !r.exact)

        return pre.concat(top, AppLauncherService.filteredApps(q), tail)
    }

    function cmdRows(p) {
        if (!p.arg) return [_info("Run a shell command", "Type the command after >", "terminal")]
        return [{ kind: "exec", id: "cmd", name: "Run: " + p.arg, comment: "Runs in sh  ·  Enter to run",
                  glyph: "terminal", argv: ["sh", "-c", p.arg] }]
    }

    function webRows(p) {
        var eng = LauncherData.engines[p.engine] || LauncherData.engines[LauncherData.defaultEngine]
        if (!p.arg) return [_info("Search " + eng.name, "Type your search", "travel_explore")]
        var url = eng.url.replace("%s", encodeURIComponent(p.arg))
        return [{ kind: "exec", id: "web", name: "Search " + eng.name + " for \"" + p.arg + "\"",
                  comment: "Opens in your browser", glyph: "travel_explore", argv: ["xdg-open", url] }]
    }

    function fileRows(p) {
        if (p.arg.length < 2) return [_info("Search files", "Type at least 2 characters after /", "search")]

        var out = []
        for (var i = 0; i < fileResults.length && out.length < 20; i++) {
            var path = fileResults[i]
            var isDir = path.charAt(path.length - 1) === "/"
            var clean = isDir ? path.slice(0, -1) : path
            var slash = clean.lastIndexOf("/")
            out.push({
                kind: "exec", id: "file:" + clean,
                name: clean.slice(slash + 1) + (isDir ? "/" : ""),
                comment: _tilde(clean.slice(0, Math.max(slash, 0))) || "/",
                glyph: isDir ? "folder" : "draft",
                argv: ["xdg-open", clean]
            })
        }
        if (out.length === 0) return [_info(filesLoading ? "Searching…" : "No files found", "", "search")]
        return out
    }

    // ---- notes: shape depends on LauncherData.notesMode ----
    function _pad2(n) { return (n < 10 ? "0" : "") + n }

    function _todayStr() {
        var d = new Date()
        return d.getFullYear() + "-" + _pad2(d.getMonth() + 1) + "-" + _pad2(d.getDate())
    }

    function _slug(text) {
        var s = text.trim().toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "").slice(0, 40)
        return s.length > 0 ? s : "note"
    }

    function _noteTarget(text) {
        var mode = LauncherData.notesMode
        if (mode === "daily") return LauncherData.notesFolder + "/" + _todayStr() + ".md"
        if (mode === "capture") {
            var d = new Date()
            var stamp = _todayStr() + " " + _pad2(d.getHours()) + _pad2(d.getMinutes())
            return LauncherData.notesFolder + "/" + stamp + " " + _slug(text) + ".md"
        }
        return LauncherData.notesFile
    }

    function noteRows(p) {
        if (!p.arg) return [_info("Quick note", "Type your note after " + LauncherSettings.triggerNotes, "edit_note")]

        var mode = LauncherData.notesMode
        var target = _noteTarget(p.arg)
        var where = mode === "running" ? _tilde(target)
                  : mode === "daily" ? "Today's note"
                  : "New note file"
        var script = mode === "capture" ? _noteCreateScript : _noteAppendScript

        return [{ kind: "exec", id: "note", name: "Save note: " + p.arg,
                  comment: where + "  ·  Enter to save", glyph: "edit_note",
                  argv: ["sh", "-c", script, "sh", p.arg, target] }]
    }

    // ---- snippets: scanned from a folder (category = subfolder, name = filename) ----
    function fetchSnippets() {
        snippetsLoading = true
        snippetProc.running = false
        snippetProc.running = true
    }

    Process {
        id: snippetProc
        command: ["sh", "-c", root._snippetsScript, "sh", LauncherData.snippetsFolder]
        stdout: StdioCollector {
            onStreamFinished: {
                root.snippetsLoading = false
                root.snippetResults = root._parseSnippets(text)
            }
        }
    }

    function _parseSnippets(txt) {
        var RS = "\u001e", US = "\u001f"
        var chunks = txt.split(RS).filter(c => c.length > 0)
        var list = []
        for (var i = 0; i < chunks.length; i++) {
            var sep = chunks[i].indexOf(US)
            if (sep < 0) continue
            var path = chunks[i].slice(0, sep)
            var content = chunks[i].slice(sep + 1).replace(/\n$/, "")
            var parts = path.split("/")
            var name = parts[parts.length - 1].replace(/\.[^.]+$/, "")
            var category = parts.length >= 2 ? parts[parts.length - 2] : ""
            list.push({ name: name, category: category, content: content })
        }
        list.sort(function(a, b) {
            return a.category.localeCompare(b.category) || a.name.localeCompare(b.name)
        })
        return list
    }

    function snippetRows(p) {
        var f = p.arg.toLowerCase()
        var out = []
        for (var i = 0; i < snippetResults.length && out.length < 20; i++) {
            var s = snippetResults[i]
            var hay = (s.category + " " + s.name + " " + s.content).toLowerCase()
            if (f && hay.indexOf(f) < 0) continue
            out.push({ kind: "copy", id: "snip:" + s.category + "/" + s.name, name: s.name,
                       comment: (s.category ? s.category + "  ·  " : "") + s.content.replace(/\s+/g, " ").slice(0, 60),
                       glyph: "text_snippet", value: s.content })
        }
        if (out.length === 0) {
            return [_info(snippetsLoading ? "Loading snippets…" : "No snippets found",
                          "Add files under the snippets folder in Settings", "text_snippet")]
        }
        return out
    }

    function emojiRows(p) {
        var tokens = p.arg.toLowerCase().split(/\s+/).filter(t => t.length > 0)
        var out = []
        for (var i = 0; i < _emoji.length && out.length < 30; i++) {
            var s = _emoji[i]
            var sp = s.indexOf(" ")
            var symbol = s.slice(0, sp)
            var meta = s.slice(sp + 1)
            var hay = meta.toLowerCase()
            var ok = true
            for (var t = 0; t < tokens.length; t++) {
                if (hay.indexOf(tokens[t]) < 0) { ok = false; break }
            }
            if (!ok) continue
            out.push({ kind: "copy", id: "emoji:" + symbol, name: symbol + "  " + meta.split("|")[0],
                       comment: "Enter to copy", glyph: "mood", value: symbol })
        }
        if (out.length === 0) return [_info("No emoji found", "Try another word", "mood")]
        return out
    }

    function systemRows(q) {
        if (!_on("system") || q.length < 3) return []
        var out = []
        for (var i = 0; i < systemCommands.length; i++) {
            var cmd = systemCommands[i]
            var hit = false
            var exact = false
            for (var k = 0; k < cmd.keywords.length; k++) {
                var kw = cmd.keywords[k]
                if (kw === q) { hit = true; exact = true }
                else if (kw.indexOf(q) === 0) hit = true
            }
            if (!hit) continue
            out.push({ kind: "exec", id: "sys:" + cmd.id, name: cmd.name,
                       comment: cmd.confirm ? "System  ·  asks to confirm" : "System command",
                       glyph: cmd.glyph, argv: cmd.argv, confirm: cmd.confirm, exact: exact })
        }
        return out
    }

    function _unit(name) {
        var n = name.toLowerCase()
        var key = Object.prototype.hasOwnProperty.call(_unitAlias, n) ? _unitAlias[n] : n
        if (!Object.prototype.hasOwnProperty.call(_units, key)) return null
        return { key: key, dim: _units[key][0], factor: _units[key][1] }
    }

    function _tempConvert(v, from, to) {
        var c = from === "c" ? v : (from === "f" ? (v - 32) * 5 / 9 : v - 273.15)
        return to === "c" ? c : (to === "f" ? c * 9 / 5 + 32 : c + 273.15)
    }

    function _unitLabel(key) {
        return key === "c" ? "°C" : (key === "f" ? "°F" : (key === "k" ? "K" : key))
    }

    function convertRow(q) {
        var m = /^(-?\d*\.?\d+(?:e[+-]?\d+)?)\s*([a-z°\/]+)\s+(?:to|in|as|into)\s+([a-z°\/]+)$/i.exec(q)
        if (!m) return null

        var value = parseFloat(m[1])
        var from = _unit(m[2])
        var to = _unit(m[3])
        if (!from || !to || from.dim !== to.dim) return null

        var result = from.dim === "temp"
            ? _tempConvert(value, from.key, to.key)
            : value * from.factor / to.factor
        if (!isFinite(result)) return null

        var text = String(Number(result.toPrecision(10)))
        return { kind: "copy", id: "unit", name: "= " + text + " " + _unitLabel(to.key),
                 comment: value + " " + _unitLabel(from.key) + "  ·  Enter to copy",
                 glyph: "straighten", value: text }
    }

    Timer {
        id: fileDebounce
        interval: 200
        repeat: false
        onTriggered: {
            root.filesLoading = true
            fileProc.arg = root._fileArg
            fileProc.running = false
            fileProc.running = true
        }
    }

    Process {
        id: fileProc
        property string arg: ""
        command: ["sh", "-c", root._fileScript, "sh", arg]
        stdout: StdioCollector {
            onStreamFinished: {
                root.filesLoading = false
                root.fileResults = text.split("\n").filter(l => l.length > 0)
            }
        }
    }
}