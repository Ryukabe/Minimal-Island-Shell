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
    property real leftPadding: 0
    property real rightPadding: 0
    property real topPadding: 0
    property real bottomPadding: 0
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
                opacity: vbar.pressed ? 1.0 : (vbar.hovered ? 0.85 : 0.65)
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }
        }

        Item {
            width: scrollView.availableWidth
            implicitHeight: contentColumn.implicitHeight + root.topPadding + root.bottomPadding

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