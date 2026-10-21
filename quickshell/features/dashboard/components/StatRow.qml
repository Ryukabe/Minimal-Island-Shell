import QtQuick
import "../../../core/styles"

Item {
    id: root

    property string icon: ""
    property string label: ""
    property string value: ""
    property string detail: ""
    property var history: []
    property real graphMax: 100
    property color tint: Colors.accent
    property bool showGraph: true

    readonly property real tileSize: Math.min(height, Dimens.fontSizeXxl * 1.8)
    readonly property real freeWidth: width - iconTile.width - textCol.implicitWidth - Dimens.spacingMd * 2

    Rectangle {
        id: iconTile
        width: root.tileSize
        height: root.tileSize
        anchors.verticalCenter: parent.verticalCenter
        radius: Dimens.radiusControl
        color: Qt.rgba(root.tint.r, root.tint.g, root.tint.b, 0.18)

        Text {
            anchors.centerIn: parent
            text: root.icon
            font.family: Fonts.icon
            font.pixelSize: Dimens.fontSizeXl
            font.variableAxes: Fonts.iconAxes
            color: root.tint
        }
    }

    Column {
        id: textCol
        anchors.left: iconTile.right
        anchors.leftMargin: Dimens.spacingMd
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1

        Text {
            text: root.label
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeSm
            font.bold: true
            color: Colors.fg
        }
        Text {
            text: root.value
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeXSm
            color: Colors.fgMuted
        }
    }

    Text {
        id: detailText
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: root.detail
        visible: root.detail !== "" && root.freeWidth >= implicitWidth + Dimens.spacingMd
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeXSm
        color: Colors.fgMuted
    }

    MiniGraph {
        anchors.left: textCol.right
        anchors.leftMargin: Dimens.spacingMd
        anchors.right: detailText.visible ? detailText.left : parent.right
        anchors.rightMargin: detailText.visible ? Dimens.spacingMd : 0
        anchors.verticalCenter: parent.verticalCenter
        height: root.height * 0.6
        values: root.history
        maxValue: root.graphMax
        lineColor: root.tint
        visible: root.showGraph && width >= Dimens.fontSizeMassive
    }
}