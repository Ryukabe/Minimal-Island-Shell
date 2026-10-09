pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    property bool enabled: false
    property bool _wifiWasOn: false
    property bool _btWasOn: false

    function toggle() {
        if (!root.enabled) {
            root._wifiWasOn = WifiService.enabled
            root._btWasOn = BluetoothService.enabled
            if (WifiService.enabled) WifiService.toggle()
            if (BluetoothService.enabled) BluetoothService.toggle()
            root.enabled = true
        } else {
            if (root._wifiWasOn && !WifiService.enabled) WifiService.toggle()
            if (root._btWasOn && !BluetoothService.enabled) BluetoothService.toggle()
            root.enabled = false
        }
    }
}