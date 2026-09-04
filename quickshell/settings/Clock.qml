import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components/settings"

Item {
    id: root
    property bool use24Hour: true

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
                    icon: "schedule"
                    title: "Clock & Date"
                    subtitle: "Time format, date display, and calendar options."
                }

                SettingsToggleRow {
                    label: "Use 24-Hour Clock Format"
                    checked: root.use24Hour
                    onToggled: (val) => root.use24Hour = val
                }
            }
        }
    }
}