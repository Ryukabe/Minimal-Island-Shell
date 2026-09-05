import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../styles"
import "../common"

Item {
    id: root
    property bool inlineCalculator: true

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
                    icon: "rocket_launch"
                    title: "App Launcher"
                    subtitle: "Search behavior, calculator, and clipboard history."
                }

                SettingsToggleRow {
                    label: "Inline Calculator Engine"
                    checked: root.inlineCalculator
                    onToggled: (val) => root.inlineCalculator = val
                }
            }
        }
    }
}