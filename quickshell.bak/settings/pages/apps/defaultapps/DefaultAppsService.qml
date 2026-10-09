// pages/apps/defaultapps/DefaultAppsService.qml — reads and sets the default app for each kind of file.
// Everything goes through xdg-mime (package xdg-utils), the same store other desktop apps read, so a
// change here is a real system change, not a shell-only setting. Candidates come from the installed
// .desktop entries (Quickshell DesktopEntries), filtered by their Categories. Not a singleton:
// DefaultAppsSettings.qml creates one while the page is open.
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    visible: false

    // key: used internally. mimes: the first one is queried, all of them are set together.
    // categories: an app is offered if it has ANY of these (none match -> every app is offered).
    readonly property var kinds: [
        { key: "browser", categories: ["WebBrowser"],
          mimes: ["x-scheme-handler/https", "x-scheme-handler/http", "text/html"] },
        { key: "email", categories: ["Email"], mimes: ["x-scheme-handler/mailto"] },
        { key: "files", categories: ["FileManager"], mimes: ["inode/directory"] },
        { key: "video", categories: ["Video"],
          mimes: ["video/mp4", "video/x-matroska", "video/webm", "video/mpeg"] },
        { key: "music", categories: ["Audio", "Music"],
          mimes: ["audio/mpeg", "audio/flac", "audio/ogg", "audio/x-wav"] },
        { key: "images", categories: ["Viewer", "Graphics"],
          mimes: ["image/png", "image/jpeg", "image/webp", "image/gif"] },
        { key: "text", categories: ["TextEditor"], mimes: ["text/plain", "text/markdown"] },
        { key: "pdf", categories: ["Viewer", "Office"], mimes: ["application/pdf"] }
    ]

    // Installed apps that are meant to be shown in menus: [{ id, name, categories }]
    readonly property var apps: {
        const out = []
        const list = DesktopEntries.applications.values
        for (let i = 0; i < list.length; i++) {
            const e = list[i]
            if (e.noDisplay) continue
            out.push({ id: e.id, name: e.name, categories: Array.from(e.categories || []) })
        }
        out.sort((a, b) => a.name.localeCompare(b.name))
        return out
    }

    // key -> desktop id (without ".desktop"), as last read from the system
    property var current: ({})

    function _kind(key) {
        for (let i = 0; i < root.kinds.length; i++) if (root.kinds[i].key === key) return root.kinds[i]
        return null
    }

    function _appById(id) {
        for (let i = 0; i < root.apps.length; i++) if (root.apps[i].id === id) return root.apps[i]
        return null
    }

    // Names offered for a kind. The current app is always included so the pill never shows a stranger.
    function optionsFor(key) {
        const kind = root._kind(key)
        if (!kind) return []
        let list = root.apps.filter(a => a.categories.some(c => kind.categories.includes(c)))
        if (list.length === 0) list = root.apps
        const names = []
        for (let i = 0; i < list.length; i++) if (!names.includes(list[i].name)) names.push(list[i].name)
        const cur = root._appById(root.current[key])
        if (cur && !names.includes(cur.name)) names.push(cur.name)
        return names
    }

    function currentName(key) {
        const id = root.current[key]
        if (!id) return "Not set"
        const app = root._appById(id)
        return app ? app.name : id
    }

    function choose(key, name) {
        const kind = root._kind(key)
        if (!kind) return
        // Prefer a candidate for this kind when two apps share a name.
        let match = root.apps.find(a => a.name === name && a.categories.some(c => kind.categories.includes(c)))
        if (!match) match = root.apps.find(a => a.name === name)
        if (!match) return

        const next = Object.assign({}, root.current)
        next[key] = match.id
        root.current = next    // show the choice immediately; refresh() confirms it

        setProcComp.createObject(root, {
            command: ["xdg-mime", "default", match.id + ".desktop"].concat(kind.mimes),
            running: true
        })
    }

    function refresh() {
        const parts = root.kinds.map(k => "printf '" + k.key + "=%s\\n' \"$(xdg-mime query default " + k.mimes[0] + " 2>/dev/null)\"")
        queryProc.command = ["sh", "-c", parts.join("; ")]
        queryProc.running = true
    }

    Component.onCompleted: root.refresh()

    Process {
        id: queryProc
        stdout: StdioCollector {
            onStreamFinished: {
                const next = {}
                const lines = text.split("\n")
                for (let i = 0; i < lines.length; i++) {
                    const eq = lines[i].indexOf("=")
                    if (eq < 1) continue
                    const value = lines[i].substring(eq + 1).trim().replace(/\.desktop$/, "")
                    next[lines[i].substring(0, eq)] = value
                }
                root.current = next
            }
        }
    }

    // One short-lived process per change, so quick successive choices don't drop each other.
    Component {
        id: setProcComp

        Process {
            id: setProc
            onExited: {
                root.refresh()
                setProc.destroy()
            }
        }
    }
}
