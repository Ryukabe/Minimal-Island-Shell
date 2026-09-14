import QtQuick
import QtQuick.Layouts
import "../../styles"

Rectangle {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""

    Layout.fillWidth: true
    implicitHeight: 70
    radius: Dimens.radiusMedium
    color: Colors.subBgMica
    border.color: Colors.border
    border.width: 1

    Item {
        anchors.fill: parent

        Rectangle {
            id: iconBadge
            width: 40
            height: 40
            radius: 20
            anchors.left: parent.left
            anchors.leftMargin: Dimens.paddingMedium
            anchors.verticalCenter: parent.verticalCenter
            color: Colors.elevatedBg

            Text {
                id: bannerIcon
                anchors.centerIn: parent
                text: root.icon
                color: Colors.accent
                font.family: Fonts.icon
                font.pixelSize: 22
                transformOrigin: Item.Center

                SequentialAnimation {
                    id: bannerIconPop
                    running: false
                    NumberAnimation { target: bannerIcon; property: "scale"; from: 0.4; to: 1.25; duration: 160; easing.type: Easing.OutCubic }
                    NumberAnimation { target: bannerIcon; property: "scale"; from: 1.25; to: 1.0; duration: 120; easing.type: Easing.InOutQuad }
                }

                onTextChanged: bannerIconPop.restart()
            }
        }

        ColumnLayout {
            anchors.left: iconBadge.right
            anchors.leftMargin: Dimens.spacingMedium
            anchors.right: parent.right
            anchors.rightMargin: Dimens.paddingMedium
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text: root.title
                color: Colors.fg
                font.family: Fonts.display
                font.pixelSize: Dimens.fontSizeLg
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            Text {
                text: root.subtitle
                color: Colors.fgMuted
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXs
                elide: Text.ElideRight
            }
        }
    }
}