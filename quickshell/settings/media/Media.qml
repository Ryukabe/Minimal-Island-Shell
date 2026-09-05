import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../styles"
import "../common"

Item {
    id: root
    property bool showVisualizer: true

    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors.rightMargin: 6
        clip: true
        contentWidth: availableWidth
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Item {
            width: scrollView.availableWidth
            implicitHeight: contentCol.implicitHeight + Dimens.paddingLarge

            ColumnLayout {
                id: contentCol
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(parent.width - Dimens.paddingMedium * 2, 640)
                spacing: 0

                SettingsHeader {
                    icon: "graphic_eq"
                    title: "Media"
                    subtitle: "Audio visualizer and player behavior in the island."
                }

                SettingsToggleRow {
                    label: "Show Audio Visualizer in Island"
                    checked: root.showVisualizer
                    onToggled: (val) => root.showVisualizer = val
                }
            }
        }
    }
}