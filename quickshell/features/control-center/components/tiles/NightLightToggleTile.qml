import QtQuick
import ".."
import "../../../display"
import "../../../../core/styles"

ToggleTile {
    title: "Night Light"
    active: NightLightService.enabled
    subtitle: NightLightService.enabled ? NightLightService.temperature + "K" : "Off"
    iconGlyph: "nightlight"
    external: true
    hasSubview: true
    onToggled: NightLightService.toggle()
}