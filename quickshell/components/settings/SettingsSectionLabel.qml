import QtQuick
import "../../styles"

Text {
    id: root
    property string label: ""

    text: root.label.toUpperCase()
    color: Colors.subtext
    font.family: Fonts.text
    font.pixelSize: Dimens.fontSizeXs
    font.weight: Font.DemiBold
    font.letterSpacing: 1
    topPadding: Dimens.spacingMedium
    bottomPadding: Dimens.spacingSmall
}