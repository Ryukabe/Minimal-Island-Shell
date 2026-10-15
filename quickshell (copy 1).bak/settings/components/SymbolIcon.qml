// components/SymbolIcon.qml — one Material Symbols glyph, optionally animated.
// Uses Fonts.iconAxes so it follows the icon weight / fill chosen in Typography.
//
// Animation is OFF by default, so every existing icon looks exactly as before. Turn it on with
//   animated: true
// then tell the icon when to play:
//   hovered: <mouse area>.containsMouse     plays when it turns true
//   activated: root.selected                plays when it turns true (e.g. sidebar item gets selected)
//   playOnLoad: true                        plays when the icon appears or its name changes (headings)
// Each icon name has its own motion (see _effects). Unknown names fall back to "pop".
// Every duration goes through ShellState.motionDuration, so the Motion page speed sliders apply
// and Reduce motion turns the icons completely still.
import QtQuick
import "../../styles"
import "../../services"

Text {
    id: root

    property string name: ""
    property real size: Dimens.fontSizeLg

    property bool animated: false
    property bool hovered: false
    property bool activated: false
    property bool playOnLoad: false

    // Which motion this icon uses. Override per instance with e.g. effect: "spin".
    property string effect: root._effects[root.name] || "pop"

    readonly property var _effects: ({
        "settings": "spin",
        "dock_to_bottom": "press",
        "rocket_launch": "lift",
        "widgets": "pop",
        "lock": "wiggle",
        "wifi": "fade",
        "graphic_eq": "stretch",
        "desktop_windows": "pop",
        "mouse": "wiggle",
        "keyboard": "press",
        "palette": "spin",
        "wallpaper": "pop",
        "format_paint": "swing",
        "text_fields": "pop",
        "speed": "sweep",
        "opacity": "fade",
        "invert_colors": "flip",
        "apps": "pop",
        "app_registration": "pop",
        "grid_view": "pop",
        "notifications": "swing",
        "language": "spin",
        "tune": "slide",
        "info": "pop",
        "chevron_right": "nudge",
        "arrow_back": "nudgeback"
    })

    text: root.name
    color: Colors.fg
    font.family: Fonts.icon
    font.variableAxes: Fonts.iconAxes
    font.pixelSize: root.size
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    // Bells hang from the top; everything else turns around its centre.
    transformOrigin: root.effect === "swing" ? Item.Top : Item.Center

    // squash: used by "stretch" (grows up from the baseline) and "flip" (turns like a coin).
    // shift: used by "lift", "press", "slide" and "nudge".
    transform: [
        Scale { id: squash; origin.x: root.width / 2; origin.y: root.height; xScale: 1; yScale: 1 },
        Translate { id: shift; x: 0; y: 0 }
    ]

    // --- Motion page hooks (ShellState names to add when wiring the settings) ---
    //   motionIconsEnabled        bool, default true    "Animated icons" switch
    //   motionIconSpeedPercent    50..200, default 100  100 = the built-in feel, 200 = twice as fast
    //   motionIconBouncePercent   0..100, default 50    how far settles overshoot; 0 = none
    // Until those exist the `!== undefined` fallbacks below give the defaults.
    readonly property real _speed: Math.max(0.1, (ShellState.motionIconSpeedPercent !== undefined ? ShellState.motionIconSpeedPercent : 100) / 100)
    readonly property real _bounce: ShellState.motionIconBouncePercent !== undefined ? ShellState.motionIconBouncePercent : 50
    readonly property real _overshoot: 1.70158 * root._bounce / 50

    // Total length of one play; 0 (= no animation) when Reduce motion is on or the
    // "Animated icons" switch on the Motion page is off. `!== false` keeps icons animated
    // until that setting exists in ShellState.
    readonly property int _d: ShellState.motionIconsEnabled !== false
        ? Math.round(ShellState.motionDuration(450) / Math.max(0.25, root._speed)) : 0
    property var _current: null
    property real _baseOpacity: 1

    function _s(f) { return Math.max(1, Math.round(root._d * f)) }

    function play() {
        if (!root.animated || root._d <= 0) return
        if (root._current && root._current.running) return

        const byName = {
            spin: spinAnim, wiggle: wiggleAnim, swing: swingAnim, pop: popAnim, fade: fadeAnim,
            lift: liftAnim, press: pressAnim, slide: slideAnim, stretch: stretchAnim,
            flip: flipAnim, sweep: sweepAnim, nudge: nudgeAnim, nudgeback: nudgeBackAnim
        }
        root._baseOpacity = root.opacity
        root._current = byName[root.effect] || popAnim
        root._current.restart()
    }

    onHoveredChanged: if (root.hovered) root.play()
    onActivatedChanged: if (root.activated) root.play()
    onNameChanged: if (root.playOnLoad) loadTimer.restart()
    Component.onCompleted: if (root.playOnLoad) loadTimer.restart()

    // Small delay so a heading icon plays after the page has actually appeared.
    Timer {
        id: loadTimer
        interval: 80
        onTriggered: root.play()
    }

    // ---------- motions ----------

    // Gear / globe / palette: one full turn.
    SequentialAnimation {
        id: spinAnim
        NumberAnimation { target: root; property: "rotation"; from: 0; to: 360; duration: root._s(1.3); easing.type: Easing.OutCubic }
        ScriptAction { script: root.rotation = 0 }
    }

    // Lock / mouse: quick shake that settles.
    SequentialAnimation {
        id: wiggleAnim
        NumberAnimation { target: root; property: "rotation"; to: -14; duration: root._s(0.18); easing.type: Easing.OutQuad }
        NumberAnimation { target: root; property: "rotation"; to: 11; duration: root._s(0.2); easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "rotation"; to: -6; duration: root._s(0.2); easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "rotation"; to: 3; duration: root._s(0.2); easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "rotation"; to: 0; duration: root._s(0.22); easing.type: Easing.OutQuad }
    }

    // Bell / paint roller: wider swing from the top.
    SequentialAnimation {
        id: swingAnim
        NumberAnimation { target: root; property: "rotation"; to: 20; duration: root._s(0.2); easing.type: Easing.OutQuad }
        NumberAnimation { target: root; property: "rotation"; to: -15; duration: root._s(0.22); easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "rotation"; to: 9; duration: root._s(0.2); easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "rotation"; to: -4; duration: root._s(0.18); easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "rotation"; to: 0; duration: root._s(0.2); easing.type: Easing.OutQuad }
    }

    // Generic: grow, dip, settle.
    SequentialAnimation {
        id: popAnim
        NumberAnimation { target: root; property: "scale"; to: 1.28; duration: root._s(0.35); easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "scale"; to: 0.94; duration: root._s(0.3); easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "scale"; to: 1; duration: root._s(0.35); easing.type: Easing.OutBack; easing.overshoot: root._overshoot }
    }

    // Wi-Fi / opacity: pulse of brightness.
    SequentialAnimation {
        id: fadeAnim
        NumberAnimation { target: root; property: "opacity"; to: 0.3; duration: root._s(0.4); easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "opacity"; to: root._baseOpacity; duration: root._s(0.6); easing.type: Easing.InOutQuad }
    }

    // Rocket: lifts off up and to the right, then settles back.
    SequentialAnimation {
        id: liftAnim
        ParallelAnimation {
            NumberAnimation { target: shift; property: "x"; to: 3; duration: root._s(0.45); easing.type: Easing.OutCubic }
            NumberAnimation { target: shift; property: "y"; to: -3; duration: root._s(0.45); easing.type: Easing.OutCubic }
        }
        ParallelAnimation {
            NumberAnimation { target: shift; property: "x"; to: 0; duration: root._s(0.55); easing.type: Easing.InOutQuad }
            NumberAnimation { target: shift; property: "y"; to: 0; duration: root._s(0.55); easing.type: Easing.InOutQuad }
        }
    }

    // Dock / keyboard: pressed down, springs back.
    SequentialAnimation {
        id: pressAnim
        NumberAnimation { target: shift; property: "y"; to: 2.5; duration: root._s(0.3); easing.type: Easing.OutQuad }
        NumberAnimation { target: shift; property: "y"; to: 0; duration: root._s(0.7); easing.type: Easing.OutBack; easing.overshoot: root._overshoot }
    }

    // Tune: sliders knob left, right, home.
    SequentialAnimation {
        id: slideAnim
        NumberAnimation { target: shift; property: "x"; to: -3; duration: root._s(0.25); easing.type: Easing.OutQuad }
        NumberAnimation { target: shift; property: "x"; to: 3; duration: root._s(0.35); easing.type: Easing.InOutQuad }
        NumberAnimation { target: shift; property: "x"; to: 0; duration: root._s(0.4); easing.type: Easing.OutBack; easing.overshoot: root._overshoot }
    }

    // Sound: the bars shoot up from the baseline and settle.
    SequentialAnimation {
        id: stretchAnim
        NumberAnimation { target: squash; property: "yScale"; to: 1.4; duration: root._s(0.35); easing.type: Easing.OutCubic }
        NumberAnimation { target: squash; property: "yScale"; to: 0.85; duration: root._s(0.3); easing.type: Easing.InOutQuad }
        NumberAnimation { target: squash; property: "yScale"; to: 1; duration: root._s(0.35); easing.type: Easing.OutBack; easing.overshoot: root._overshoot }
    }

    // Colors: turns edge-on like a coin and back.
    SequentialAnimation {
        id: flipAnim
        NumberAnimation { target: squash; property: "xScale"; to: 0; duration: root._s(0.4); easing.type: Easing.InQuad }
        NumberAnimation { target: squash; property: "xScale"; to: 1; duration: root._s(0.6); easing.type: Easing.OutBack; easing.overshoot: root._overshoot }
    }

    // Speed: gauge needle sweeps one way, the other, and home.
    SequentialAnimation {
        id: sweepAnim
        NumberAnimation { target: root; property: "rotation"; to: -28; duration: root._s(0.3); easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "rotation"; to: 28; duration: root._s(0.4); easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "rotation"; to: 0; duration: root._s(0.3); easing.type: Easing.OutBack; easing.overshoot: root._overshoot }
    }

    // Back arrow: small push to the left.
    SequentialAnimation {
        id: nudgeBackAnim
        NumberAnimation { target: shift; property: "x"; to: -4; duration: root._s(0.35); easing.type: Easing.OutCubic }
        NumberAnimation { target: shift; property: "x"; to: 0; duration: root._s(0.65); easing.type: Easing.OutBack; easing.overshoot: root._overshoot }
    }

    // Chevron: small push to the right.
    SequentialAnimation {
        id: nudgeAnim
        NumberAnimation { target: shift; property: "x"; to: 4; duration: root._s(0.35); easing.type: Easing.OutCubic }
        NumberAnimation { target: shift; property: "x"; to: 0; duration: root._s(0.65); easing.type: Easing.OutBack; easing.overshoot: root._overshoot }
    }
}
