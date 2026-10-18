// SearchIndexService.qml — finds every individual option on every settings page, automatically.
// One grep over the whole features folder collects, per file: option texts (label/title plus the
// description/subtitle right after) and section headings (SectionLabel), and which components the
// file uses. Each registry page then gets its own file plus every helper file it uses (found by
// component name), so options in helper components are searchable too. Results go to `entries`.
// Skipped on purpose: labels built from expressions, choices inside model arrays ({ label: "AM" }),
// and registry sources shared by several entries (e.g. the three Keybinds views).
// Handles files with Windows (CRLF) line endings.
// Not a singleton (no qmldir): SettingsApp.qml creates one instance and hands `entries` to SearchBox.
import QtQuick
import Quickshell.Io
import "core"

Item {
    id: root

    // Folder holding SettingsApp.qml, as a plain path. Set by SettingsApp.
    property string baseDir: ""

    // [{ menuId, viewId, title, description, path, icon }]
    property var entries: []

    // The features folder (parent of baseDir), built from text so no ".." is involved.
    readonly property string scanDir: root.baseDir.substring(0, root.baseDir.lastIndexOf("/"))

    function rebuild() {
        if (root.baseDir !== "" && !scanProc.running) scanProc.running = true
    }

    onBaseDirChanged: root.rebuild()
    Component.onCompleted: root.rebuild()

    // ── Path helpers ───────────────────────────────────────────
    function _norm(p) {
        const out = []
        const parts = String(p).split("/")
        for (let i = 0; i < parts.length; i++) {
            if (parts[i] === "" || parts[i] === ".") continue
            if (parts[i] === "..") out.pop()
            else out.push(parts[i])
        }
        return "/" + out.join("/")
    }

    function _dirOf(p) { return p.substring(0, p.lastIndexOf("/")) }

    function _suffixOf(p) {
        const parts = p.split("/")
        return parts.slice(Math.max(0, parts.length - 2)).join("/")
    }

    function _unescape(s) {
        try { return JSON.parse('"' + s + '"') } catch (e) { return s }
    }

    // ── Registry ───────────────────────────────────────────────
    function _pageMap() {
        const all = []
        function add(menu, view) {
            const src = view ? view.source : menu.source
            if (!src) return
            const file = root._norm(root.baseDir + "/" + src)
            all.push({
                file: file,
                suffix: root._suffixOf(file),
                dir: root._dirOf(file),
                folderMatch: src.indexOf("pages/") === 0,
                menuId: menu.id,
                viewId: view ? view.id : "",
                title: view ? view.title : menu.title,
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
        const count = {}
        const registered = {}
        for (let i = 0; i < all.length; i++) {
            count[all[i].file] = (count[all[i].file] || 0) + 1
            registered[all[i].file] = true
        }
        return { pages: all.filter(p => count[p.file] === 1), registered: registered }
    }

    // ── Reading grep output ────────────────────────────────────
    function _isOptionKey(before) {
        const t = before.replace(/\s+$/, "")
        if (t === "" || t.endsWith(";")) return true
        if (t.endsWith("{")) return /[A-Z][A-Za-z0-9_]*$/.test(t.slice(0, -1).replace(/\s+$/, ""))
        return false
    }

    function _optionsOf(items) {
        const out = []
        let cur = null
        for (let i = 0; i < items.length; i++) {
            const it = items[i]
            if (it.kind === "section") {
                cur = null
                out.push({ title: it.text, description: "", line: it.line })
            } else if (it.kind === "label" || it.kind === "title") {
                cur = { title: it.text, description: "", line: it.line }
                out.push(cur)
            } else if (cur && it.line - cur.line <= 3 && cur.description === "") {
                cur.description = it.text
            }
        }
        return out
    }

    function _collect(start, files, byName, registered, compDir, coreDir) {
        const seen = {}
        const order = []
        const stack = [start]
        while (stack.length > 0) {
            const f = stack.pop()
            if (seen[f]) continue
            seen[f] = true
            order.push(f)
            const uses = Object.keys(files[f].uses)
            for (let u = 0; u < uses.length; u++) {
                const cands = byName[uses[u]]
                if (!cands) continue
                let pick = null
                for (let c = 0; c < cands.length; c++) {
                    if (root._dirOf(cands[c]) === root._dirOf(f)) { pick = cands[c]; break }
                }
                if (!pick && cands.length === 1) pick = cands[0]
                if (!pick || seen[pick] || registered[pick]) continue
                if (pick.startsWith(compDir) || pick.startsWith(coreDir)) continue
                stack.push(pick)
            }
        }
        return order
    }

    function _parse(text) {
        const keyRe = /(label|title|description|subtitle)\s*:\s*(?:qsTr\(\s*)?(["'])((?:\\.|(?!\2)[^\\])*)\2/g
        const sectionRe = /\bSectionLabel\s*\{\s*text\s*:\s*(["'])((?:\\.|(?!\1)[^\\])*)\1/
        const useRe = /\b[A-Z][A-Za-z0-9_]*(?=\s*\{)/g

        // 1) per file: used component names and option items.
        // Split on \r?\n so files with Windows line endings are read like any other.
        const files = {}
        const lines = text.split(/\r?\n/)
        for (let i = 0; i < lines.length; i++) {
            const lm = lines[i].match(/^(.*?):(\d+):(.*)$/)
            if (!lm) continue
            const content = lm[3]
            if (content.trim().indexOf("//") === 0) continue
            const file = root._norm(lm[1])
            const lineNo = parseInt(lm[2])

            let f = files[file]
            if (!f) { f = { uses: {}, items: [] }; files[file] = f }

            useRe.lastIndex = 0
            let u
            while ((u = useRe.exec(content)) !== null) f.uses[u[0]] = true

            const sm = content.match(sectionRe)
            if (sm) f.items.push({ kind: "section", text: root._unescape(sm[2]), line: lineNo })

            keyRe.lastIndex = 0
            let m
            while ((m = keyRe.exec(content)) !== null) {
                if (!root._isOptionKey(content.substring(0, m.index))) continue
                f.items.push({ kind: m[1], text: root._unescape(m[3]), line: lineNo })
            }
        }

        const names = Object.keys(files)
        const byName = {}
        for (let i = 0; i < names.length; i++) {
            const base = names[i].substring(names[i].lastIndexOf("/") + 1).replace(/\.qml$/, "")
            if (!byName[base]) byName[base] = []
            byName[base].push(names[i])
        }

        // 2) per registry page: gather its files and turn their items into entries
        const map = root._pageMap()
        const compDir = root._norm(root.baseDir + "/components") + "/"
        const coreDir = root._norm(root.baseDir + "/core") + "/"
        const out = []
        const seen = {}
        const missing = []

        for (let p = 0; p < map.pages.length; p++) {
            const page = map.pages[p]

            let start = files[page.file] ? page.file : ""
            if (start === "") {
                let hit = ""
                let hits = 0
                for (let i = 0; i < names.length; i++) {
                    if (names[i].endsWith("/" + page.suffix)) { hit = names[i]; hits++ }
                }
                if (hits === 1) start = hit
            }
            if (start === "") { missing.push(page.menuId + (page.viewId ? "/" + page.viewId : "")); continue }

            const group = root._collect(start, files, byName, map.registered, compDir, coreDir)
            if (page.folderMatch) {
                for (let i = 0; i < names.length; i++) {
                    if (names[i].startsWith(page.dir + "/") && !map.registered[names[i]] && group.indexOf(names[i]) < 0)
                        group.push(names[i])
                }
            }

            for (let g = 0; g < group.length; g++) {
                const opts = root._optionsOf(files[group[g]].items)
                for (let o = 0; o < opts.length; o++) {
                    const e = opts[o]
                    const title = e.title.trim()
                    if (title === "" || title === page.title) continue
                    const key = page.menuId + "|" + page.viewId + "|" + title.toLowerCase()
                    if (seen[key]) continue
                    seen[key] = true
                    out.push({ menuId: page.menuId, viewId: page.viewId, title: title,
                               description: e.description, path: page.path, icon: page.icon })
                }
            }
        }

        root.entries = out
        console.log("SearchIndex v5: " + names.length + " files | " + out.length + " options from "
                    + (map.pages.length - missing.length) + "/" + map.pages.length + " pages"
                    + (missing.length > 0 ? " | no file for: " + missing.join(", ") : ""))
    }

    Process {
        id: scanProc
        command: ["grep", "-RnE", "--include=*.qml",
                  "(^|[^A-Za-z0-9_.])(label|title|description|subtitle)[[:space:]]*:[[:space:]]*(qsTr\\()?[\"']|[A-Z][A-Za-z0-9_]*[[:space:]]*[{]",
                  root.scanDir]
        stdout: StdioCollector { onStreamFinished: root._parse(text) }
    }
}