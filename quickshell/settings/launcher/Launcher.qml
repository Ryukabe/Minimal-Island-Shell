// settings/launcher/Launcher.qml
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../common"

Item {
    id: root
    property bool inlineCalculator: true

    SettingsScrollView {
        SettingsGroup {
            title: "App Launcher Preferences"
            description: "Search behavior, calculator, and clipboard history"
            icon: "rocket_launch"
            expanded: true

            SettingsToggleRow {
                label: "Inline Calculator Engine"
                checked: root.inlineCalculator
                showDivider: false
                onToggled: (val) => root.inlineCalculator = val
            }
        }
    }
}