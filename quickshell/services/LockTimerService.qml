// services/LockTimerService.qml — lock-after-idle, stored in ~/.config/hypr/hypridle.conf.
// The file is the single source of truth: nothing is duplicated in ShellState.
// Needs a qmldir "singleton" entry.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string configPath: Quickshell.env("HOME") + "/.config/hypr/hypridle.conf"

    property bool available: false
    property string status: "Looking for hypridle.conf"
    property int lockSeconds: 0
    readonly property int lockMinutes: Math.round(root.lockSeconds / 60)

    // Seconds between the lock listener and the screen-off listener, kept when the lock timer
    // moves. -1 = no screen-off listener after the lock one, leave it alone.
    property int screenOffGap: -1

    property string _text: ""
    property bool _backedUp: false

    // Pulls the "timeout" of the listener whose on-timeout matches `pattern` (first match).
    function _timeoutFor(text, pattern) {
        var blocks = text.match(/listener\s*\{[^}]*\}/g) || []
        var re = new RegExp("on-timeout\\s*=[^\\n]*" + pattern)
        for (var i = 0; i < blocks.length; i++) {
            if (!re.test(blocks[i])) continue
            var t = /^\s*timeout\s*=\s*(\d+)/m.exec(blocks[i])
            if (t) return parseInt(t[1])
        }
        return -1
    }

    // Rewrites the timeout of the first listener whose on-timeout matches `pattern`.
    // Everything else in the file is returned untouched.
    function _withTimeout(text, pattern, seconds) {
        var re = new RegExp("on-timeout\\s*=[^\\n]*" + pattern)
        var done = false
        return text.replace(/listener\s*\{[^}]*\}/g, function (block) {
            if (done || !re.test(block)) return block
            done = true
            return block.replace(/^(\s*timeout\s*=\s*)\d+/m, function (m, prefix) {
                return prefix + seconds
            })
        })
    }

    function _applyText(text) {
        root._text = text
        var lock = root._timeoutFor(text, "loginctl lock-session")
        if (lock <= 0) {
            root.available = false
            root.status = "No listener with on-timeout = loginctl lock-session found in hypridle.conf"
            return
        }
        var dpms = root._timeoutFor(text, "dpms off")
        root.lockSeconds = lock
        root.screenOffGap = dpms > lock ? dpms - lock : -1
        root.available = true
        root.status = ""
    }

    function setLockMinutes(minutes) {
        if (!root.available) return
        root.lockSeconds = minutes * 60   // the slider follows immediately; the file is written after the debounce
        saveTimer.restart()
    }

    function _write() {
        var text = root._withTimeout(root._text, "loginctl lock-session", root.lockSeconds)
        if (root.screenOffGap >= 0)
            text = root._withTimeout(text, "dpms off", root.lockSeconds + root.screenOffGap)
        if (text === root._text) return

        root._text = text
        configFile.setText(text)

        // Restart only if hypridle is already running, so this never starts one you don't use.
        Quickshell.execDetached(["sh", "-c",
            "pgrep -x hypridle >/dev/null && { pkill -x hypridle; sleep 0.3; setsid hypridle >/dev/null 2>&1 & }"])
    }

    FileView {
        id: configFile
        path: root.configPath
        printErrors: false
        watchChanges: true

        onLoaded: {
            // First successful load, before any edit can happen: keep a copy of the original.
            if (!root._backedUp) {
                root._backedUp = true
                Quickshell.execDetached(["cp", "-n", root.configPath, root.configPath + ".bak"])
            }
            // Don't let our own write (or a reload mid-drag) snap the slider back.
            if (saveTimer.running) return
            root._applyText(text())
        }

        onLoadFailed: (error) => {
            root.available = false
            root.status = "hypridle.conf not found at " + root.configPath
        }

        onFileChanged: reload()
    }

    Timer {
        id: saveTimer
        interval: 500
        repeat: false
        onTriggered: root._write()
    }
}