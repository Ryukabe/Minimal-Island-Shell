import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components/settings"

Item {
    id: root
    property string powerProfile: "balanced"

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
                    icon: "settings"
                    title: "System"
                    subtitle: "Hardware status and power management."
                }

                SettingsRow {
                    label: "Active Power Profile"
                    value: root.powerProfile.toUpperCase()
                    showChevron: false
                }

                Button {
                    Layout.fillWidth: true
                    Layout.topMargin: Dimens.spacingLarge
                    text: "Reload Shell State"
                }
            }
        }
    }
}