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
            width: 8
            active: true

            // Track — the part that was missing entirely before, which is
            // why the bar was invisible at rest. A faint always-visible
            // pill so the scrollable area reads clearly even when idle.
            background: Rectangle {
                implicitWidth: 8
                radius: 4
                color: Colors.fg
                opacity: 0.06
            }

            contentItem: Rectangle {
                implicitWidth: 8
                radius: 4
                color: Colors.accent
                // Idle opacity raised from 0.5 to 0.65 so the thumb is
                // clearly visible without hovering, not just when dragged.
                opacity: vbar.pressed ? 1.0 : (vbar.hovered ? 0.85 : 0.65)
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }
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