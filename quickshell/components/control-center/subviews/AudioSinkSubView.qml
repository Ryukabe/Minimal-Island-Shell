pragma ComponentBehavior: Bound

import QtQuick
import "../../../styles"
import "../../../services"

Item {
    id: root
    implicitWidth: 580
    implicitHeight: contentColumn.implicitHeight + 32

    signal backRequested()

    Column {
        id: contentColumn
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        spacing: 12

        Item {
            width: parent.width
            height: 32

            Text {
                id: backBtn
                text: "arrow_back"
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeLg
                color: Colors.fg
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.backRequested()
                }
            }

            Text {
                text: "Audio Output"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSize15
                font.bold: true
                color: Colors.fg
                anchors.left: backBtn.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            width: parent.width
            height: 120
            radius: Dimens.radiusLarge
            color: Colors.subBgMica
            border.width: 1
            border.color: Colors.border

            Text {
                anchors.centerIn: parent
                text: "Output device switching isn't wired up yet"
                font.pixelSize: Dimens.fontSizeSm
                color: Colors.fgMuted
            }
        }
    }
}