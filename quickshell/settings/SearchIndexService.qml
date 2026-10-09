// SearchIndexService.qml — finds every individual option on every settings page, automatically.
// At start (and each time Settings opens) it greps the page files for  label: "..."  /  title: "..."
// (and the description:/subtitle: just after it), maps each file to its menu or view through the
// `source` paths in SettingsRegistry, and exposes the result as `entries` for the search box.
// Nothing is listed by hand: a new toggle or slider with a plain-string label is searchable as soon
// as the page file has it. Labels built from variables (label: someExpression) are not picked up.
// Not a singleton (no qmldir): SettingsApp.qml creates one instance and hands `entries` to SearchBox.
import QtQuick
import Quickshell
import Quickshell.Io
import "./core"

Item {
    id: root

    // Folder holding SettingsApp.qml, as a plain path. Set by SettingsApp.
    property string baseDir: ""

    // [{ menuId, viewId, title, description, path, icon }]
    property var entries: []

    function rebuild() {
        if (root.baseDir !== "" && !scanProc.running) scanProc.running = true
    }

    onBaseDirChanged: root.rebuild()
    Component.onCompleted: root.rebuild()

    // Registry pages that have a real source file: their folder decides which page a file belongs to.
    function _pageMap() {
        const out = []
        function add(menu, view) {
            const src = view ? view.source : menu.source
            if (!src) return
            out.push({
                dir: src.substring(0, src.lastIndexOf("/")),
                menuId: menu.id,
                viewId: view ? view.id : "",
                icon: view ? view.icon : menu.icon,
                path: view ? menu.title + " › " + view.title : menu.title
            })
        }
        const clusters = SettingsRegistry.clusters
        for (let c = 0; c < clusters.length; c++) {
            const menus = clusters[c].menus
            for (let m = 0; m < menus.length; m++) {
                add(menus[m], null)
                const views = menus[m].views || []
                for (let v = 0; v < views.length; v++) add(menus[m], views[v])
            }
        }
        return out
    }

    // Longest matching folder wins, so pages/appearance/motion beats pages/appearance.
    function _pageFor(pages, file) {
        const prefix = root.baseDir + "/"
        const rel = file.startsWith(prefix) ? file.substring(prefix.length) : file
        let best = null
        for (let i = 0; i < pages.length; i++) {
            if (rel.startsWith(pages[i].dir + "/") && (!best || pages[i].dir.length > best.dir.length)) best = pages[i]
        }
        return best
    }

    function _parse(text) {
        const pages = root._pageMap()
        const re = /(?:^|[^A-Za-z0-9_.])(label|title|description|subtitle)\s*:\s*"((?:[^"\\]|\\.)*)"/g
        const found = []
        let cur = null

        const lines = text.split("\n")
        for (let i = 0; i < lines.length; i++) {
            const lm = lines[i].match(/^(.*?):(\d+):(.*)$/)
            if (!lm) continue
            const file = lm[1]
            const lineNo = parseInt(lm[2])
            const page = root._pageFor(pages, file)
            if (!page) continue

            re.lastIndex = 0
            let m
            while ((m = re.exec(lm[3])) !== null) {
                let str = m[2]
                try { str = JSON.parse('"' + m[2] + '"') } catch (e) { }
                if (m[1] === "label" || m[1] === "title") {
                    cur = { menuId: page.menuId, viewId: page.viewId, title: str, description: "",
                            path: page.path, icon: page.icon, file: file, line: lineNo }
                    found.push(cur)
                } else if (cur && cur.file === file && lineNo - cur.line <= 3 && cur.description === "") {
                    cur.description = str
                }
            }
        }

        // The same label can appear twice on a page (a tile and a row): keep the first.
        const seen = {}
        const out = []
        for (let i = 0; i < found.length; i++) {
            const e = found[i]
            if (e.title.trim() === "") continue
            const key = e.menuId + "|" + e.viewId + "|" + e.title.toLowerCase()
            if (seen[key]) continue
            seen[key] = true
            out.push({ menuId: e.menuId, viewId: e.viewId, title: e.title, description: e.description,
                       path: e.path, icon: e.icon })
        }
        root.entries = out
    }

    Process {
        id: scanProc
        command: ["grep", "-RnE", "--include=*.qml",
                  "(^|[^A-Za-z0-9_.])(label|title|description|subtitle)[[:space:]]*:[[:space:]]*\"",
                  root.baseDir + "/pages"]
        stdout: StdioCollector { onStreamFinished: root._parse(text) }
    }
}
