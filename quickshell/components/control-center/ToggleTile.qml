import QtQuick
import "../../styles"

Rectangle {
    id: tile

    property string title: ""
    property string subtitle: ""
    property string displayName: title
    property string iconGlyph: "settings"
    property color iconColor: Colors.fg
    property bool active: false
    property bool external: false
    property bool compact: false
    property bool hasSubview: false
    property int signalBars: -1 // -1 = show iconGlyph, 0-4 = show bar indicator instead

    signal toggled()
    signal subviewRequested()

    implicitWidth: compact ? 76 : 160
    implicitHeight: compact ? 78 : 64
    radius: compact ? Dimens.radiusMedium : Dimens.radiusMediumLarge
    color: Colors.surface
    border.width: 1
    border.color: Colors.border

    Behavior on color { ColorAnimation { duration: 150 } }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (!tile.external) {
                tile.active = !tile.active
            }
            tile.toggled()
        }
    }

    // ---- Compact layout: icon (or signal bars) + label stacked, bottom-left ----
    Column {
        id: compactContent
        visible: tile.compact
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 10
        spacing: 6

        Item {
            width: Math.max(iconText.implicitWidth, barsRow.implicitWidth)
            height: 22

            Text {
                id: iconText
                visible: tile.signalBars < 0
                text: tile.iconGlyph
                font.family: Fonts.icon
                font.pixelSize: Dimens.fontSizeXl
                font.variableAxes: Fonts.iconAxes
                font.features: { "liga": 1, "dlig": 1 }
                color: tile.active ? Colors.accent : Colors.fg
                anchors.left: parent.left
                anchors.bottom: parent.bottom
            }

            Row {
                id: barsRow
                visible: tile.signalBars >= 0
                spacing: 2
                anchors.left: parent.left
                anchors.bottom: parent.bottom

                Repeater {
                    model: 4
                    delegate: Rectangle {
                        required property int index
                        width: 3
                        height: 6 + index * 4
                        radius: 1
                        anchors.bottom: parent.bottom
                        color: index < tile.signalBars
                            ? (tile.active ? Colors.accent : Colors.fg)
                            : Colors.border
                    }
                }
            }
        }

        Text {
            text: tile.displayName
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeXSm
            color: Colors.fgMuted
            elide: Text.ElideRight
            width: tile.width - 20
        }
    }

    MouseArea {
        visible: tile.compact
        enabled: tile.hasSubview
        x: compactContent.x - 6
        y: compactContent.y - 6
        width: compactContent.width + 12
        height: compactContent.height + 12
        onClicked: tile.subviewRequested()
    }

    // ---- Full layout: icon + title/subtitle, left-aligned ----
    Row {
        id: fullContent
        visible: !tile.compact
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 14
        spacing: 10

        Text {
            text: tile.iconGlyph
            font.family: Fonts.icon
            font.pixelSize: Dimens.fontSizeLg
            font.variableAxes: Fonts.iconAxes
            font.features: { "liga": 1, "dlig": 1 }
            color: tile.active ? Colors.accent : Colors.fg
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            spacing: 1
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: tile.title
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeSm
                font.bold: true
                color: Colors.fg
            }

            Text {
                text: tile.subtitle
                font.pixelSize: Dimens.fontSizeXSm
                color: tile.active ? Colors.accent : Colors.fgMuted
                elide: Text.ElideRight
                width: Math.min(implicitWidth, tile.width - 60)
            }
        }
    }

    MouseArea {
        visible: !tile.compact
        enabled: tile.hasSubview
        x: fullContent.x - 6
        y: fullContent.y - 6
        width: fullContent.width + 12
        height: fullContent.height + 12
        onClicked: tile.subviewRequested()
    }

    Rectangle {
        width: 8
        height: 8
        radius: 4
        color: tile.active ? Colors.accent : Colors.fgMuted
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 8
        Behavior on color { ColorAnimation { duration: 150 } }
    }
}