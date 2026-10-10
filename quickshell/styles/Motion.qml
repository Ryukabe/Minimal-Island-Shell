// styles/Motion.qml — animation constants, derived live from Settings > Motion
//
// SpringAnimation ranges (Qt docs): spring 0–5, damping 0–1. Values outside
// those ranges make the animation unstable (items vanish), so every tier below
// stays inside them. Higher damping = settles with less bounce; the shared
// Bounce sliders lower it. The numbers are starting points — tune by feel.
pragma Singleton
import QtQuick
import "../services"

QtObject {
    id: motion

    // ============ SNAP tier ============
    // General small toggles (button press, row selection) elsewhere in the shell.
    readonly property real snapMs: ShellState.motionHoverMs
    readonly property real snapSpring: ShellState.springStiffnessFor(ShellState.motionHoverMs, 50, 400, 2.5, 4.5)
    readonly property real snapDamping: ShellState.springDampingFor(0.15, 0.6)
    readonly property real snapMass: 1.0

    // ============ HOVER tier ============
    // Passing pointer-over feedback — should feel light and immediate,
    // low bounce so it doesn't feel "sticky" as the pointer moves through.
    readonly property real hoverMs: ShellState.motionHoverMs * 0.7
    readonly property real hoverSpring: ShellState.springStiffnessFor(ShellState.motionHoverMs, 50, 400, 3.0, 4.5)
    readonly property real hoverDamping: ShellState.springDampingFor(0.25, 0.7)
    readonly property real hoverMass: 1.0

    // ============ SELECT tier ============
    // Deliberate selection state (keyboard focus, applied/chosen item) —
    // allowed more travel and more bounce than a hover, so it reads as a
    // heavier, more intentional confirmation.
    readonly property real selectMs: ShellState.motionHoverMs * 1.3
    readonly property real selectSpring: ShellState.springStiffnessFor(ShellState.motionHoverMs, 50, 400, 2.0, 4.0)
    readonly property real selectDamping: ShellState.springDampingFor(0.1, 0.5)
    readonly property real selectMass: 1.2

    // ============ GLIDE tier ============
    // Geometry morphs: panel resize, page swaps, card/list selection.
    // Kept subtle on purpose — it fires constantly.
    readonly property real glideMs: ShellState.motionMovementMs
    readonly property real glideSpring: ShellState.springStiffnessFor(ShellState.motionMovementMs, 100, 800, 1.5, 3.5)
    readonly property real glideDamping: ShellState.springDampingFor(0.12, 0.55)
    readonly property real glideMass: 1.0

    // ============ EXPRESSIVE tier ============
    // Rare, playful moments (page pop-in, Control Center tile reflow/resize/drop,
    // pager snap). Livelier than glide, with its OWN bounce amount
    // (ShellState.motionExpressiveBouncePercent). expressiveMs is the non-spring fallback.
    readonly property real expressiveMs: ShellState.motionMovementMs * 0.5
    readonly property real expressiveSpring: ShellState.springStiffnessFor(ShellState.motionMovementMs, 100, 800, 2.0, 4.0)
    readonly property real expressiveDamping: ShellState.springDampingFor(0.08, 0.4, ShellState.motionExpressiveBouncePercent)
    readonly property real expressiveMass: 1.0

    // ============ MORPH (island container) ============
    // Real spring physics for the island's width/height (MorphSpring.qml). Unlike the
    // SpringAnimation tiers above, these are true SwiftUI-style values: settle time in
    // seconds and bounce 0-0.5. Both follow the Settings > Motion sliders.
    readonly property real morphDuration: Math.max(0.2, ShellState.motionMovementMs / 1000)
    readonly property real morphBounce: Math.max(0, Math.min(0.5, ShellState.motionBouncePercent / 100))

    // Rest threshold in the animated property's own units:
    // epsilon for pixel values (x/y/width/height), scaleEpsilon for scale (~0.9–1.1).
    // Using epsilon on a scale spring makes it finish instantly.
    readonly property real epsilon: 0.25
    readonly property real scaleEpsilon: 0.001

    // ============ LAYERED TIMING ============
    // The container (island) leads; incoming page content starts this long after it
    // (Apple-style ~60–100 ms stagger). Scales with the Movement slider but is clamped
    // to 40–100 ms so a slow setting never makes content feel late. Pass through
    // ShellState.motionDuration() at the call site so Reduce Motion collapses it to 0.
    readonly property real contentDelayMs: Math.max(40, Math.min(100, ShellState.motionMovementMs * 0.2))

    // ============ FADES tier ============
    // Opacity & color only — never springs (clamped 0-1, overshoot clips).
    readonly property real fadeMs: ShellState.motionFadeMs
}