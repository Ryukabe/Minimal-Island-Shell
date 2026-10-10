// components/common/MorphSpring.qml
// Velocity-carrying spring for one number. Retargeting mid-flight keeps the current
// speed, so a reversed morph curves smoothly instead of restarting from rest.
// Duration/bounce use the SwiftUI model: stiffness = (2π/duration)², damping = 4π(1-bounce)/duration.
import QtQuick

Item {
    id: root

    property real target: 0
    // Starts equal to target (so nothing animates at creation); snap() below makes it independent.
    property real value: target
    property real velocity: 0

    property real duration: 0.4   // seconds
    property real bounce: 0.15    // 0 = no overshoot, ~0.15-0.3 = Apple-like
    property bool active: true    // false = follow target instantly (Reduce Motion / spring off)

    // Rest thresholds (in the animated value's units, i.e. pixels) and solver step size.
    property real restDelta: 0.05
    property real maxStep: 1 / 120

    readonly property real _duration: Math.max(0.05, duration)
    readonly property real _omega: 2 * Math.PI / _duration
    readonly property real stiffness: _omega * _omega
    readonly property real damping: 4 * Math.PI * (1 - Math.max(0, Math.min(0.9, bounce))) / _duration

    function snap() {
        value = target
        velocity = 0
    }

    onTargetChanged: if (!active) snap()
    onActiveChanged: if (!active) snap()
    Component.onCompleted: snap()

    FrameAnimation {
        running: root.active
            && (Math.abs(root.target - root.value) > root.restDelta
                || Math.abs(root.velocity) > root.restDelta)

        onTriggered: {
            var remaining = Math.min(frameTime, 1 / 30)
            var v = root.velocity
            var x = root.value
            while (remaining > 0) {
                var h = Math.min(remaining, root.maxStep)
                var a = -root.stiffness * (x - root.target) - root.damping * v
                v += a * h
                x += v * h
                remaining -= h
            }
            root.velocity = v
            root.value = x
        }

        onRunningChanged: if (!running) root.snap()
    }
}