// settings/system/System.qml — consolidated Display, Notifications, and
// Mouse & Touchpad settings under one "System" page.
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../common"

Item {
    id: root

    property bool peaceMode: false
    property bool naturalScrolling: true

    SettingsScrollView {
        SettingsHeader {
            icon: "settings"
            title: "System"
            subtitle: "Display, notifications, and mouse behavior."
        }

        SettingsSectionLabel { label: "Display" }

        SettingsRow {
            label: "Display Scale Factor"
            value: "100%"
            showChevron: false
            showDivider: false
        }

        SettingsSectionLabel { label: "Notifications" }

        SettingsToggleRow {
            label: "Peace Mode (Do Not Disturb)"
            checked: root.peaceMode
            showDivider: false
            onToggled: (val) => root.peaceMode = val
        }

        SettingsSectionLabel { label: "Mouse & Touchpad" }

        SettingsToggleRow {
            label: "Natural Scrolling"
            checked: root.naturalScrolling
            showDivider: false
            onToggled: (val) => root.naturalScrolling = val
        }
    }
}