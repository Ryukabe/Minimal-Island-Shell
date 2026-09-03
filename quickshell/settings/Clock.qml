import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components/common"

Item {
    id: root
    property bool use24Hour: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Dimens.paddingLarge
        spacing: Dimens.spacingLarge

        Text { text: "Clock & Date Settings"; color: Colors.fg; font.pixelSize: Dimens.fontSizeXl; font.bold: true }

        Rectangle {
            Layout.fillWidth: true
            height: 64
            color: Colors.islandMica
            radius: Dimens.radiusLarge
            border.color: Colors.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: Dimens.paddingLarge
                Text { text: "Use 24-Hour Clock Format"; color: Colors.fg; Layout.fillWidth: true }
                ToggleSwitch { checked: root.use24Hour; onToggled: (val) => root.use24Hour = val }
            }
        }
        Item { Layout.fillHeight: true }
    }
}