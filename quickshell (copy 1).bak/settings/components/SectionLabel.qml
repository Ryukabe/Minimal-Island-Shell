// components/SectionLabel.qml — small muted heading above a GroupCard.
import QtQuick
import QtQuick.Layouts
import "../../styles"

Text {
    Layout.fillWidth: true
    Layout.topMargin: Dimens.spacingSmall
    leftPadding: Dimens.paddingSmall
    color: Colors.fgMuted
    font.family: Fonts.text
    font.pixelSize: Dimens.fontSizeSm
    font.weight: Font.DemiBold
    elide: Text.ElideRight
}
