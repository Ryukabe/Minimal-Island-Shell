pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../services"

Singleton {
    id: root
    readonly property int step: 5
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property int percent: sink ? Math.round(sink.audio.volume * 100) : 0
    readonly property bool muted: sink ? sink.audio.muted : false

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    // no more blanket onPercentChanged/onMutedChanged watchers —
    // flashPage is now only called explicitly from the keyboard-driven
    // functions below, so slider drags (setPercent) don't hijack the island

    function _setVolume(pct) {
        if (!sink) return
        const clamped = Math.max(0, Math.min(100, pct))
        sink.audio.volume = clamped / 100
    }

    function increase() {
        if (root.muted) {
            toggleMute()
        } else {
            _setVolume(root.percent + root.step)
        }
        ShellState.flashPage("volume")
    }

    function decrease() {
        if (root.muted) {
            toggleMute()
        } else {
            _setVolume(root.percent - root.step)
        }
        ShellState.flashPage("volume")
    }

    function toggleMute() {
        if (!sink) return
        sink.audio.muted = !sink.audio.muted
        ShellState.flashPage("volume")
    }

    function setPercent(pct) {
        _setVolume(pct)
        // deliberately no flashPage here — this is called from the
        // Control Center slider drag, which should stay on the control page
    }

    IpcHandler {
        target: "volume"
        function increase() { root.increase() }
        function decrease() { root.decrease() }
        function toggle() { root.toggleMute() }
    }
}