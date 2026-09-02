import QtQuick
import QtQuick.Layouts
import "../styles"

Item {
    Layout.fillWidth: true
    Layout.fillHeight: true
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        Text { text: "System Settings"; color: Colors.fg ?? "#cdd6f4"; font.bold: true }
    }
}