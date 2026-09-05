// services/HyprlandAnimationsService.qml — discovers Hyprland animation presets
// under ~/.config/hypr/modules/animations/*.lua and switches which one is
// active by rewriting the require(...) line in modules/animations.lua, then
// triggering hyprctl reload. No compile step exists for this Lua config —
// Hyprland picks up the change directly on save/reload.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string animationsDir: "~/.config/hypr/modules/animations"
    readonly property string requireFile: "~/.config/hypr/modules/animations.lua"

    property var animationsList: []   // [{ name: "apple" }, { name: "fade" }, ...]
    property string currentAnimation: ""

    function refresh() {
        listProc.running = true
        currentProc.running = true
    }

    function applyAnimation(presetName) {
        applyProc.command = ["sh", "-c",
            "sed -i 's/modules\\.animations\\.[A-Za-z0-9_]*/modules.animations." + presetName + "/' " + root.requireFile + " && hyprctl reload"]
        applyProc.running = true
    }

    Component.onCompleted: refresh()

    // Lists preset files, strips path + .lua extension for display names.
    Process {
        id: listProc
        command: ["sh", "-c", "ls " + root.animationsDir + "/*.lua 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n").filter(l => l.length > 0)
                root.animationsList = lines.map(path => {
                    let file = path.split("/").pop()
                    return { name: file.replace(/\.lua$/, "") }
                })
            }
        }
    }

    // Parses which preset modules/animations.lua currently requires.
    Process {
        id: currentProc
        command: ["sh", "-c", "cat " + root.requireFile + " 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                let match = text.match(/modules\.animations\.([A-Za-z0-9_]+)/)
                root.currentAnimation = match ? match[1] : ""
            }
        }
    }

    Process {
        id: applyProc
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) currentProc.running = true
        }
    }
}