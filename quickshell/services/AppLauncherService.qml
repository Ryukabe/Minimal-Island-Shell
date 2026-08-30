// services/AppLauncherService.qml
pragma Singleton
import QtQuick
import Quickshell

QtObject {
    id: root

    // ── App list + search ──────────────────────────────────────────────
    // DesktopEntries.applications already excludes Hidden/NoDisplay entries
    function filteredApps(query) {
        var all = [...DesktopEntries.applications.values].sort(
            (a, b) => a.name.localeCompare(b.name)
        )

        if (!query || query.trim().length === 0) {
            return all
        }

        var q = query.trim().toLowerCase()
        return all.filter(a => {
            var name = (a.name || "").toLowerCase()
            var comment = (a.comment || "").toLowerCase()
            return name.includes(q) || comment.includes(q)
        })
    }

    function launch(app) {
        if (!app) return
        app.execute()
    }
}