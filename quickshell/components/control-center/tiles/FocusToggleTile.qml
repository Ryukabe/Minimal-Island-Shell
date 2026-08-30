import QtQuick
import "../"
import "../../../styles"
import "../../../services"

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