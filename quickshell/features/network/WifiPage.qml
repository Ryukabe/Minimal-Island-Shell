// features/network/WifiPage.qml — Wi-Fi. Embeds the Control Center Wi-Fi view, so both places show the same state.
// Every option here is real: saved networks and metered are NetworkManager settings, the scan
// interval is a ShellState setting, and airplane mode is AirplaneModeService (shared with the Control Center).
import QtQuick
import QtQuick.Layouts
import "../settings/components"
import "../settings/core"
import "."
import "../../core/shell"
import "../../core/styles"
import "../control-center/components/subviews"

PageScroll {
    id: root

    function _openForgetPicker() {
        SettingsPicker.open({
            title: "Forget a network",
            searchHint: "Search saved networks...",
            items: WifiService.savedProfiles.map(name => ({ value: name, label: name })),
            selectedValue: "",
            initialQuery: "",
            onPick: function (name) { WifiService.forgetNetwork(name) }
        })
    }

    SectionLabel { text: "Networks" }

    WifiSubView {
        Layout.fillWidth: true
        showBackButton: false
    }

    SectionLabel {
        text: "Saved networks"
        Layout.topMargin: Dimens.spacingLarge
    }

    GroupCard {
        InfoRow {
            visible: savedRepeater.count === 0
            label: "No saved networks yet"
            showDivider: false
        }

        // One switch per saved network: NetworkManager keeps "connect automatically" per network,
        // so this is the real setting rather than a copy of it.
        Repeater {
            id: savedRepeater
            model: WifiService.savedNetworks

            delegate: ToggleRow {
                required property var modelData

                label: modelData.name
                description: modelData.name === WifiService.ssid
                    ? "Connected. Join automatically when in range"
                    : "Join automatically when in range"
                checked: modelData.autoconnect
                onToggled: (val) => WifiService.setAutoconnect(modelData.name, val)
            }
        }

        ButtonRow {
            visible: savedRepeater.count > 0
            label: "Forget a network"
            description: "Removes it and its saved password"
            buttonText: "Choose"
            showDivider: false
            onClicked: root._openForgetPicker()
        }
    }

    SectionLabel {
        text: "Options"
        Layout.topMargin: Dimens.spacingLarge
    }

    GroupCard {
        SliderRow {
            label: "Wi-Fi scan"
            description: "How often nearby networks are looked up while a Wi-Fi list is open"
            from: 5; to: 60; stepSize: 5
            value: ShellState.wifiScanIntervalSec
            unit: " s"
            onMoved: (val) => ShellState.wifiScanIntervalSec = val
        }

        ToggleRow {
            label: "Metered connection"
            description: WifiService.ssid !== ""
                ? "Treat " + WifiService.ssid + " as having a data limit"
                : "Connect to a network first"
            checked: WifiService.meteredActive
            enabled: WifiService.ssid !== ""
            onToggled: (val) => WifiService.setMetered(val)
        }

        // Same AirplaneModeService as the Control Center tile, so both always agree.
        ToggleRow {
            label: "Airplane mode"
            description: "Turn off Wi-Fi and Bluetooth together"
            checked: AirplaneModeService.enabled
            onToggled: (val) => AirplaneModeService.toggle()
            showDivider: false
        }
    }
}
