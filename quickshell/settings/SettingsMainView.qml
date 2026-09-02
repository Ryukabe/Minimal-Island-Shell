import QtQuick
import QtQuick.Layouts
import "../styles"

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 12

        Text {
            text: "Bar & Island Configuration"
            color: Colors.fg ?? "#cdd6f4"
            font.bold: true
            font.pixelSize: 14
        }
    }
}