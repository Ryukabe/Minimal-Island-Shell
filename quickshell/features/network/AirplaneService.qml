// features/network/AirplaneService.qml — airplane mode = Wi-Fi radio and Bluetooth both off.
// Nothing is stored: `active` is derived from the two services, so it can never disagree with them
// (switching either radio off by hand and the other is already off also reads as airplane mode).
// Turning it off switches both radios back on; it does not remember what was on before.
pragma Singleton
import QtQuick
import Quickshell
import "."

Singleton {
    id: root

    readonly property bool active: !WifiService.enabled && !BluetoothService.enabled

    function set(on) {
        WifiService.setRadio(!on)
        BluetoothService.setPower(!on)
    }
}
