// core/SettingsNav.qml — where the user currently is: a menu, and optionally a view inside it.
// No breadcrumbs: a view just shows its own title plus a back arrow.
pragma Singleton
import QtQuick

QtObject {
    id: root

    property string menuId: SettingsRegistry.defaultMenuId
    property string viewId: ""

    readonly property var menu: SettingsRegistry.findMenu(root.menuId)
    readonly property var view: root.viewId !== "" ? SettingsRegistry.findView(root.menuId, root.viewId) : null
    readonly property bool canGoBack: root.view !== null

    readonly property string title: root.view ? root.view.title : (root.menu ? root.menu.title : "")
    readonly property string subtitle: root.view ? root.view.subtitle : (root.menu ? root.menu.subtitle : "")
    readonly property string icon: root.view ? root.view.icon : (root.menu ? root.menu.icon : "")

    // Path (relative to SettingsApp.qml) of the page the host should load.
    readonly property string pageSource: {
        if (root.view) {
            return root.view.source ? root.view.source : "components/PlaceholderPage.qml"
        }
        if (root.menu) {
            if (root.menu.views && root.menu.views.length > 0) return "components/LandingPage.qml"
            if (root.menu.source) return root.menu.source
        }
        return "components/PlaceholderPage.qml"
    }

    function openMenu(id) {
        root.viewId = ""
        root.menuId = id
    }

    function openView(menuId, viewId) {
        root.menuId = menuId
        root.viewId = viewId
    }

    function back() {
        if (root.viewId !== "") root.viewId = ""
    }

    // Used by `qs ipc call settings section <name>`; accepts "menu" or "menu/view".
    // Exact id/title match wins; otherwise the first partial match is used.
    function openByName(name) {
        const parts = String(name).toLowerCase().trim().split("/")
        const menuQuery = parts[0].trim()
        const viewQuery = parts.length > 1 ? parts[1].trim() : ""

        for (let pass = 0; pass < 2; pass++) {
            for (let c = 0; c < SettingsRegistry.clusters.length; c++) {
                const menus = SettingsRegistry.clusters[c].menus
                for (let m = 0; m < menus.length; m++) {
                    const menu = menus[m]
                    const id = menu.id.toLowerCase()
                    const title = menu.title.toLowerCase()
                    const hit = pass === 0 ? (id === menuQuery || title === menuQuery)
                                           : (id.includes(menuQuery) || title.includes(menuQuery))
                    if (!hit) continue

                    root.openMenu(menu.id)
                    if (viewQuery !== "" && menu.views) {
                        for (let v = 0; v < menu.views.length; v++) {
                            const view = menu.views[v]
                            if (view.id === viewQuery || view.title.toLowerCase().includes(viewQuery)) {
                                root.openView(menu.id, view.id)
                                break
                            }
                        }
                    }
                    return true
                }
            }
        }
        return false
    }
}
