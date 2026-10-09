import QtQuick
import "../"
import "../../../styles"
import "../../../services"

ToggleTile {
    title: "Caffeine"
    active: CaffeineService.enabled
    subtitle: CaffeineService.enabled ? "Awake" : "Off"
    iconGlyph: "coffee"
    iconColor: Colors.green
    hasSubview: true
    external: false
    onToggled: CaffeineService.toggle()
}