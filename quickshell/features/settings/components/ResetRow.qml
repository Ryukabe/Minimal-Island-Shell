// components/ResetRow.qml — "Reset this page" row for the bottom of a settings page.
// First tap arms it ("Confirm"), second tap resets. It disarms itself after a few seconds.
// `keys` are ShellState keys; every one must exist in ShellState.defaults.
import QtQuick
import "../core"

ButtonRow {
    id: root

    property var keys: []
    property bool armed: false

    label: "Reset this page"
    description: root.armed
        ? "Tap again to confirm. Every option on this page goes back to its default"
        : "Put every option on this page back to its default"
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
    }

    property Timer _disarmTimer: Timer {
        interval: 4000
        repeat: false
        onTriggered: root.armed = false
    }
}