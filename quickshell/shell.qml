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
    LockScreen { id: lockScreen }

    IpcHandler {
        target: "lock"
        function lock() { ShellState.showPage("lock") }
        function unlock() { if (ShellState.activePage === "lock") lockScreen.unlock() }
        function toggle() { ShellState.activePage === "lock" ? lockScreen.unlock() : ShellState.showPage("lock") }
    }
}