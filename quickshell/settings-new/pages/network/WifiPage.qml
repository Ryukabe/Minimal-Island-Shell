// pages/network/WifiPage.qml — Wi-Fi. Embeds the Control Center Wi-Fi view, so both places show the same state.
// The Options rows are greyed placeholders.
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../../services"
import "../../../styles"
import "../../../components/control-center/subviews"

PageScroll {
    id: root

    SectionLabel { text: "Networks" }

    WifiSubView {
        Layout.fillWidth: true
        showBackButton: false
    }

    SectionLabel {
        text: "Options"
        Layout.topMargin: Dimens.spacingLarge
    }

    GroupCard {
        ToggleRow {
            label: "Connect automatically"
            description: "Join known networks when they are in range"
            checked: true
            placeholder: true
        }

        ToggleRow {
            label: "Metered connection"
            description: "Treat this connection as having a data limit"
            placeholder: true
        }

        ToggleRow {
            label: "Airplane mode"
            description: "Turn off Wi-Fi and Bluetooth together"
            placeholder: true
            showDivider: false
        }
    }
}