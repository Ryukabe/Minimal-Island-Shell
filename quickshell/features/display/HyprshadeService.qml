pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property string _home: Quickshell.env("HOME")
    readonly property string shaderDir: root._home + "/.config/hypr/shaders"

    // Names of every .glsl file in shaderDir (no extension), rescanned by refresh().
    property var shades: []
    // Name of the shader Hyprland is using right now, "" when none.
    property string current: ""
    readonly property bool enabled: root.current !== ""
    // Last shade the user picked; the tile turns this back on.
    property string lastShade: ""

    // What the user last asked for ("" = off). Saved, and re-applied after a Hyprland reload
    // and at shell startup, until the user turns it off.
    property string _wanted: ""
    property bool _applyingConfig: false

    function prettyName(name) {
        if (!name) return ""
        const spaced = name.replace(/[-_]+/g, " ")
        return spaced.charAt(0).toUpperCase() + spaced.slice(1)
    }

    function refresh() {
        listProc.running = true
        currentProc.running = true
    }

    function select(name) {
        if (applyProc.running) return
        root.lastShade = name
        root._wanted = name
        saveTimer.restart()
        applyProc.command = ["hyprshade", "on", root.shaderDir + "/" + name + ".glsl"]
        applyProc.running = true
    }

    function turnOff() {
        if (applyProc.running) return
        root._wanted = ""
        saveTimer.restart()
        applyProc.command = ["hyprshade", "off"]
        applyProc.running = true
    }

    function toggle() {
        if (root.enabled) {
            root.turnOff()
            return
        }
        const remembered = root.shades.indexOf(root.lastShade) >= 0 ? root.lastShade : ""
        const pick = remembered !== "" ? remembered : (root.shades.length > 0 ? root.shades[0] : "")
        if (pick !== "") root.select(pick)
    }

    // Puts the wanted shade back. Used after hyprctl reload (which wipes runtime keywords)
    // and at startup (after a reboot, Hyprland has no shader).
    function _restore() {
        if (root._wanted === "" || applyProc.running) return
        applyProc.command = ["hyprshade", "on", root.shaderDir + "/" + root._wanted + ".glsl"]
        applyProc.running = true
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "configreloaded") restoreTimer.restart()
        }
    }

    // Short wait so Hyprland has finished applying the reloaded config.
    Timer {
        id: restoreTimer
        interval: 300
        repeat: false
        onTriggered: root._restore()
    }

    // Lists the shader folder directly, so new files appear without code changes.
    Process {
        id: listProc
        command: ["sh", "-c",
            "for f in \"$1\"/*.glsl; do [ -e \"$f\" ] && basename \"$f\" .glsl; done",
            "sh", root.shaderDir]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n").map(s => s.trim()).filter(s => s !== "")
                lines.sort()
                root.shades = lines
            }
        }
    }

    // Asks Hyprland what is really applied, so the UI never guesses.
    Process {
        id: currentProc
        command: ["hyprctl", "getoption", "decoration:screen_shader", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                let path = ""
                try {
                    path = JSON.parse(text).str || ""
                } catch (e) {
                    path = ""
                }
                if (path === "" || path === "[[EMPTY]]") {
                    root.current = ""
                    return
                }
                const file = path.split("/").pop()
                root.current = file.replace(/\.glsl$/, "")
            }
        }
    }

    Process {
        id: applyProc
        onExited: (exitCode) => {
            if (exitCode !== 0) console.warn("HyprshadeService: hyprshade exited with code", exitCode)
            currentProc.running = true
        }
    }

    // Safety net: catches shader changes made outside the shell (hyprshade in a terminal).
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: currentProc.running = true
    }

    Component.onCompleted: root.refresh()

    // ---- Persistence: last picked shade, and whether one should be on ----
    FileView {
        id: configFile
        path: root._home + "/.config/quickshell/state/shades.json"
        printErrors: false
        onLoaded: {
            root._applyingConfig = true
            try {
                const data = JSON.parse(text())
                if (typeof data.lastShade === "string") root.lastShade = data.lastShade
                if (typeof data.wanted === "string") root._wanted = data.wanted
            } catch (e) {
                console.warn("HyprshadeService: bad shades.json, ignoring", e)
            }
            root._applyingConfig = false
            // Bring back the shade that was on when the shell last ran.
            if (root._wanted !== "") restoreTimer.restart()
        }
    }

    Timer {
        id: saveTimer
        interval: 400
        repeat: false
        onTriggered: {
            if (root._applyingConfig) return
            configFile.setText(JSON.stringify({ lastShade: root.lastShade, wanted: root._wanted }, null, 2))
        }
    }
}