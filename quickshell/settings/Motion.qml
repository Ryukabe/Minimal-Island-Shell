import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components/common"

Item {
    id: root
    property real stiffness: 120
    property real damping: 0.85

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Dimens.paddingLarge
        spacing: Dimens.spacingLarge

        Text { text: "Motion & Physics Curves"; color: Colors.fg; font.pixelSize: Dimens.fontSizeXl; font.bold: true }

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
                    Text { text: "Spring Stiffness"; color: Colors.fg }
                    Item { Layout.fillWidth: true }
                    Text { text: Math.round(root.stiffness).toString(); color: Colors.accent; font.bold: true }
                }
                SliderControl {
                    Layout.fillWidth: true
                    from: 20; to: 300
                    value: root.stiffness
                    onMoved: (val) => root.stiffness = val
                }
            }
        }
        Item { Layout.fillHeight: true }
    }
}