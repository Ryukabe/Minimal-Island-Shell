// components/KeyCaptureField.qml — live key-press capture for rebinding.
// Capture only starts via activate() (a click on the field), never as a side effect of gaining focus.
// Pressing a combo stages it (shown in the accent colour) without saving; keep pressing to overwrite it.
// Escape cancels and discards the staged combo. Saving is the caller's job.
//
// While armed, Hyprland is switched into the "capture" submap (declared in binds.lua, with an Escape ->
// reset safety bind). No bind outside it can fire during capture, including the one being rebound.
// deactivateAndClear() is the single way to leave capture mode and wipe the staged combo.
// Mouse-button binds can't be captured this way.
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
    implicitHeight: 34
    radius: Dimens.settingsControlRadius
    color: Colors.elevatedBg
    border.color: root.armed ? Colors.accent : "transparent"
    border.width: 1

    property var _heldMods: []
    property bool _inCaptureMode: false

    function reset() {
        root.resultCombo = ""
        root._heldMods = []
    }

    // The only entry point that starts capture. Call it from an explicit click.
    function activate() {
        root.armed = true
        root.enterCapture()
        root.forceActiveFocus()
    }

    // Disarms capture and wipes any staged combo in one call. Use it for Cancel and close paths.
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

    function enterCapture() {
        if (root._inCaptureMode) return
        root._inCaptureMode = true
        submapProc.command = ["hyprctl", "dispatch", "hl.dsp.submap(\"capture\")"]
        submapProc.running = true
    }

    function exitCapture() {
        if (!root._inCaptureMode) return
        root._inCaptureMode = false
        submapProc.command = ["hyprctl", "dispatch", "hl.dsp.submap(\"reset\")"]
        submapProc.running = true
    }

    // Safety net: losing focus always disarms and leaves the submap, even if a caller forgot to.
    onActiveFocusChanged: {
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

        // Letters and digits come from the key code, not event.text. With CTRL or ALT held, event.text
        // often carries a control character (Ctrl+A -> \x01) that renders as a box.
        if (key >= Qt.Key_A && key <= Qt.Key_Z) return String.fromCharCode(key)
        if (key >= Qt.Key_0 && key <= Qt.Key_9) return String.fromCharCode(key)

        if (text && text.length === 1) return text.toUpperCase()
        return ""
    }

    function _impliedMod(key) {
        if (key === Qt.Key_Shift) return Qt.ShiftModifier
        if (key === Qt.Key_Control) return Qt.ControlModifier
        if (key === Qt.Key_Alt) return Qt.AltModifier
        if (key === Qt.Key_Meta || key === Qt.Key_Super_L || key === Qt.Key_Super_R) return Qt.MetaModifier
        return 0
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

    // Clicking the field is the explicit user action that arms capture.
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: if (!root.armed) root.activate()
    }

    Keys.onPressed: (event) => {
        // Hard gate: ignore every key unless armed via activate().
        if (!root.armed) { event.accepted = false; return }

        if (event.isAutoRepeat) { event.accepted = true; return }

        // Escape always cancels and discards the staged combo; it never saves.
        if (event.key === Qt.Key_Escape) {
            root.cancelled()
            event.accepted = true
            return
        }

        const isPureModifier = event.key === Qt.Key_Shift || event.key === Qt.Key_Control
            || event.key === Qt.Key_Alt || event.key === Qt.Key_Meta
            || event.key === Qt.Key_Super_L || event.key === Qt.Key_Super_R

        if (isPureModifier) {
            root._heldMods = root._modNames(event.modifiers | root._impliedMod(event.key))
            event.accepted = true
            return
        }

        const mods = root._modNames(event.modifiers)
        const keyName = root._keyName(event.key, event.text)
        if (keyName.length === 0) { event.accepted = true; return }

        // Stages the combo without saving. Pressing again overwrites it.
        root.resultCombo = (mods.length > 0 ? mods.join(" + ") + " + " : "") + keyName
        root.comboChanged(root.resultCombo)
        event.accepted = true
    }

    Keys.onReleased: (event) => {
        if (!root.armed) return
        if (!event.isAutoRepeat) root._heldMods = root._modNames(event.modifiers)
    }
}