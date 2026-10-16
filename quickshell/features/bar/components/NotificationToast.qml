// features/bar/components/NotificationToast.qml
import QtQuick
import "../../../core/styles"
import "../../notifications"
import "../../../core/shell"

Item {
    id: toast

    readonly property var notif: NotificationService.latestNotification

    readonly property int iconSpacing: 10
    readonly property int maxTextWidth: ShellState.notificationToastMaxWidth

    implicitWidth: ShellState.islandCompactWidth + 5
    implicitHeight: ShellState.islandCompactHeight

    // Ring on first show, and again when a newer notification replaces this one.
    Component.onCompleted: toast.ring()
    onNotifChanged: toast.ring()

    function ring() {
        bellRing.stop()
        iconText.rotation = 0
        if (!ShellState.motionReduced) bellRing.start()
    }

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

    // Click to dismiss. This is how a toast that is set to stay until clicked goes away.
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: ShellState.dismissFlash()
    }
}