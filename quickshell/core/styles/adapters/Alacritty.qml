pragma Singleton
import QtQuick
import Quickshell.Io
import ".."
import "../../shell"

Item {
    id: root
    readonly property string path: "$HOME/.config/alacritty/hermit-colors.toml"
    readonly property bool active: ShellState.templatesEnabled && ShellState.templateAlacritty
    Process { id: proc }

    function buildToml() {
        function c(v) { return '"' + Colors.toHex(v) + '"' }
        return "[colors.primary]\nbackground = " + c(Colors.bg) + "\nforeground = " + c(Colors.fg) + "\n\n" +
               "[colors.cursor]\ntext = " + c(Colors.bg) + "\ncursor = " + c(Colors.accent) + "\n\n" +
               "[colors.selection]\ntext = " + c(Colors.bg) + "\nbackground = " + c(Colors.accent) + "\n\n" +
               "[colors.normal]\nblack = " + c(Colors.black) + "\nred = " + c(Colors.red) + "\ngreen = " + c(Colors.green) +
               "\nyellow = " + c(Colors.yellow) + "\nblue = " + c(Colors.blue) + "\nmagenta = " + c(Colors.purple) +
               "\ncyan = " + c(Colors.cyan) + "\nwhite = " + c(Colors.fgMuted) + "\n\n" +
               "[colors.bright]\nblack = " + c(Colors.brightBlack) + "\nred = " + c(Colors.brightRed) + "\ngreen = " + c(Colors.brightGreen) +
               "\nyellow = " + c(Colors.brightYellow) + "\nblue = " + c(Colors.brightBlue) + "\nmagenta = " + c(Colors.brightPurple) +
               "\ncyan = " + c(Colors.brightCyan) + "\nwhite = " + c(Colors.brightWhite) + "\n"
    }

    function apply() {
        if (!Colors.loaded || !root.active) return;
        proc.command = ["bash", "-c",
            'mkdir -p "$HOME/.config/alacritty" && printf "%s" \'' + root.buildToml() + '\' > /tmp/alacritty-theme.tmp && mv /tmp/alacritty-theme.tmp "' + root.path + '"']
        proc.running = true
    }

    Connections { target: Colors; function onActivePaletteChanged() { root.apply() } }
    onActiveChanged: root.apply()
}