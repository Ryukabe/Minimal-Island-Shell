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
    implicitHeight: mainColumn.implicitHeight + (Dimens.paddingMedium * 2)
    radius: Dimens.radiusMedium
    color: Colors.elevatedBg
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
        anchors.margins: Dimens.paddingMedium
        spacing: Dimens.spacingMedium

        // Header Row (Clickable Dropdown Toggle)
        MouseArea {
            Layout.fillWidth: true
            implicitHeight: headerRow.implicitHeight
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded

            RowLayout {
                id: headerRow
                anchors.fill: parent
                spacing: Dimens.spacingMedium

                // Material Symbol Icon
                Text {
                    visible: root.icon !== ""
                    text: root.icon
                    color: Colors.accent
                    font.family: Fonts.icon
                    font.pixelSize: 22
                    font.styleName: Fonts.iconStyle
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: root.title
                        color: Colors.fg
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeBase
                        font.weight: Font.DemiBold
                    }

                    Text {
                        visible: root.description !== ""
                        text: root.description
                        color: Colors.subtext
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeXs
                    }
                }

                // Dropdown Expand/Collapse Icon
                Text {
                    text: root.expanded ? "expand_less" : "expand_more"
                    color: Colors.fgMuted
                    font.family: Fonts.icon
                    font.pixelSize: 22
                    font.styleName: Fonts.iconStyle

                    Behavior on rotation {
                        NumberAnimation { duration: 150 }
                    }
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