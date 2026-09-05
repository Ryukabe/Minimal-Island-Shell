// settings/common/SettingsScrollView.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../styles"

Item {
    id: root
    anchors.fill: parent
    focus: true

    default property alias data: contentColumn.data
    property real leftPadding: Dimens.paddingMedium
    property real rightPadding: Dimens.paddingSmall
    property real topPadding: Dimens.paddingLarge
    property real bottomPadding: Dimens.paddingLarge
    property real spacing: 12

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true

        ScrollBar.horizontal: ScrollBar {
            policy: ScrollBar.AlwaysOff
            interactive: false
            visible: false
            contentItem: Item {}
            background: Item {}
        }

        ScrollBar.vertical: ScrollBar {
            id: vbar
            policy: ScrollBar.AlwaysOn
            width: 6
            active: true

            contentItem: Rectangle {
                implicitWidth: 6
                radius: 3
                color: Colors.accent
                opacity: vbar.pressed ? 1.0 : (vbar.hovered ? 0.8 : 0.5)
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }
            background: Item {}
        }

        Item {
            width: scrollView.availableWidth
            implicitHeight: contentColumn.implicitHeight + root.topPadding + root.bottomPadding

            // Dismiss active text field focus when clicking empty background space
            MouseArea {
                anchors.fill: parent
                onClicked: root.forceActiveFocus()
            }

            ColumnLayout {
                id: contentColumn
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: root.topPadding
                anchors.leftMargin: root.leftPadding
                anchors.rightMargin: root.rightPadding
                spacing: root.spacing
            }
        }
    }
}