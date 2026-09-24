import QtQuick
import QtQuick.Layouts
import "../../services"
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
    property bool compact: false   // legacy: kept so existing tile files still compile, ignored now
    property bool hasSubview: false
    property int signalBars: -1

    signal toggled()
    signal subviewRequested()

    // Layout is chosen by the tile's SHAPE, never by its text, so every tile
    // of the same size looks the same. Wider than roomyAspect x its height gets
    // the icon-left layout, everything else gets the compact one.
    readonly property real roomyAspect: 1.6
    readonly property bool roomy: width >= height * roomyAspect
    readonly property Item _content: roomy ? fullRow : compactContent
    readonly property real _hitPad: Dimens.spacingSmall

    implicitWidth: compact ? 76 : 160
    radius: ShellState.islandCornerRadius
    color: Colors.subBgMica
    border.width: 1
    border.color: Colors.border

    Behavior on color { ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) } }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (!tile.external) {
                tile.active = !tile.active
            }
            tile.toggled()
        }
    }

    // ---- Compact layout: icon + short name, bottom-left ----
    Column {
        id: compactContent
        visible: !tile.roomy
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: Dimens.paddingMedium
        width: tile.width - Dimens.paddingMedium * 2
        spacing: Dimens.spacingSmall

        Item {
            id: iconBox
            width: Math.max(iconText.implicitWidth, barsRow.implicitWidth)
            height: iconText.implicitHeight

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
                        width: Math.max(2, Math.round(iconBox.height / 7))
                        height: iconBox.height * (0.3 + index * 0.2)
                        radius: ShellState.islandCornerRadius
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
            width: compactContent.width
        }
    }

    // ---- Full layout: icon left, title + subtitle right ----
    RowLayout {
        id: fullRow
        visible: tile.roomy
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        spacing: Dimens.spacingSmall

        Text {
            text: tile.iconGlyph
            font.family: Fonts.icon
            font.pixelSize: Dimens.fontSizeLg
            font.variableAxes: Fonts.iconAxes
            font.features: { "liga": 1, "dlig": 1 }
            color: tile.active ? Colors.accent : Colors.fg
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            Text {
                text: tile.title
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeSm
                font.bold: true
                color: Colors.fg
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: tile.subtitle
                visible: text !== ""
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXSm
                color: tile.active ? Colors.accent : Colors.fgMuted
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }

    // Separate tap target for opening the subview
    MouseArea {
        visible: tile.hasSubview
        enabled: tile.hasSubview
        x: tile._content.x - tile._hitPad
        y: tile._content.y - tile._hitPad
        width: tile._content.width + tile._hitPad * 2
        height: tile._content.height + tile._hitPad * 2
        onClicked: tile.subviewRequested()
    }

    Rectangle {
        width: 8
        height: 8
        radius: ShellState.islandCornerRadius
        color: tile.active ? Colors.accent : Colors.fgMuted
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 8
        Behavior on color { ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) } }
    }
}