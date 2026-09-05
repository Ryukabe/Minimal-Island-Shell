import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../components/common"

Item {
    id: root
    property string label: ""
    property bool checked: false
    property bool showDivider: true
    signal toggled(bool checked)

    Layout.fillWidth: true
    implicitHeight: 44

    RowLayout {
        anchors.fill: parent
        spacing: Dimens.spacingSmall

        Text {
            text: root.label
            color: Colors.fg
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeBase
            Layout.fillWidth: true
        }

        ToggleSwitch {
            checked: root.checked
            onToggled: (val) => root.toggled(val)
        }
    }

    Rectangle {
        visible: root.showDivider
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Colors.border
        opacity: 0.35
    }
}