import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components/common"

Item {
    id: root
    property bool compactSliders: false

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Dimens.paddingLarge
        spacing: Dimens.spacingLarge

        Text { text: "Control Center Tiles"; color: Colors.fg; font.pixelSize: Dimens.fontSizeXl; font.bold: true }

        Rectangle {
            Layout.fillWidth: true
            height: 64
            color: Colors.islandMica
            radius: Dimens.radiusLarge
            border.color: Colors.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: Dimens.paddingLarge
                Text { text: "Compact Slider Layout"; color: Colors.fg; Layout.fillWidth: true }
                ToggleSwitch { checked: root.compactSliders; onToggled: (val) => root.compactSliders = val }
            }
        }
        Item { Layout.fillHeight: true }
    }
}