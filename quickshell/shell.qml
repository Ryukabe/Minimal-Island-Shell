// shell.qml
import QtQuick
import Quickshell
import Quickshell.Io
import "core/shell"
import "features/lockscreen"
import "features/settings"

ShellRoot {
    Island {}
    SettingsApp {}
    LockScreen {}

    IpcHandler {
        target: "lock"
        function lock() { ShellState.showPage("lock") }
        function unlock() { if (ShellState.activePage === "lock") ShellState.showPage("clock") }
        function toggle() { ShellState.activePage === "lock" ? ShellState.showPage("clock") : ShellState.showPage("lock") }
    }
}