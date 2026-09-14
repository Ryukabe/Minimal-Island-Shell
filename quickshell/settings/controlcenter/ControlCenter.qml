// settings/controlcenter/ControlCenter.qml
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../common"

Item {
    id: root
    property bool compactSliders: false

    SettingsScrollView {
        SettingsGroup {
            title: "Control Center Tiles"
            description: "Layout and appearance of quick toggle tiles"
            icon: "widgets"
            expanded: true

            SettingsToggleRow {
                label: "Compact Slider Layout"
                checked: root.compactSliders
                showDivider: false
                onToggled: (val) => root.compactSliders = val
            }
        }
    }
}