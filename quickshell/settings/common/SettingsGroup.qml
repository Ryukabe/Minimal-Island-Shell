// settings/components/SettingsGroup.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../styles"

Rectangle {
    id: root

    property string title: ""
    property string description: ""
    property string icon: ""
    property bool expanded: true
    default property alias content: contentLayout.children

    Layout.fillWidth: true
    implicitHeight: mainColumn.implicitHeight + (Dimens.paddingLarge * 2)
    radius: Dimens.radiusMedium
    color: Colors.subBgMica
    border.color: Colors.border
    border.width: 1

    Behavior on implicitHeight {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    ColumnLayout {
        id: mainColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Dimens.paddingLarge
        spacing: Dimens.spacingMedium

        // Header Row (Clickable Dropdown Toggle)
        MouseArea {
            Layout.fillWidth: true
            implicitHeight: 36
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded

            Item {
                anchors.fill: parent

                // Icon Badge
                Rectangle {
                    id: iconBadge
                    visible: root.icon !== ""
                    width: 36
                    height: 36
                    radius: 18
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    color: Colors.elevatedBg

                    Text {
                        anchors.centerIn: parent
                        text: root.icon
                        color: Colors.accent
                        font.family: Fonts.icon
                        font.pixelSize: 18
                        font.styleName: Fonts.iconStyle
                    }
                }

                // Title & Subtitle Column (positioned right next to icon badge)
                ColumnLayout {
                    anchors.left: iconBadge.visible ? iconBadge.right : parent.left
                    anchors.leftMargin: iconBadge.visible ? Dimens.spacingSmall : 0
                    anchors.right: expandIcon.left
                    anchors.rightMargin: Dimens.spacingMedium
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: root.title
                        color: Colors.fg
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeBase
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: root.description !== ""
                        text: root.description
                        color: Colors.subtext
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeXs
                        elide: Text.ElideRight
                    }
                }

                // Arrow pinned to far right
                Text {
                    id: expandIcon
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.expanded ? "expand_less" : "expand_more"
                    color: Colors.fgMuted
                    font.family: Fonts.icon
                    font.pixelSize: 22
                    font.styleName: Fonts.iconStyle
                }
            }
        }

        // Dividers & Collapsible Settings Options
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Colors.border
            opacity: 0.4
            visible: root.expanded && contentLayout.children.length > 0
        }

        ColumnLayout {
            id: contentLayout
            Layout.fillWidth: true
            spacing: Dimens.spacingSmall
            visible: root.expanded
            clip: true
        }
    }
}