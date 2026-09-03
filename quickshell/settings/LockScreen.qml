import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components/common"

Item {
    id: root
    property bool frostedBlur: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Dimens.paddingLarge
        spacing: Dimens.spacingLarge

        Text { text: "Lock Screen & Security"; color: Colors.fg; font.pixelSize: Dimens.fontSizeXl; font.bold: true }

        Rectangle {
            Layout.fillWidth: true
            height: 64
            color: Colors.islandMica
            radius: Dimens.radiusLarge
            border.color: Colors.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: Dimens.paddingLarge
                Text { text: "Frosted Glass Background Blur"; color: Colors.fg; Layout.fillWidth: true }
                ToggleSwitch { checked: root.frostedBlur; onToggled: (val) => root.frostedBlur = val }
            }
        }
        Item { Layout.fillHeight: true }
    }
}