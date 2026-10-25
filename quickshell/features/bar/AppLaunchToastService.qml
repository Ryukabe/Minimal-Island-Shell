// features/bar/AppLaunchToastService.qml — island toast when an app opens its first window.
// Needs a qmldir "singleton" entry. Extra windows of an app already open never toast.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland as QsHypr
import "."
import "../notifications"
import "../../core/shell"

Singleton {
    id: root

    // What the toast page shows.
    property string appName: ""
    property string iconName: ""

    // Windows that open while the shell starts up must not toast (same idea as EventToastService).
    readonly property int warmupMs: 3000
    property bool _ready: false

    // Helper windows that are not "an app launching". Add more window classes here if needed.
    readonly property var ignoredClasses: [
        "xdg-desktop-portal-gtk",
        "xdg-desktop-portal-kde",
        "polkit-gnome-authentication-agent-1",
        "quickshell"
    ]

    // Open windows (address -> class) and how many windows each class has.
    // Plain objects edited in place; nothing binds to them.
    property var _windowClass: ({})
    property var _classCount: ({})

    // Touch the desktop entry index early so the first lookup is not empty.
    readonly property var _warm: DesktopEntries.applications

    Timer {
        running: true
        interval: root.warmupMs
        repeat: false
        onTriggered: root._ready = true
    }

    // Windows already open when the shell starts count as open, so opening a second
    // window of one of those apps does not toast.
    Process {
        running: true
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root._seed(text)
        }
    }

    Connections {
        target: QsHypr.Hyprland

        function onRawEvent(event) {
            if (event.name === "openwindow") {
                // WINDOWADDRESS,WORKSPACENAME,WINDOWCLASS,WINDOWTITLE
                const args = event.parse(4)
                root._register(args[0], args[2], true)
            } else if (event.name === "closewindow") {
                root._closed(event.data)
            }
        }
    }

    // Hyprland's events give addresses without "0x"; `hyprctl clients -j` includes it.
    function _norm(address) {
        return String(address || "").replace(/^0x/, "")
    }

    function _seed(text) {
        let clients
        try {
            clients = JSON.parse(text)
        } catch (e) {
            return
        }
        if (!Array.isArray(clients)) return
        for (let i = 0; i < clients.length; i++) {
            root._register(clients[i].address, clients[i]["class"], false)
        }
    }

    function _register(address, cls, announce) {
        const key = root._norm(address)
        if (key === "" || !cls) return
        if (root._windowClass[key] !== undefined) return

        root._windowClass[key] = cls
        const n = (root._classCount[cls] || 0) + 1
        root._classCount[cls] = n

        if (announce && n === 1) root._announce(cls)
    }

    function _closed(address) {
        const key = root._norm(address)
        const cls = root._windowClass[key]
        if (cls === undefined) return

        delete root._windowClass[key]
        const n = (root._classCount[cls] || 1) - 1
        if (n <= 0) delete root._classCount[cls]
        else root._classCount[cls] = n
    }

    function _announce(cls) {
        if (!root._ready || !ShellState.appToastEnabled) return
        if (root.ignoredClasses.indexOf(cls) >= 0) return

        // Never kick the user out of an open panel (launcher, control center, ...) or hide a
        // notification toast. Only the idle bar and the other short toasts give way.
        const page = ShellState.activePage
        if (page !== "clock" && page !== "timertoast" && page !== "eventtoast" && page !== "apptoast") return

        const entry = DesktopEntries.heuristicLookup(cls)
        if (entry) {
            root.appName = entry.name
            root.iconName = entry.icon
        } else {
            root.appName = cls.charAt(0).toUpperCase() + cls.slice(1)
            root.iconName = ""
        }
        ShellState.flashPageFor("apptoast", ShellState.appToastMs)
    }
}