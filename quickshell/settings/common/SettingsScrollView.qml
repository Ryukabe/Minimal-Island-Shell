// settings/common/SettingsScrollView.qml — one shared scroll container for
// every Settings page. Content runs edge-to-edge (like Appearance) instead of
// being capped and centered; left padding and the scrollbar's position are
// controlled in one place so every page matches without repeating the same
// ScrollView boilerplate.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../styles"

Item {
    id: root
    anchors.fill: parent

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
        contentWidth: availableWidth

        // AlwaysOff policy alone can still leave the native style's track
        // painted on some QQC2 styles. Give it an explicitly empty visual
        // so it can never render, matching the vertical bar's approach.
        ScrollBar.horizontal: ScrollBar {
            policy: ScrollBar.AlwaysOff
            interactive: false
            visible: false
            contentItem: Item {}
            background: Item {}
        }

        ScrollBar.vertical: ScrollBar {
            id: vbar
            policy: ScrollBar.AsNeeded
            width: 5
            contentItem: Rectangle {
                implicitWidth: 5
                radius: 2.5
                color: Colors.fgMuted
                opacity: vbar.pressed ? 0.8 : (vbar.active ? 0.5 : 0.25)
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }
            background: Item {}
        }

        Item {
            width: scrollView.availableWidth
            implicitHeight: contentColumn.implicitHeight + root.topPadding + root.bottomPadding

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