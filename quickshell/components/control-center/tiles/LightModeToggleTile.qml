import QtQuick
import "../"
import "../../../styles"
import "../../../services"

ToggleTile {
    title: Colors.lightModeEnabled ? "Light Mode" : "Dark Mode"
    displayName: Colors.lightModeEnabled ? "Light Mode" : "Dark Mode"
    active: Colors.lightModeEnabled
    subtitle: {
        if (!Colors.themeHasBothVariants) return "Unavailable"
        return Colors.lightModeEnabled ? "On" : "Off"
    }
    iconGlyph: Colors.lightModeEnabled ? "light_mode" : "dark_mode"
    external: false
    onToggled: Colors.toggleLightMode()
}