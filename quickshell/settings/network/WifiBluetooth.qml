// settings/network/WifiBluetooth.qml
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"
import "../common"
import "../../components/control-center/subviews"

Item {
    id: root

    SettingsScrollView {
        SettingsSectionLabel { label: "Wi-Fi" }

        WifiSubView {
            Layout.fillWidth: true
            showBackButton: false
        }

        SettingsSectionLabel {
            label: "Bluetooth"
            Layout.topMargin: Dimens.spacingLarge
        }

        BluetoothSubView {
            Layout.fillWidth: true
            showBackButton: false
        }
    }
}