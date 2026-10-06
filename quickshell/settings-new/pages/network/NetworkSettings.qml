// pages/network/NetworkSettings.qml — Wi-Fi & Bluetooth. Embeds the Control Center subviews, so both
// places always show the same state.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"
import "../../../components/control-center/subviews"

PageScroll {
    id: root

    SectionLabel { text: "Wi-Fi" }

    WifiSubView {
        Layout.fillWidth: true
        showBackButton: false
    }

    SectionLabel {
        text: "Bluetooth"
        Layout.topMargin: Dimens.spacingLarge
    }

    BluetoothSubView {
        Layout.fillWidth: true
        showBackButton: false
    }
}