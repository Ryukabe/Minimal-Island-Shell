import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components/common"

Item {
    id: root
    property bool peaceMode: false

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Dimens.paddingLarge
        spacing: Dimens.spacingLarge

        Text { text: "Notification Behaviors"; color: Colors.fg; font.pixelSize: Dimens.fontSizeXl; font.bold: true }

        Rectangle {
            Layout.fillWidth: true
            height: 64
            color: Colors.islandMica
            radius: Dimens.radiusLarge
            border.color: Colors.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: Dimens.paddingLarge
                Text { text: "Peace Mode (Do Not Disturb)"; color: Colors.fg; Layout.fillWidth: true }
                ToggleSwitch { checked: root.peaceMode; onToggled: (val) => root.peaceMode = val }
            }
        }
        Item { Layout.fillHeight: true }
    }
}