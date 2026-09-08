// settings/keybinds/KeyCaptureField.qml — live key-press capture for rebinding.
// Capture only ever starts via an explicit activate() call (a real click),
// never as a side effect of gaining active focus. This prevents the field
// from "eating" keystrokes the moment it becomes visible/focused for any
// reason other than the user deliberately clicking it.
//
// Pressing a combo stages it (shown in accent color) without saving; keep
// pressing to overwrite the staged combo. Escape always cancels and discards
// whatever was staged. Actual commit happens only via KeybindRow's Save
// button. Mouse-button binds aren't capturable this way.
//
// While armed, Hyprland is switched into the "capture" submap (declared
// statically in binds.lua via hl.define_submap, with a safety-valve
// Escape -> reset bind inside it). While that submap is active, NO bind
// outside it can fire — including the one currently being rebound — so
// pressing a combo that's already in use here won't also trigger its old
// action. deactivateAndClear() is the single source of truth for leaving
// capture mode and wiping staged input; callers (KeybindRow, Keybinds)
// should use activate()/deactivateAndClear() rather than poking
// enterCapture()/exitCapture() directly.
import QtQuick
import Quickshell.Io
import "../../styles"

Rectangle {
    id: root

    property string resultCombo: ""
    property bool armed: false

    signal comboChanged(string combo)
    signal cancelled()

    implicitWidth: 200
    implicitHeight: 28
    radius: Dimens.radiusSmall
    color: Colors.subBgMica
    border.color: root.armed ? Colors.accent : Colors.border
    border.width: 1

    property var _heldMods: []
    property bool _inCaptureMode: false

    function reset() {
        root.resultCombo = ""
        root._heldMods = []
    }

    // Public — the ONLY entry point that should start capture. Call this
    // from an explicit user action (a click), never from a focus handler.
    function activate() {
        root.armed = true
        root.enterCapture()
        root.forceActiveFocus()
    }

    // Public — disarms capture AND wipes any staged combo in one call.
    // Use this for Cancel / close-without-saving paths.
    function deactivateAndClear() {
        root.armed = false
        root.exitCapture()
        root.reset()
    }

    Process {
        id: submapProc
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    console.log("[KeyCaptureField] submap dispatch error:", text.trim())
                }
            }
        }
    }

    // Internal — switches Hyprland into the capture submap. Only call via
    // activate(), or the onActiveFocusChanged safety net below.
    function enterCapture() {
        if (root._inCaptureMode) return
        root._inCaptureMode = true
        submapProc.command = ["hyprctl", "dispatch", "hl.dsp.submap(\"capture\")"]
        submapProc.running = true
    }

    // Internal — leaves the capture submap. Safe to call redundantly.
    function exitCapture() {
        if (!root._inCaptureMode) return
        root._inCaptureMode = false
        submapProc.command = ["hyprctl", "dispatch", "hl.dsp.submap(\"reset\")"]
        submapProc.running = true
    }

    onActiveFocusChanged: {
        // Safety net only: losing focus always disarms + exits the submap,
        // even if a caller forgot to call deactivateAndClear() explicitly.
        // Gaining focus deliberately does NOT arm capture — arming only
        // ever happens via activate().
        if (!activeFocus) {
            root.armed = false
            root.exitCapture()
        }
    }

    Component.onDestruction: root.exitCapture()

    function _modNames(mods) {
        let names = []
        if (mods & Qt.MetaModifier) names.push("SUPER")
        if (mods & Qt.ControlModifier) names.push("CTRL")
        if (mods & Qt.ShiftModifier) names.push("SHIFT")
        if (mods & Qt.AltModifier) names.push("ALT")
        return names
    }

    function _keyName(key, text) {
        const map = {
            [Qt.Key_Left]: "left", [Qt.Key_Right]: "right",
            [Qt.Key_Up]: "up", [Qt.Key_Down]: "down",
            [Qt.Key_Return]: "Return", [Qt.Key_Enter]: "Return",
            [Qt.Key_Space]: "Space", [Qt.Key_Tab]: "Tab",
            [Qt.Key_Backspace]: "Backspace",
            [Qt.Key_Delete]: "Delete", [Qt.Key_Print]: "Print",
            [Qt.Key_Comma]: "COMMA", [Qt.Key_Period]: "PERIOD"
        }
        if (map[key] !== undefined) return map[key]
        if (key >= Qt.Key_F1 && key <= Qt.Key_F35) return "F" + (key - Qt.Key_F1 + 1)

        // Letters and digits: derive from the key code itself, not
        // event.text. event.text is unreliable once CTRL/ALT is held — it
        // often carries a control character (e.g. Ctrl+A -> \x01) instead
        // of the plain letter, which has no glyph and renders as a box.
        // Qt.Key_A..Z and Qt.Key_0..9 map 1:1 onto ASCII codes, so
        // String.fromCharCode(key) is safe no matter what modifiers are held.
        if (key >= Qt.Key_A && key <= Qt.Key_Z) return String.fromCharCode(key)
        if (key >= Qt.Key_0 && key <= Qt.Key_9) return String.fromCharCode(key)

        if (text && text.length === 1) return text.toUpperCase()
        return ""
    }

    Text {
        anchors.centerIn: parent
        text: root.resultCombo.length > 0
            ? root.resultCombo
            : (root._heldMods.length > 0
                ? root._heldMods.join(" + ") + " + …"
                : (root.armed ? "Press keys…" : "Click to set shortcut"))
        color: root.resultCombo.length > 0 ? Colors.accent : (root._heldMods.length > 0 ? Colors.fg : Colors.subtext)
        font.family: Fonts.mono
        font.pixelSize: Dimens.fontSizeSm
    }

    Keys.onPressed: (event) => {
        // Hard gate: ignore all key events unless explicitly armed via
        // activate(). This is what stops the field from capturing keys
        // just because it happened to receive focus.
        if (!root.armed) { event.accepted = false; return }

        if (event.isAutoRepeat) { event.accepted = true; return }

        // Escape always exits editing and discards the staged combo — it
        // never saves. Saving is Save-button-only.
        if (event.key === Qt.Key_Escape) {
            root.cancelled()
            event.accepted = true
            return
        }

        const isPureModifier = event.key === Qt.Key_Shift || event.key === Qt.Key_Control
            || event.key === Qt.Key_Alt || event.key === Qt.Key_Meta
            || event.key === Qt.Key_Super_L || event.key === Qt.Key_Super_R

        if (isPureModifier) {
            root._heldMods = root._modNames(event.modifiers | _impliedMod(event.key))
            event.accepted = true
            return
        }

        const mods = root._modNames(event.modifiers)
        const keyName = root._keyName(event.key, event.text)
        if (keyName.length === 0) { event.accepted = true; return }

        // Stages the combo — does not emit a save. Pressing again overwrites this.
        root.resultCombo = (mods.length > 0 ? mods.join(" + ") + " + " : "") + keyName
        root.comboChanged(root.resultCombo)
        event.accepted = true
    }

    function _impliedMod(key) {
        if (key === Qt.Key_Shift) return Qt.ShiftModifier
        if (key === Qt.Key_Control) return Qt.ControlModifier
        if (key === Qt.Key_Alt) return Qt.AltModifier
        if (key === Qt.Key_Meta || key === Qt.Key_Super_L || key === Qt.Key_Super_R) return Qt.MetaModifier
        return 0
    }

    Keys.onReleased: (event) => {
        if (!root.armed) return
        if (!event.isAutoRepeat) root._heldMods = root._modNames(event.modifiers)
    }
}