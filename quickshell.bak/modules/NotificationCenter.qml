// modules/NotificationCenter.qml
pragma ComponentBehavior: Bound

import QtQuick
import "../services"
import "../styles"
import "../components/notification-center"

Item {
    id: root
    implicitWidth: ShellState.notificationCenterWidth
    implicitHeight: Math.min(contentColumn.implicitHeight + 32, ShellState.notificationCenterMaxHeight)

    focus: true
    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: root.forceActiveFocus()
    }

    Component.onCompleted: focusTimer.restart()

    function clearAll() {
        const items = [...NotificationService.trackedNotifications.values]
        for (let i = 0; i < items.length; i++) {
            items[i].dismiss()
        }
    }

    Column {
        id: contentColumn
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        spacing: 12

        Item {
            id: headerRow
            width: parent.width
            height: 28

            Text {
                text: "Notification Center"
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSize15
                font.bold: true
                color: Colors.fg
                anchors.centerIn: parent
            }

            Text {
                text: "Clear all"
                font.pixelSize: Dimens.fontSizeSm
                color: Colors.accent
                visible: NotificationService.trackedNotifications.values.length > 0
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    onClicked: root.clearAll()
                }
            }
        }

        Flickable {
            id: listFlick
            width: parent.width
            height: Math.min(listColumn.implicitHeight, 380)
            contentWidth: width
            contentHeight: listColumn.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: listColumn
                width: parent.width
                spacing: 8

                Repeater {
                    model: NotificationService.trackedNotifications

                    delegate: NotificationRow {
                        required property var modelData

                        width: listColumn.width
                        notification: modelData
                    }
                }

                Text {
                    text: "No notifications"
                    font.pixelSize: Dimens.fontSizeSm
                    color: Colors.fgMuted
                    visible: NotificationService.trackedNotifications.values.length === 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    topPadding: 20
                    bottomPadding: 20
                }
            }
        }
    }
}