import QtQuick
import "../"
import "../../../styles"
import "../../../services"

ToggleTile {
    title: "Bluetooth"
    active: BluetoothService.enabled
    subtitle: BluetoothService.statusText
    displayName: {
        if (!BluetoothService.enabled) return "Bluetooth"
        if (BluetoothService.connectedDevices.length > 0) return BluetoothService.connectedDevices[0].name
        return "No Device"
    }
    iconGlyph: "bluetooth"
    external: true
    hasSubview: true
    onToggled: BluetoothService.toggle()
}