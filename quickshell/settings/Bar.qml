import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components/common"

Item {
    id: root
    property int barHeight: 38
    property bool showIsland: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Dimens.paddingLarge
        spacing: Dimens.spacingLarge

        Text { text: "Bar & Island Geometry"; color: Colors.fg; font.pixelSize: Dimens.fontSizeXl; font.bold: true }

        Rectangle {
            Layout.fillWidth: true
            height: 64
            color: Colors.islandMica
            radius: Dimens.radiusLarge
            border.color: Colors.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: Dimens.paddingLarge
                Text { text: "Enable Dynamic Island"; color: Colors.fg; Layout.fillWidth: true }
                ToggleSwitch { checked: root.showIsland; onToggled: (val) => root.showIsland = val }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 72
            color: Colors.islandMica
            radius: Dimens.radiusLarge
            border.color: Colors.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Dimens.paddingMedium
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Bar Height"; color: Colors.fg }
                    Item { Layout.fillWidth: true }
                    Text { text: root.barHeight + "px"; color: Colors.accent; font.bold: true }
                }
                SliderControl {
                    Layout.fillWidth: true
                    from: 28; to: 56; stepSize: 1
                    value: root.barHeight
                    onMoved: (val) => root.barHeight = val
                }
            }
        }
        Item { Layout.fillHeight: true }
    }
}