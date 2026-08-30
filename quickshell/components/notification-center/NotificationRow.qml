import QtQuick
import "../../styles"

Rectangle {
    id: row
    required property var notification

    width: parent ? parent.width : 340
    implicitHeight: contentColumn.implicitHeight + 20
    radius: Dimens.radiusLarge
    color: Colors.surface
    border.width: 1
    border.color: Colors.border

    Column {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 4

        Item {
            width: parent.width
            height: 16

            Text {
                text: row.notification ? row.notification.appName : ""
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXSm
                color: Colors.fgMuted
                elide: Text.ElideRight
                anchors.left: parent.left
                anchors.right: dismissIcon.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: dismissIcon
                text: "\uf00d"
                font.family: Fonts.mono
                font.pixelSize: Dimens.fontSizeXSm
                color: Colors.fgMuted
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    onClicked: if (row.notification) row.notification.dismiss()
                }
            }
        }

        Text {
            text: row.notification ? row.notification.summary : ""
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeBase
            font.bold: true
            color: Colors.fg
            width: parent.width
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            maximumLineCount: 2
        }

        Text {
            text: row.notification ? row.notification.body : ""
            font.pixelSize: Dimens.fontSizeSm
            color: Colors.fgMuted
            width: parent.width
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            maximumLineCount: 3
            visible: text.length > 0
        }
    }
}