// features/bar/components/NotificationToast.qml — the notification popup on the island.
// Compact: the pill with a bell and the title. Detailed and Interactive: a card with more in it.
// The style is chosen in Settings > Focus & Notifications.
import QtQuick
import "../../../core/styles"
import "../../notifications"
import "../../../core/shell"

Item {
    id: toast

    readonly property var notif: NotificationService.latestNotification
    readonly property string style: ShellState.notificationPopupStyle
    readonly property bool compact: toast.style === "Compact"

    readonly property int iconSpacing: 10
    readonly property int maxTextWidth: ShellState.notificationToastMaxWidth

    // Compact keeps its fixed size. The card sizes itself from its content.
    implicitWidth: toast.compact ? ShellState.islandCompactWidth + 5 : card.implicitWidth
    implicitHeight: toast.compact ? ShellState.islandCompactHeight : card.implicitHeight

    // Ring on first show, and again when a newer notification replaces this one.
    Component.onCompleted: toast.ring()
    onNotifChanged: toast.ring()

    function ring() {
        bellRing.stop()
        iconText.rotation = 0
        if (!ShellState.motionReduced) bellRing.start()
    }

    // Click to dismiss the popup (the notification stays in the center). Behind everything else,
    // so the buttons on an Interactive card get their own clicks.
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: ShellState.dismissFlash()
    }

    // Detailed and Interactive popups stay up while the pointer is over them.
    HoverHandler {
        enabled: !toast.compact
        onHoveredChanged: ShellState.holdFlash(hovered)
    }

    Row {
        id: contentRow
        visible: toast.compact
        anchors.centerIn: parent
        spacing: toast.iconSpacing

        Text {
            id: iconText
            text: "\uf0f3"
            font.family: Fonts.mono
            font.pixelSize: Dimens.fontSizeMd
            color: Colors.accent
            anchors.verticalCenter: parent.verticalCenter
            // The bell hangs from its top edge.
            transformOrigin: Item.Top
        }

        Text {
            id: summaryText
            text: toast.notif
                ? (ShellState.notificationPreviewsEnabled ? toast.notif.summary : "New notification")
                : ""
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

    NotificationPopupCard {
        id: card
        visible: !toast.compact
        notification: toast.notif
        interactive: toast.style === "Interactive"
    }

    // Decaying swing: each step is smaller and opposite to the last, then it rests at 0.
    SequentialAnimation {
        id: bellRing

        PauseAnimation { duration: ShellState.motionDuration(Motion.contentDelayMs) }

        NumberAnimation { target: iconText; property: "rotation"; to: 22;  duration: ShellState.motionDuration(Motion.snapMs); easing.type: Easing.OutCubic }
        NumberAnimation { target: iconText; property: "rotation"; to: -18; duration: ShellState.motionDuration(Motion.snapMs); easing.type: Easing.InOutSine }
        NumberAnimation { target: iconText; property: "rotation"; to: 13;  duration: ShellState.motionDuration(Motion.snapMs); easing.type: Easing.InOutSine }
        NumberAnimation { target: iconText; property: "rotation"; to: -8;  duration: ShellState.motionDuration(Motion.snapMs); easing.type: Easing.InOutSine }
        NumberAnimation { target: iconText; property: "rotation"; to: 4;   duration: ShellState.motionDuration(Motion.snapMs); easing.type: Easing.InOutSine }
        NumberAnimation { target: iconText; property: "rotation"; to: 0;   duration: ShellState.motionDuration(Motion.snapMs); easing.type: Easing.InOutSine }
    }
}