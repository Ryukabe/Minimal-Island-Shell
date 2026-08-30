pragma Singleton
import QtQuick
import "../services"

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