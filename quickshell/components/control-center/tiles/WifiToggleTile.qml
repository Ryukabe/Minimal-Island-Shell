import QtQuick
import "../"
import "../../../styles"
import "../../../services"

ToggleTile {
    title: "Wi-Fi"
    active: WifiService.enabled
    subtitle: {
        if (!WifiService.enabled) return "Off"
        if (WifiService.ssid === "") return "On"
        if (!WifiService.hasInternet) return "No Internet"
        return WifiService.ssid
    }
    displayName: {
        if (!WifiService.enabled) return "Wi-Fi"
        if (WifiService.ssid === "") return "Not Connected"
        if (!WifiService.hasInternet) return "No Internet"
        return WifiService.ssid
    }
    iconGlyph: "wifi"
    external: true
    hasSubview: true
    onToggled: WifiService.toggle()
}