pragma Singleton
import QtQuick
import Quickshell.Io
import ".."
import "../../../services"
import "../../state"

Item {
    id: root
    Process { id: vscodeProc }
    readonly property string settingsPath: "$HOME/.config/Code/User/settings.json"

    readonly property bool active: ShellState.templatesEnabled && ShellState.templateVSCode

    function apply() {
        if (!Colors.loaded || !root.active) return;
        var theme = Colors.activePalette.vscodeTheme
        var cmd
        if (theme !== undefined && theme !== "") {
            cmd = 'jq \'.["workbench.colorTheme"] = "' + theme + '" | .["workbench.colorCustomizations"] = {}\' "' + root.settingsPath + '" > /tmp/vscode-settings.tmp && mv /tmp/vscode-settings.tmp "' + root.settingsPath + '"'
        } else {
            var patch = {
                "editor.background": Colors.toHex(Colors.bg),
                "sideBar.background": Colors.toHex(Colors.bgsur),
                "activityBar.background": Colors.toHex(Colors.bgsur),
                "statusBar.background": Colors.toHex(Colors.bgsur),
                "titleBar.activeBackground": Colors.toHex(Colors.bgsur),
                "focusBorder": Colors.toHex(Colors.accent),
                "textLink.foreground": Colors.toHex(Colors.accent)
            }
            cmd = 'printf "%s" \'' + JSON.stringify(patch) + '\' | jq --slurpfile patch /dev/stdin \'.["workbench.colorCustomizations"] = ((.["workbench.colorCustomizations"] // {}) + $patch[0])\' "' + root.settingsPath + '" > /tmp/vscode-settings.tmp && mv /tmp/vscode-settings.tmp "' + root.settingsPath + '"'
        }
        vscodeProc.command = ["bash", "-c", cmd]
        vscodeProc.running = true
    }

    Connections {
        target: Colors
        function onActivePaletteChanged() { root.apply() }
    }

    onActiveChanged: root.apply()
}