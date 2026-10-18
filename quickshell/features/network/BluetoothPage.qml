// features/network/BluetoothPage.qml — Bluetooth. Embeds the Control Center Bluetooth view.
// Battery and reconnect are ShellState settings; "visible" is read from and written to BlueZ.
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "."
import "../../core/shell"
import "../../core/styles"
import "../control-center/components/subviews"

PageScroll {
    id: root

    SectionLabel { text: "Devices" }

    BluetoothSubView {
        Layout.fillWidth: true
        showBackButton: false
    }

    SectionLabel {
        text: "Options"
        Layout.topMargin: Dimens.spacingLarge
    }

    GroupCard {
        ToggleRow {
            label: "Show battery level"
            description: "Display the charge of connected devices that report one"
            checked: ShellState.bluetoothShowBattery
            onToggled: (val) => ShellState.bluetoothShowBattery = val
        }

        ToggleRow {
            label: "Visible to nearby devices"
            description: BluetoothService.enabled
                ? "Let other devices find this computer for a few minutes"
                : "Turn Bluetooth on first"
            checked: BluetoothService.discoverable
            enabled: BluetoothService.enabled
            onToggled: (val) => BluetoothService.setDiscoverable(val)
        }

        ToggleRow {
            label: "Reconnect at startup"
            description: "Connect to the last device when the shell starts"
            checked: ShellState.bluetoothReconnectAtStartup
            onToggled: (val) => ShellState.bluetoothReconnectAtStartup = val
            showDivider: false
        }
    }
}
