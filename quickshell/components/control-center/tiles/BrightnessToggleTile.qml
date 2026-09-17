import QtQuick
import "../../../styles"
import "../../../services"

Rectangle {
    id: root
    radius: ShellState.islandCornerRadius
    color: Colors.subBgMica
    border.width: 1
    border.color: Colors.border

    signal subviewRequested()

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        radius: parent.radius
        width: Math.max(height, parent.width * (BrightnessService.percent / 100))
        color: Colors.accent
        Behavior on width { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
    }

    Text {
        text: "brightness_medium"
        font.family: Fonts.icon
        font.pixelSize: Dimens.fontSizeMd
        font.variableAxes: Fonts.iconAxes
        font.features: { "liga": 1, "dlig": 1 }
        color: Colors.subBgMica
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        text: BrightnessService.percent + "%"
        font.pixelSize: Dimens.fontSizeSm
        font.weight: Font.DemiBold
        color: Colors.fg
        anchors.right: chevron.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
    }

    MouseArea {
        anchors.fill: parent
        anchors.rightMargin: 28
        cursorShape: Qt.PointingHandCursor
        function updatePct(x) {
            var pct = Math.max(0, Math.min(100, Math.round((x / root.width) * 100)))
            BrightnessService.setPercent(pct)
        }
        onPressed: (mouse) => updatePct(mouse.x)
        onPositionChanged: (mouse) => { if (pressed) updatePct(mouse.x) }
    }

    Text {
        id: chevron
        text: "chevron_right"
        font.family: Fonts.icon
        font.pixelSize: Dimens.fontSizeMd
        font.variableAxes: Fonts.iconAxes
        color: chevronMouse.containsMouse ? Colors.accent : Colors.subBgMica
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            id: chevronMouse
            anchors.fill: parent
            anchors.margins: -8
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.subviewRequested()
        }
    }
}