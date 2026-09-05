import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../styles"
import "../common"

Item {
    id: root
    property bool compactSliders: false

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
                    icon: "widgets"
                    title: "Control Center"
                    subtitle: "Layout and appearance of quick toggle tiles."
                }

                SettingsToggleRow {
                    label: "Compact Slider Layout"
                    checked: root.compactSliders
                    onToggled: (val) => root.compactSliders = val
                }
            }
        }
    }
}