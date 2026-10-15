import QtQuick
import ".."
import "../../../../display"
import "../../../../../core/styles"

ToggleTile {
    title: "Night Light"
    active: NightLightService.enabled
    subtitle: NightLightService.enabled ? "On" : "Off"
    iconGlyph: "nightlight"
    external: true
    onToggled: NightLightService.toggle()
}