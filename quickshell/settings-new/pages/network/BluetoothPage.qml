// pages/network/BluetoothPage.qml — Bluetooth. Embeds the Control Center Bluetooth view.
// The Options rows are greyed placeholders.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"
import "../../../components/control-center/subviews"

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
            description: "Display the charge of connected devices"
            checked: true
            placeholder: true
        }

        ToggleRow {
            label: "Visible to nearby devices"
            description: "Let other devices find this computer"
            placeholder: true
        }

        ToggleRow {
            label: "Reconnect at startup"
            description: "Connect to the last device when the shell starts"
            placeholder: true
            showDivider: false
        }
    }
}