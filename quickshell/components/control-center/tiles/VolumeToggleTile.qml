import QtQuick
import "../../../styles"
import "../../../services"

Rectangle {
    id: root
    radius: height / 2
    color: Colors.subBgMica
    border.width: 1
    border.color: Colors.border

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        radius: parent.radius
        width: Math.max(height, parent.width * (VolumeService.muted ? 0 : VolumeService.percent / 100))
        color: Colors.accent
        Behavior on width { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
    }

    Text {
        text: VolumeService.muted ? "volume_off" : "volume_up"
        font.family: Fonts.icon
        font.pixelSize: Dimens.fontSizeMd
        font.variableAxes: Fonts.iconAxes
        font.features: { "liga": 1, "dlig": 1 }
        color: Colors.subBgMica
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            anchors.fill: parent
            anchors.margins: -8
            cursorShape: Qt.PointingHandCursor
            onClicked: VolumeService.toggleMute()
        }
    }

    Text {
        text: VolumeService.muted ? "Muted" : VolumeService.percent + "%"
        font.pixelSize: Dimens.fontSizeSm
        font.weight: Font.DemiBold
        color: Colors.fg
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        function updatePct(x) {
            var pct = Math.max(0, Math.min(100, Math.round((x / width) * 100)))
            VolumeService.setPercent(pct)
        }
        onPressed: (mouse) => updatePct(mouse.x)
        onPositionChanged: (mouse) => { if (pressed) updatePct(mouse.x) }
    }
}