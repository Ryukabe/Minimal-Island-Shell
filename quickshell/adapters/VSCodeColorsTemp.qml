pragma Singleton
import QtQuick
import Quickshell.Io
import "../styles"

Item {
    id: root
    Process { id: vscodeProc }
    readonly property string settingsPath: "$HOME/.config/Code/User/settings.json"

    Connections {
        target: Colors
        function onActivePaletteChanged() {
            if (!Colors.loaded) return;
            var theme = Colors.activePalette.vscodeTheme
            var cmd
            if (theme !== undefined && theme !== "") {
                cmd = 'jq \'.["workbench.colorTheme"] = "' + theme + '" | .["workbench.colorCustomizations"] = {}\' "' + root.settingsPath + '" > /tmp/vscode-settings.tmp && mv /tmp/vscode-settings.tmp "' + root.settingsPath + '"'
            } else {
                var patch = {
                    "editor.background": Colors.toHex(Colors.bg),
                    "sideBar.background": Colors.toHex(Colors.bgSurface),
                    "activityBar.background": Colors.toHex(Colors.bgSurface),
                    "statusBar.background": Colors.toHex(Colors.bgSurface),
                    "titleBar.activeBackground": Colors.toHex(Colors.bgSurface),
                    "focusBorder": Colors.toHex(Colors.accent),
                    "textLink.foreground": Colors.toHex(Colors.accent)
                }
                cmd = 'printf "%s" \'' + JSON.stringify(patch) + '\' | jq --slurpfile patch /dev/stdin \'.["workbench.colorCustomizations"] = ((.["workbench.colorCustomizations"] // {}) + $patch[0])\' "' + root.settingsPath + '" > /tmp/vscode-settings.tmp && mv /tmp/vscode-settings.tmp "' + root.settingsPath + '"'
            }
            vscodeProc.command = ["bash", "-c", cmd]
            vscodeProc.running = true
        }
    }
}
