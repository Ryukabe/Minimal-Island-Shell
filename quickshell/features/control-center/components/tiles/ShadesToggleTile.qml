import QtQuick
import ".."
import "../../../display"
import "../../../../core/styles"

ToggleTile {
    title: "Shades"
    active: HyprshadeService.enabled
    subtitle: HyprshadeService.enabled ? HyprshadeService.prettyName(HyprshadeService.current) : "Off"
    iconGlyph: "tonality"
    external: true
    hasSubview: true
    onToggled: HyprshadeService.toggle()
}