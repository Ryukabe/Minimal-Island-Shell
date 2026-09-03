import QtQuick
import QtQuick.Layouts
import "../../styles"

ColumnLayout {
    id: root
    property string icon: "settings"
    property string title: ""
    property string subtitle: ""

    Layout.fillWidth: true
    Layout.bottomMargin: Dimens.spacingLarge
    spacing: Dimens.spacingSmall

    Rectangle {
        Layout.alignment: Qt.AlignHCenter
        width: 56
        height: 56
        radius: 28
        color: Colors.islandMica
        border.color: Colors.border
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: root.icon
            color: Colors.fg
            font.family: Fonts.icon
            font.variableAxes: Fonts.iconAxes
            font.pixelSize: Dimens.fontSizeXxl
        }
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: root.title
        color: Colors.fg
        font.family: Fonts.display
        font.pixelSize: Dimens.fontSizeLg
        font.weight: Font.Bold
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        Layout.maximumWidth: 340
        text: root.subtitle
        color: Colors.subtext
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeSm
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
    }
}