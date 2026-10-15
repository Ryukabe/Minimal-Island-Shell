pragma Singleton
import QtQuick
import "../services"
import "../core/state"

QtObject {
    id: root

    property int secondsRemaining: 0
    property int initialSeconds: 0
    property bool running: false

    property Timer ticker: Timer {
        interval: 1000
        repeat: true
        running: root.running
        onTriggered: {
            if (root.secondsRemaining > 0) {
                root.secondsRemaining--
            } else {
                root.running = false
                ShellState.flashPageFor("timertoast", 3000)
            }
        }
    }

    function start(seconds) {
        if (seconds <= 0) return
        initialSeconds = seconds
        secondsRemaining = seconds
        running = true
    }

    function togglePause() {
        if (secondsRemaining > 0) {
            running = !running
        }
    }

    // Start over from the length the timer was last started (or adjusted) with.
    function restart() {
        if (initialSeconds > 0) start(initialSeconds)
    }

    // +/- buttons. Keeps a paused timer paused (start() would resume it).
    // An idle timer with a positive delta starts, like the old +5m button did.
    function adjust(deltaSeconds) {
        var idle = secondsRemaining <= 0
        var next = Math.max(0, secondsRemaining + deltaSeconds)
        if (next === 0) {
            reset()
            return
        }
        initialSeconds = next
        secondsRemaining = next
        if (idle) running = true
    }

    function reset() {
        running = false
        secondsRemaining = 0
        initialSeconds = 0
    }

    function formatTime(totalSecs) {
        var m = Math.floor(totalSecs / 60)
        var s = totalSecs % 60
        return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
    }
}