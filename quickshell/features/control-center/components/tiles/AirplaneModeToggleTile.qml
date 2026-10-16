import QtQuick
import ".."
import "../../../../core/styles"
import "../../../network"

ToggleTile {
    title: "Airplane Mode"
    active: AirplaneModeService.enabled
    subtitle: AirplaneModeService.enabled ? "On" : "Off"
    iconGlyph: "flight"
    iconColor: Colors.cyan
    external: false
    onToggled: AirplaneModeService.toggle()
}