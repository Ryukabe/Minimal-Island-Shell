import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"

Item {
    id: root
    property string palette: "Catppuccin"
    property string fontFamily: "Sans"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Dimens.paddingLarge
        spacing: Dimens.spacingLarge

        Text { text: "Appearance & Themes"; color: Colors.fg; font.pixelSize: Dimens.fontSizeXl; font.bold: true }

        Rectangle {
            Layout.fillWidth: true
            height: 64
            color: Colors.islandMica
            radius: Dimens.radiusLarge
            border.color: Colors.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: Dimens.paddingLarge
                Text { text: "System Font"; color: Colors.fg; Layout.fillWidth: true }
                Text { text: root.fontFamily; color: Colors.accent; font.bold: true }
            }
        }
        Item { Layout.fillHeight: true }
    }
}