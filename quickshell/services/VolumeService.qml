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

    // ---- Per-app mixer: playback streams only (Spotify, Firefox, ...) ----
    readonly property var appStreams: Pipewire.nodes.values.filter(
        n => n.isStream && !n.isSink
    )

    // ---- Output devices: real sinks (speakers, headphones, HDMI), not app streams ----
    readonly property var outputSinks: Pipewire.nodes.values.filter(
        n => n.isSink && !n.isStream
    )

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    // Streams must be bound before their audio.volume / audio.muted are usable
    PwObjectTracker {
        objects: root.appStreams
    }

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
        // deliberately no flashPage here — called from slider drags,
        // which should stay on the control page
    }

    // ---- Per-app helpers (no flashPage: driven from the subview) ----
    function appName(node) {
        if (!node) return ""
        const p = node.properties
        return p["application.name"] || p["node.description"] || node.description || node.name
    }

    function appPercent(node) {
        return (node && node.audio) ? Math.round(node.audio.volume * 100) : 0
    }

    function appMuted(node) {
        return (node && node.audio) ? node.audio.muted : false
    }

    function setAppPercent(node, pct) {
        if (!node || !node.audio) return
        node.audio.volume = Math.max(0, Math.min(100, pct)) / 100
    }

    function toggleAppMute(node) {
        if (!node || !node.audio) return
        node.audio.muted = !node.audio.muted
    }

    // ---- Output device helpers ----
    function sinkLabel(node) {
        if (!node) return ""
        return node.nickname || node.description || node.name
    }

    function isDefaultSink(node) {
        return !!(sink && node && sink.id === node.id)
    }

    function setDefaultSink(node) {
        if (!node) return
        Pipewire.preferredDefaultAudioSink = node
    }

    IpcHandler {
        target: "volume"
        function increase() { root.increase() }
        function decrease() { root.decrease() }
        function toggle() { root.toggleMute() }
    }
}