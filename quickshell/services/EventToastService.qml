// services/EventToastService.qml — short island toasts for system events
// (Do Not Disturb, charger, audio output / input). Needs a qmldir "singleton" entry.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import "../services"

Singleton {
    id: root

    property string title: ""
    property string icon: ""

    // Events fired while the shell is still starting up (default devices being detected etc.)
    // must not toast.
    readonly property int warmupMs: 3000
    property bool _ready: false

    Timer {
        running: true
        interval: root.warmupMs
        repeat: false
        onTriggered: root._ready = true
    }

    function show(iconName, text) {
        root.icon = iconName
        root.title = text
        ShellState.flashPageFor("eventtoast", ShellState.eventToastMs)
    }

    function _label(node) {
        if (!node) return ""
        return node.nickname || node.description || node.name
    }

    // ---- Do Not Disturb ----
    Connections {
        target: ShellState
        function onFocusModeEnabledChanged() {
            if (!root._ready || !ShellState.eventToastDnd) return
            if (ShellState.focusModeEnabled)
                root.show("do_not_disturb_on", ShellState.activeFocusMode + " on")
            else
                root.show("notifications", "Notifications back on")
        }
    }

    // ---- Charger ----
    Connections {
        target: UPower
        function onOnBatteryChanged() {
            if (!root._ready || !ShellState.eventToastCharging) return
            if (UPower.onBattery)
                root.show("power_off", "Unplugged")
            else
                root.show("bolt", "Charging")
        }
    }

    // ---- Audio devices ----
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    onSinkChanged: {
        if (!root._ready || !root.sink || !ShellState.eventToastAudioOutput) return
        root.show("speaker", "Output: " + root._label(root.sink))
    }

    onSourceChanged: {
        if (!root._ready || !root.source || !ShellState.eventToastAudioInput) return
        root.show("mic", "Input: " + root._label(root.source))
    }
}