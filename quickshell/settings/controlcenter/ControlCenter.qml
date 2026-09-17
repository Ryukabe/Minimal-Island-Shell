// settings/controlcenter/ControlCenter.qml
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../common"
import "../../components/control-center"

Item {
    id: root
    property bool compactSliders: false

    SettingsScrollView {

        SettingsToggleRow {
            label: "Compact Slider Layout"
            checked: root.compactSliders
            showDivider: false
            onToggled: (val) => root.compactSliders = val
        }

        ControlGrid {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            editMode: true
        }
    }
}