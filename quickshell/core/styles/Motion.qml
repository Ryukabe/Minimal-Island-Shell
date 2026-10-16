// styles/Motion.qml — animation constants, derived live from Settings > Motion
//
// SpringAnimation ranges (Qt docs): spring 0–5, damping 0–1. Values outside
// those ranges make the animation unstable (items vanish), so every tier below
// stays inside them. Higher damping = settles with less bounce; the shared
// Bounce sliders lower it. The numbers are starting points — tune by feel.
pragma Singleton
import QtQuick
import "../shell"

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
    // Rare, playful moments (island page pop-in, Control Center tile reflow/resize/drop,
    // pager snap). Livelier than glide, with its OWN bounce amount
    // (ShellState.motionExpressiveBouncePercent). expressiveMs is the non-spring fallback.
    readonly property real expressiveMs: ShellState.motionMovementMs * 0.5
    readonly property real expressiveSpring: ShellState.springStiffnessFor(ShellState.motionMovementMs, 100, 800, 2.0, 4.0)
    readonly property real expressiveDamping: ShellState.springDampingFor(0.08, 0.4, ShellState.motionExpressiveBouncePercent)
    readonly property real expressiveMass: 1.0

    // ============ MORPH (island container) ============
    // Real spring physics for the island's width/height (MorphSpring.qml). Unlike the
    // SpringAnimation tiers above, these are true SwiftUI-style values: spring period in
    // seconds and bounce 0-1. The spring is ~90% of the way after ~0.6x its duration, so
    // the island morph runs at 70% of the Movement slider (floor 150 ms) to feel brisk.
    // Bounce follows the Settings > Motion Bounce slider 1:1 (20 % = 0.2) up to 0.8, which is
    // already very wobbly; the slider is not dead above 50 % any more.
    readonly property real morphDuration: Math.max(0.15, ShellState.motionMovementMs / 1000 * 0.7)
    readonly property real morphBounce: Math.max(0, Math.min(0.8, ShellState.motionBouncePercent / 100))

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

    // ============ PRESETS ============
    // Each preset sets the three spring sliders and the two icon sliders together, and turns
    // spring physics on. Fade and hover timing and the "Animated icons" switch are left alone.
    // Balanced equals the shipped slider defaults. Settings > Motion highlights a preset only
    // while every one of its sliders still matches exactly.
    readonly property var presets: [
        { name: "Calm", description: "Slow and soft, barely any bounce",
          movementMs: 620, bouncePercent: 8, expressiveBouncePercent: 20,
          iconSpeedPercent: 80, iconBouncePercent: 15 },
        { name: "Balanced", description: "The default feel",
          movementMs: 480, bouncePercent: 20, expressiveBouncePercent: 45,
          iconSpeedPercent: 100, iconBouncePercent: 50 },
        { name: "Lively", description: "Quick, with visible overshoot",
          movementMs: 440, bouncePercent: 38, expressiveBouncePercent: 70,
          iconSpeedPercent: 120, iconBouncePercent: 75 },
        { name: "Snappy", description: "Fast and tight, little bounce",
          movementMs: 280, bouncePercent: 12, expressiveBouncePercent: 30,
          iconSpeedPercent: 140, iconBouncePercent: 25 }
    ]

    readonly property string activePreset: {
        if (!ShellState.motionSpringEnabled) return ""
        for (var i = 0; i < motion.presets.length; i++) {
            var p = motion.presets[i]
            if (ShellState.motionMovementMs === p.movementMs
                    && ShellState.motionBouncePercent === p.bouncePercent
                    && ShellState.motionExpressiveBouncePercent === p.expressiveBouncePercent
                    && ShellState.motionIconSpeedPercent === p.iconSpeedPercent
                    && ShellState.motionIconBouncePercent === p.iconBouncePercent)
                return p.name
        }
        return ""
    }

    function applyPreset(name) {
        for (var i = 0; i < motion.presets.length; i++) {
            var p = motion.presets[i]
            if (p.name !== name) continue
            ShellState.motionSpringEnabled = true
            ShellState.motionMovementMs = p.movementMs
            ShellState.motionBouncePercent = p.bouncePercent
            ShellState.motionExpressiveBouncePercent = p.expressiveBouncePercent
            ShellState.motionIconSpeedPercent = p.iconSpeedPercent
            ShellState.motionIconBouncePercent = p.iconBouncePercent
            return
        }
    }
}