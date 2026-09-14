// settings/clock/Clock.qml
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../common"

Item {
    id: root
    property bool use24Hour: true

    SettingsScrollView {
        SettingsGroup {
            title: "Clock & Date Settings"
            description: "Time format, date display, and calendar options"
            icon: "schedule"
            expanded: true

            SettingsToggleRow {
                label: "Use 24-Hour Clock Format"
                checked: root.use24Hour
                showDivider: false
                onToggled: (val) => root.use24Hour = val
            }
        }
    }
}