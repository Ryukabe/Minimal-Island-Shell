import QtQuick
import "../"
import "../../../core/styles"
import "../../../services"
import "../../../core/state"

ToggleTile {
    title: "Focus"
    active: ShellState.focusModeEnabled
    subtitle: ShellState.focusModeEnabled ? "On" : "Off"
    displayName: ShellState.focusModeEnabled ? ShellState.activeFocusMode : "Focus"
    iconGlyph: "do_not_disturb_on"
    external: false
    hasSubview: true
    onToggled: ShellState.toggleFocusMode()
}