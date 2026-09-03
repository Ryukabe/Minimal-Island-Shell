import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"

Item {
    id: root
    property string powerProfile: "balanced"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Dimens.paddingLarge
        spacing: Dimens.spacingLarge

        Text { text: "System & Power Maintenance"; color: Colors.fg; font.pixelSize: Dimens.fontSizeXl; font.bold: true }

        Rectangle {
            Layout.fillWidth: true
            height: 64
            color: Colors.islandMica
            radius: Dimens.radiusLarge
            border.color: Colors.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: Dimens.paddingLarge
                Text { text: "Active Power Profile"; color: Colors.fg; Layout.fillWidth: true }
                Text { text: root.powerProfile.toUpperCase(); color: Colors.accent; font.bold: true }
            }
        }

        Button {
            text: "Reload Shell State"
            Layout.fillWidth: true
        }
        Item { Layout.fillHeight: true }
    }
}