// styles/Motion.qml — animation constants, derived live from Settings > Motion
pragma Singleton
import QtQuick
import "../services"

QtObject {
    id: motion

    // ============ SNAP tier ============
    // General small toggles (button press, row selection) elsewhere in the shell.
    readonly property real snapMs: ShellState.motionHoverMs
    readonly property real snapSpring: ShellState.springStiffnessFor(ShellState.motionHoverMs, 50, 400, 250, 550)
    readonly property real snapDamping: ShellState.springDampingFor(18, 45)
    readonly property real snapMass: 1.0

    // ============ HOVER tier ============
    // Passing pointer-over feedback — should feel light and immediate,
    // low bounce so it doesn't feel "sticky" as the pointer moves through.
    readonly property real hoverMs: ShellState.motionHoverMs * 0.7
    readonly property real hoverSpring: ShellState.springStiffnessFor(ShellState.motionHoverMs, 50, 400, 300, 600)
    readonly property real hoverDamping: ShellState.springDampingFor(30, 55)
    readonly property real hoverMass: 0.8

    // ============ SELECT tier ============
    // Deliberate selection state (keyboard focus, applied/chosen item) —
    // allowed more travel and more bounce than a hover, so it reads as a
    // heavier, more intentional confirmation.
    readonly property real selectMs: ShellState.motionHoverMs * 1.3
    readonly property real selectSpring: ShellState.springStiffnessFor(ShellState.motionHoverMs, 50, 400, 200, 450)
    readonly property real selectDamping: ShellState.springDampingFor(12, 38)
    readonly property real selectMass: 1.2

    // ============ GLIDE tier ============
    // Geometry morphs: panel resize, page swaps, card/list selection.
    readonly property real glideMs: ShellState.motionMovementMs
    readonly property real glideSpring: ShellState.springStiffnessFor(ShellState.motionMovementMs, 100, 800, 150, 400)
    readonly property real glideDamping: ShellState.springDampingFor(22, 50)
    readonly property real glideMass: 1.4

    readonly property real epsilon: 0.25

    // ============ FADES tier ============
    // Opacity & color only — never springs (clamped 0-1, overshoot clips).
    readonly property real fadeMs: ShellState.motionFadeMs
}