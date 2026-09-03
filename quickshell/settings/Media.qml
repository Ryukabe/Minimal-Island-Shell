import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components/common"

Item {
    id: root
    property bool showVisualizer: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Dimens.paddingLarge
        spacing: Dimens.spacingLarge

        Text { text: "Media & Equalizer Settings"; color: Colors.fg; font.pixelSize: Dimens.fontSizeXl; font.bold: true }

        Rectangle {
            Layout.fillWidth: true
            height: 64
            color: Colors.islandMica
            radius: Dimens.radiusLarge
            border.color: Colors.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: Dimens.paddingLarge
                Text { text: "Show Audio Visualizer in Island"; color: Colors.fg; Layout.fillWidth: true }
                ToggleSwitch { checked: root.showVisualizer; onToggled: (val) => root.showVisualizer = val }
            }
        }
        Item { Layout.fillHeight: true }
    }
}