// settings/common/SettingsCarouselRow.qml — horizontal scrollable card row.
// Used by Theme and Wallpaper sections; delegate is supplied per use-site since
// ThemeCard and WallpaperCard take different properties.
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property alias model: listView.model
    property alias currentIndex: listView.currentIndex
    property Component cardDelegate
    property real rowHeight: 140
    property real cardSpacing: 12

    Layout.fillWidth: true
    implicitHeight: root.rowHeight

    ListView {
        id: listView
        anchors.fill: parent
        orientation: ListView.Horizontal
        spacing: root.cardSpacing
        clip: true
        delegate: root.cardDelegate

        WheelHandler {
            orientation: Qt.Horizontal
            property: "contentX"
            rotationScale: 15
        }
    }
}