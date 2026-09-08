// settings/keybinds/KeyCaptureField.qml — live key-press capture for rebinding.
// Pressing a combo stages it (shown in accent color) without saving; keep
// pressing to overwrite the staged combo. Escape always cancels and discards
// whatever was staged. Actual commit happens only via KeybindRow's Save
// button. Mouse-button binds aren't capturable this way.
//
// While this field is active, Hyprland is switched into the "capture"
// submap (declared statically in binds.lua via hl.define_submap, with a
// safety-valve Escape -> reset bind inside it). While that submap is
// active, NO bind outside it can fire — including the one currently being
// rebound — so pressing a combo that's already in use here won't also
// trigger its old action. Capture mode is exited explicitly by the caller
// (KeybindRow calls exitCapture() whenever it closes editing, on every
// path: Save, Cancel, or Escape/cancelled), not left to rely on focus loss
// alone. onActiveFocusChanged and Component.onDestruction remain as backup
// safety nets in case the field loses focus or is torn down some other way.
import QtQuick
import Quickshell.Io
import "../../styles"

Rectangle {
    id: root

    property string resultCombo: ""

    signal comboChanged(string combo)
    signal cancelled()

    implicitWidth: 200
    implicitHeight: 28
    radius: Dimens.radiusSmall
    color: Colors.subBgMica
    border.color: Colors.accent
    border.width: 1

    property var _heldMods: []
    property bool _inCaptureMode: false

    function reset() {
        root.resultCombo = ""
        root._heldMods = []
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

    // Public — call to start capturing. Uses Hyprland's Lua-eval dispatch
    // form since binds.lua runs on Hyprland's native Lua config engine
    // (hl.bind/hl.dsp), matching how the "capture" submap itself is
    // declared there via hl.define_submap.
    function enterCapture() {
        if (root._inCaptureMode) return
        root._inCaptureMode = true
        submapProc.command = ["hyprctl", "dispatch", "hl.dsp.submap(\"capture\")"]
        submapProc.running = true
    }

    // Public — call explicitly whenever editing closes, from any path
    // (Save, Cancel, Escape/cancelled). Do not rely on focus loss alone.
    function exitCapture() {
        if (!root._inCaptureMode) return
        root._inCaptureMode = false
        submapProc.command = ["hyprctl", "dispatch", "hl.dsp.submap(\"reset\")"]
        submapProc.running = true
    }

    onActiveFocusChanged: {
        // Backup safety net only — primary control is the caller's
        // explicit enterCapture()/exitCapture() calls.
        if (activeFocus) root.enterCapture()
        else root.exitCapture()
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
        if (text && text.length === 1) return text.toUpperCase()
        return ""
    }

    Text {
        anchors.centerIn: parent
        text: root.resultCombo.length > 0
            ? root.resultCombo
            : (root._heldMods.length > 0 ? root._heldMods.join(" + ") + " + …" : "Press keys…")
        color: root.resultCombo.length > 0 ? Colors.accent : (root._heldMods.length > 0 ? Colors.fg : Colors.subtext)
        font.family: Fonts.mono
        font.pixelSize: Dimens.fontSizeSm
    }

    Keys.onPressed: (event) => {
        if (event.isAutoRepeat) { event.accepted = true; return }

        // Escape always exits editing and discards the staged combo — it
        // never saves. Saving is Save-button-only. KeybindRow's
        // onEditingChanged (triggered via the cancelled() handler setting
        // editing=false) calls exitCapture() explicitly. This is separate
        // from the Escape -> submap reset safety bind inside binds.lua,
        // which only matters if something goes wrong and Quickshell isn't
        // around to issue the dispatch itself.
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
        if (!event.isAutoRepeat) root._heldMods = root._modNames(event.modifiers)
    }
}