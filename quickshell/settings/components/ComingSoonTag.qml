// components/ComingSoonTag.qml — small pill shown on anything that is still a placeholder.
import QtQuick
import "../../styles"

Rectangle {
    id: root

    implicitHeight: 20
    implicitWidth: tagLabel.implicitWidth + Dimens.paddingSmall * 2
    radius: height / 2
    color: Colors.elevatedBg
    border.color: Colors.border
    border.width: 1

    Text {
        id: tagLabel
        anchors.centerIn: parent
        text: "Coming soon"
        color: Colors.fgMuted
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeXs
    }
}
