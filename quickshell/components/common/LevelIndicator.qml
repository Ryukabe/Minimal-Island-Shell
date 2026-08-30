import QtQuick
import "../../styles"

Rectangle {
    id: root
    property string icon: "\uf028"
    property string iconSource: ""
    property int percent: 50
    property color barColor: Colors.accent
    property bool interactive: false   // NEW: set true to allow drag-to-set

    signal percentDragged(int pct)     // NEW: emitted while dragging the track
    signal iconClicked()               // NEW: emitted on icon tap (e.g. mute toggle)

    implicitWidth: 160
    implicitHeight: 36
    color: "transparent"
    radius: height / 2

    Text {
        id: iconText
        visible: root.iconSource === ""
        text: root.icon
        font.family: Fonts.mono
        font.pixelSize: Dimens.fontSizeMd
        color: Colors.fg
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            onClicked: root.iconClicked()
        }
    }

    Image {
        id: iconImage
        visible: root.iconSource !== ""
        source: root.iconSource
        width: 16
        height: 16
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        sourceSize: Qt.size(64, 64)
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            onClicked: root.iconClicked()
        }
    }

    Text {
        id: percentText
        text: root.percent + "%"
        font.family: Fonts.mono
        font.pixelSize: Dimens.fontSizeSm
        font.weight: Font.DemiBold
        color: Colors.fg
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
        id: track
        height: 4
        radius: Dimens.radiusXSmall
        color: Colors.bgSurface
        anchors.left: root.iconSource === "" ? iconText.right : iconImage.right
        anchors.leftMargin: 10
        anchors.right: percentText.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            width: track.width * (root.percent / 100)
            height: parent.height
            radius: parent.radius
            color: root.barColor
        }

        MouseArea {
            anchors.fill: parent
            anchors.margins: -8
            enabled: root.interactive
            function updatePct(x) {
                var pct = Math.max(0, Math.min(100, Math.round((x / width) * 100)))
                root.percentDragged(pct)
            }
            onPressed: (mouse) => updatePct(mouse.x)
            onPositionChanged: (mouse) => { if (pressed) updatePct(mouse.x) }
        }
    }
}