// services/AppLauncherService.qml
pragma Singleton
import QtQuick
import Quickshell

QtObject {
    id: root

    function appId(app) {
        return app.id || app.name || ""
    }

    function _matchesRef(app, ref) {
        var r = String(ref).toLowerCase()
        return (app.name || "").toLowerCase() === r || (app.id || "").toLowerCase() === r
    }

    function _isWordStart(text, i) {
        if (i === 0) return true
        var p = text.charAt(i - 1)
        return p === " " || p === "-" || p === "_" || p === "."
    }

    function _wordStartIndex(text, q) {
        var i = text.indexOf(q)
        while (i >= 0) {
            if (_isWordStart(text, i)) return i
            i = text.indexOf(q, i + 1)
        }
        return -1
    }

    // Score for how well `name` matches `q` (both lowercase). -1 = no match.
    // Prefix mode only accepts "name starts with q" and "a word starts with q".
    function nameScore(name, q, fuzzy) {
        if (name.startsWith(q)) return 1000
        if (_wordStartIndex(name, q) >= 0) return 900
        if (!fuzzy) return -1

        var pos = name.indexOf(q)
        if (pos >= 0) return 700 - Math.min(pos, 99)

        // Fuzzy: characters of q appear in order somewhere in the name
        var ti = 0
        var prev = -2
        var score = 300
        for (var qi = 0; qi < q.length; qi++) {
            var f = name.indexOf(q.charAt(qi), ti)
            if (f < 0) return -1
            if (f === prev + 1) score += 10
            if (_isWordStart(name, f)) score += 15
            score -= Math.min(f - ti, 5)
            prev = f
            ti = f + 1
        }
        return Math.min(650, Math.max(100, score))
    }

    function descScore(app, q) {
        var fields = [app.comment, app.genericName, String(app.keywords || "")]
        for (var i = 0; i < fields.length; i++) {
            if ((fields[i] || "").toLowerCase().includes(q)) return 200
        }
        return -1
    }

    function scoreApp(app, q) {
        var fuzzy = LauncherSettings.matchMode === "Fuzzy"
        var s = nameScore((app.name || "").toLowerCase(), q, fuzzy)
        if (s < 0 && LauncherSettings.searchDescriptions) s = descScore(app, q)
        return s
    }

    // DesktopEntries.applications already excludes Hidden/NoDisplay entries
    function filteredApps(query) {
        var all = [...DesktopEntries.applications.values]
        var q = (query || "").trim().toLowerCase()

        var recentRank = {}
        if (LauncherSettings.showRecentsFirst) {
            var recents = LauncherSettings.recentIds.slice(0, LauncherSettings.recentLimit)
            for (var r = 0; r < recents.length; r++) recentRank[recents[r]] = r
        }

        var aliasRef = ""
        if (q.length > 0 && Object.prototype.hasOwnProperty.call(LauncherData.aliases, q)) {
            aliasRef = LauncherData.aliases[q]
        }
        var pinned = q.length === 0 ? LauncherData.pinned : []

        var entries = []
        for (var i = 0; i < all.length; i++) {
            var a = all[i]
            var s = 0

            if (q.length > 0) {
                s = scoreApp(a, q)
                if (aliasRef !== "" && _matchesRef(a, aliasRef)) s = Math.max(s, 0) + 5000
                else if (s < 0) continue
            } else {
                for (var p = 0; p < pinned.length; p++) {
                    if (_matchesRef(a, pinned[p])) { s += 20000 - p; break }
                }
            }

            var rank = recentRank[appId(a)]
            if (rank !== undefined) {
                s += q.length > 0 ? (80 - rank * 4) : (10000 - rank)
            }
            entries.push({ app: a, name: a.name || "", score: s })
        }

        entries.sort(function(x, y) {
            if (y.score !== x.score) return y.score - x.score
            return x.name.localeCompare(y.name)
        })

        var list = entries.map(e => e.app)
        return q.length > 0 ? list.slice(0, LauncherSettings.maxResults) : list
    }

    function launch(app) {
        if (!app) return
        LauncherSettings.recordLaunch(appId(app))
        app.execute()
    }
}