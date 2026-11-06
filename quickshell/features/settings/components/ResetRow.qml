// components/ResetRow.qml — "Reset <menu>" row for the bottom of a menu's main page only.
// First tap arms it ("Confirm"), second tap resets. It disarms itself after a few seconds.
// `keys` are ShellState keys covering the whole menu, sub-pages included; every one must exist
// in ShellState.defaults. Use onResetDone for anything outside ShellState (layout services).
import QtQuick
import "../core"

ButtonRow {
    id: root

    property var keys: []
    property string menuName: ""
    property bool armed: false
    signal resetDone()

    label: "Reset " + (root.menuName !== "" ? root.menuName : "this menu")
    description: root.armed
        ? "Tap again to confirm. Every option in this menu, including its sub-pages, goes back to its default"
        : "Put every option in this menu, including its sub-pages, back to its default"
    buttonText: root.armed ? "Confirm" : "Reset"
    showDivider: false

    onClicked: {
        if (!root.armed) {
            root.armed = true
            root._disarmTimer.restart()
            return
        }
        root._disarmTimer.stop()
        root.armed = false
        SettingsStore.resetKeys(root.keys)
        root.resetDone()
    }

    property Timer _disarmTimer: Timer {
        interval: 4000
        repeat: false
        onTriggered: root.armed = false
    }
}