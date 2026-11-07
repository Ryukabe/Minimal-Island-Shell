// features/bar/components/NotificationPopupCard.qml — the body of a Detailed or Interactive notification popup.
// Detailed: app icon, app name, time, title and the message. Interactive adds the app's own action
// buttons plus Snooze and Dismiss. It sizes itself from its content, so the island grows around it.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../../core/styles"
import "../../../core/shell"
import "../../notifications"

Item {
    id: card

    property var notification: null
    property bool interactive: false

    readonly property int padding: 14
    readonly property bool showText: ShellState.notificationPreviewsEnabled
    readonly property var receivedAt: NotificationService.latestReceivedAt

    // The notification's own picture if it sent one, otherwise the app's icon.
    readonly property string avatarSource: {
        const n = card.notification
        if (!n) return ""
        if (n.image && n.image !== "") return n.image
        return n.appIcon ? Quickshell.iconPath(n.appIcon, true) : ""
    }

    // The width follows the notification center's Width setting.
    implicitWidth: Math.max(ShellState.islandCompactWidth, ShellState.notificationCenterWidth)
    implicitHeight: column.implicitHeight + card.padding * 2

    // Runs one of the app's own action buttons, then clears the notification: you have dealt with it.
    function runAction(action) {
        const n = card.notification
        action.invoke()
        if (n) n.dismiss()
        ShellState.dismissFlash()
    }

    function dismissNow() {
        const n = card.notification
        if (n) n.dismiss()
        ShellState.dismissFlash()
    }

    component PopupButton: Rectangle {
        id: btn

        property string text: ""
        property bool primary: false
        signal clicked()

        implicitWidth: btnLabel.implicitWidth + 24
        implicitHeight: 28
        radius: height / 2
        color: btn.primary ? Colors.accent : (btnMouse.containsMouse ? Colors.elevatedBg : Colors.subBgMica)
        border.width: btn.primary ? 0 : 1
        border.color: Colors.border

        Text {
            id: btnLabel
            anchors.centerIn: parent
            text: btn.text
            color: btn.primary ? Colors.mainBgMica : Colors.fg
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeSm
            font.weight: Font.Medium
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }

    Column {
        id: column
        x: card.padding
        y: card.padding
        width: card.implicitWidth - card.padding * 2
        spacing: 8

        // App icon, app name, time
        Item {
            width: parent.width
            height: 26

            Rectangle {
                id: avatar
                width: 26
                height: 26
                radius: 7
                color: Colors.elevatedBg
                clip: true

                Image {
                    id: avatarImage
                    anchors.fill: parent
                    source: card.avatarSource
                    fillMode: Image.PreserveAspectCrop
                    visible: avatarImage.status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent
                    visible: !avatarImage.visible
                    text: "\uf0f3"
                    font.family: Fonts.mono
                    font.pixelSize: Dimens.fontSizeMd
                    color: Colors.accent
                }
            }

            Text {
                anchors.left: avatar.right
                anchors.leftMargin: 8
                anchors.right: timeText.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: card.notification ? card.notification.appName : ""
                color: Colors.fgMuted
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXSm
                elide: Text.ElideRight
            }

            Text {
                id: timeText
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: card.receivedAt ? Qt.formatTime(card.receivedAt, ShellState.clockTimeFormat) : ""
                color: Colors.fgMuted
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXSm
            }
        }

        // Title
        Text {
            width: parent.width
            text: card.notification
                ? (card.showText ? card.notification.summary : "New notification")
                : ""
            color: Colors.fg
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeBase
            font.bold: true
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }

        // Message: several lines in Detailed, two in Interactive (the buttons need the room)
        Text {
            visible: card.showText && text.length > 0
            width: parent.width
            text: card.notification ? card.notification.body : ""
            color: Colors.fgMuted
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeSm
            wrapMode: Text.WordWrap
            maximumLineCount: card.interactive ? 2 : 6
            elide: Text.ElideRight
        }

        // Interactive only: the app's own buttons first, then Snooze and Dismiss
        Flow {
            visible: card.interactive
            width: parent.width
            spacing: 6

            Repeater {
                model: card.notification ? card.notification.actions : []

                delegate: PopupButton {
                    required property var modelData
                    required property int index

                    visible: modelData.text !== ""
                    text: modelData.text
                    primary: index === 0
                    onClicked: card.runAction(modelData)
                }
            }

            PopupButton {
                text: "Snooze " + ShellState.notificationSnoozeMinutes + " min"
                onClicked: NotificationService.snooze(card.notification, ShellState.notificationSnoozeMinutes)
            }

            PopupButton {
                text: "Dismiss"
                onClicked: card.dismissNow()
            }
        }
    }
}