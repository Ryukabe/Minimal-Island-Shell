import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components/settings"

Item {
    id: root
    property bool frostedBlur: true

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
                    icon: "lock"
                    title: "Lock Screen"
                    subtitle: "Security and background appearance while locked."
                }

                SettingsToggleRow {
                    label: "Frosted Glass Background Blur"
                    checked: root.frostedBlur
                    onToggled: (val) => root.frostedBlur = val
                }
            }
        }
    }
}