import QtQuick
import "../../../styles"
import "../../../services"

Item {
    id: root
    implicitWidth: 340
    implicitHeight: contentColumn.implicitHeight + 32

    signal backRequested()

    Column {
        id: contentColumn
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        spacing: 16

        // ---- Header with Back Button ----
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
                text: "Caffeine Settings"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSize15
                font.bold: true
                color: Colors.fg
                anchors.left: backBtn.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // ---- Status Card ----
        Rectangle {
            width: parent.width
            height: 64
            radius: Dimens.radiusMediumLarge
            color: Colors.subBgMica
            border.width: 1
            border.color: Colors.border

            Row {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Text {
                    text: "coffee"
                    font.family: Fonts.icon
                    font.pixelSize: Dimens.fontSizeXl
                    color: CaffeineService.enabled ? Colors.accent : Colors.fgMuted
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    width: parent.width - 100
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: CaffeineService.enabled ? "Inhibit Active" : "Inhibit Disabled"
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeSm
                        font.bold: true
                        color: Colors.fg
                    }

                    Text {
                        text: CaffeineService.enabled ? "System sleeping & lid lock prevented" : "Normal power saving active"
                        font.family: Fonts.text
                        font.pixelSize: Dimens.fontSizeXs
                        color: Colors.fgMuted
                    }
                }

                // Main Switch Toggle
                Rectangle {
                    width: 44
                    height: 24
                    radius: 12
                    color: CaffeineService.enabled ? Colors.accent : Colors.bgSurface
                    border.width: 1
                    border.color: Colors.border
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Rectangle {
                        width: 18
                        height: 18
                        radius: 9
                        color: Colors.fg
                        anchors.verticalCenter: parent.verticalCenter
                        x: CaffeineService.enabled ? parent.width - width - 3 : 3

                        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: CaffeineService.toggle()
                    }
                }
            }
        }
    }
}