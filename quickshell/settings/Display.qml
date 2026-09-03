import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Dimens.paddingLarge
        spacing: Dimens.spacingLarge

        Text { text: "Display & Scaling"; color: Colors.fg; font.pixelSize: Dimens.fontSizeXl; font.bold: true }

        Rectangle {
            Layout.fillWidth: true
            height: 64
            color: Colors.islandMica
            radius: Dimens.radiusLarge
            border.color: Colors.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: Dimens.paddingLarge
                Text { text: "Display Scale Factor"; color: Colors.fg; Layout.fillWidth: true }
                Text { text: "100%"; color: Colors.accent; font.bold: true }
            }
        }
        Item { Layout.fillHeight: true }
    }
}