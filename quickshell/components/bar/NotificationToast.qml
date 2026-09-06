// components/bar/NotificationToast.qml
import QtQuick
import "../../styles"
import "../../services"

Item {
    id: toast

    readonly property var notif: NotificationService.latestNotification

    readonly property int iconSpacing: 10
    readonly property int maxTextWidth: 260

    implicitWidth: ShellState.islandCompactWidth
    implicitHeight: ShellState.islandCompactHeight

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: toast.iconSpacing

        Text {
            id: iconText
            text: "\uf0f3"
            font.family: Fonts.mono
            font.pixelSize: Dimens.fontSizeMd
            color: Colors.accent
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: summaryText
            text: toast.notif ? toast.notif.summary : ""
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeBase
            font.bold: true
            color: Colors.fg
            elide: Text.ElideRight
            // width caps at maxTextWidth only if the real text is longer than that —
            // short text keeps its true implicitWidth, so it never overflows the pill
            width: Math.min(implicitWidth, toast.maxTextWidth)
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}