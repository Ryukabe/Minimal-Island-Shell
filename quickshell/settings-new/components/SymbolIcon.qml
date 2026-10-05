// components/SymbolIcon.qml — one Material Symbols glyph.
// Uses Fonts.iconAxes so it follows the icon weight / fill chosen in Typography.
import QtQuick
import "../../styles"

Text {
    id: root

    property string name: ""
    property real size: Dimens.fontSizeLg

    text: root.name
    color: Colors.fg
    font.family: Fonts.icon
    font.variableAxes: Fonts.iconAxes
    font.pixelSize: root.size
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
}
