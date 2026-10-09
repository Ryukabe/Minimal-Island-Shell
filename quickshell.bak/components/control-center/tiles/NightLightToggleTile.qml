import QtQuick
import "../"
import "../../../services"
import "../../../styles"

ToggleTile {
    title: "Night Light"
    active: NightLightService.enabled
    subtitle: NightLightService.enabled ? "On" : "Off"
    iconGlyph: "nightlight"
    external: true
    onToggled: NightLightService.toggle()
}