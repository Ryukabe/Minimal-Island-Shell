pragma Singleton
import QtQuick
import Quickshell.Io
import ".."

Item {
    id: root
    Process { id: kittyProc }

    Connections {
        target: Colors
        function onActivePaletteChanged() {
            if (!Colors.loaded) return;
            kittyProc.command = [
                "kitty", "@", "--to", "unix:/tmp/kitty-theme-socket", "set-colors", "-a",
                "background=" + Colors.toHex(Colors.bg),
                "foreground=" + Colors.toHex(Colors.fg),
                "cursor=" + Colors.toHex(Colors.accent),
                "selection_background=" + Colors.toHex(Colors.accent),
                "selection_foreground=" + Colors.toHex(Colors.bg),
                "color0=" + Colors.toHex(Colors.black),
                "color1=" + Colors.toHex(Colors.red),
                "color2=" + Colors.toHex(Colors.green),
                "color3=" + Colors.toHex(Colors.yellow),
                "color4=" + Colors.toHex(Colors.blue),
                "color5=" + Colors.toHex(Colors.purple),
                "color6=" + Colors.toHex(Colors.cyan),
                "color7=" + Colors.toHex(Colors.fgMuted),
                "color8=" + Colors.toHex(Colors.brightBlack),
                "color9=" + Colors.toHex(Colors.brightRed),
                "color10=" + Colors.toHex(Colors.brightGreen),
                "color11=" + Colors.toHex(Colors.brightYellow),
                "color12=" + Colors.toHex(Colors.brightBlue),
                "color13=" + Colors.toHex(Colors.brightPurple),
                "color14=" + Colors.toHex(Colors.brightCyan),
                "color15=" + Colors.toHex(Colors.brightWhite)
            ]
            kittyProc.running = true
        }
    }
}
