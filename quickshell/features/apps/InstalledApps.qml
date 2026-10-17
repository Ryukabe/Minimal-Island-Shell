// features/apps/InstalledApps.qml — the one list of installed apps for the Apps pages.
// Every app that is meant to appear in menus (NoDisplay entries are skipped), A to Z:
// [{ id, name, comment, icon, categories }]. `id` is the desktop-entry id without ".desktop".
// Used by DefaultAppsService, AllAppsSettings and StartupAppsSettings so the filtering and
// sorting live in one place.
pragma Singleton
import QtQuick
import Quickshell

QtObject {
    id: root

    readonly property var apps: {
        const out = []
        const list = DesktopEntries.applications.values
        for (let i = 0; i < list.length; i++) {
            const e = list[i]
            if (e.noDisplay) continue
            out.push({
                id: e.id,
                name: e.name,
                comment: e.comment || e.genericName || "",
                icon: e.icon,
                categories: Array.from(e.categories || [])
            })
        }
        out.sort((a, b) => a.name.localeCompare(b.name))
        return out
    }

    // The app with this desktop-entry id, or null.
    function byId(id) {
        for (let i = 0; i < root.apps.length; i++) if (root.apps[i].id === id) return root.apps[i]
        return null
    }
}
