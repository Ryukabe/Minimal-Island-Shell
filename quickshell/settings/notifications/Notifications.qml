import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../styles"
import "../common"

Item {
    id: root
    property bool peaceMode: false

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
                    icon: "notifications"
                    title: "Notifications"
                    subtitle: "Toast behavior and Do Not Disturb."
                }

                SettingsToggleRow {
                    label: "Peace Mode (Do Not Disturb)"
                    checked: root.peaceMode
                    onToggled: (val) => root.peaceMode = val
                }
            }
        }
    }
}