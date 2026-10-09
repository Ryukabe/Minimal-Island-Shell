import QtQuick
import "../"
import "../../../styles"
import "../../../services"

ToggleTile {
    id: tile
    title: "Power Profile"
    active: PowerProfileService.activeProfile !== "auto"
    subtitle: {
        var p = PowerProfileService.profiles.find(function(x) { return x.id === PowerProfileService.activeProfile })
        return p ? p.name : "Automatic"
    }
    displayName: {
        var p = PowerProfileService.profiles.find(function(x) { return x.id === PowerProfileService.activeProfile })
        return p ? p.name : "Auto"
    }
    iconGlyph: "speed"
    external: true
    hasSubview: true
    onToggled: tile.subviewRequested()
}