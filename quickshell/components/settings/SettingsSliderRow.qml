import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../common"

ColumnLayout {
    id: root
    property string label: ""
    property real from: 0
    property real to: 100
    property real value: 0
    property real stepSize: 1
    property string unit: ""
    property int decimals: 0
    signal moved(real value)

    Layout.fillWidth: true
    Layout.bottomMargin: Dimens.spacingMedium
    spacing: Dimens.spacingSmall

    RowLayout {
        Layout.fillWidth: true
        Text {
            text: root.label
            color: Colors.fg
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeBase
            Layout.fillWidth: true
        }
        Text {
            text: (root.decimals > 0 ? root.value.toFixed(root.decimals) : Math.round(root.value).toString()) + root.unit
            color: Colors.subtext
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeBase
        }
    }

    SliderControl {
        Layout.fillWidth: true
        from: root.from
        to: root.to
        stepSize: root.stepSize
        value: root.value
        onMoved: (val) => root.moved(val)
    }
}