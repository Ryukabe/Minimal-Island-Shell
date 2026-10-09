// components/InfoTile.qml — Windows-style summary tile: small label, big value, caption underneath.
import QtQuick
import QtQuick.Layouts
import "../../styles"

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property string value: ""
    property string caption: ""

    Layout.fillWidth: true
    implicitHeight: 112
    radius: Dimens.settingsContainerRadius
    color: Colors.subBgMica

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Dimens.paddingMedium
        spacing: Dimens.spacingSmall

        RowLayout {
            Layout.fillWidth: true
            spacing: Dimens.spacingSmall

            SymbolIcon {
                name: root.icon
                size: Dimens.fontSizeLg
                color: Colors.accent
            }

            Text {
                Layout.fillWidth: true
                text: root.label
                color: Colors.fgMuted
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeSm
                elide: Text.ElideRight
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: root.value
            color: Colors.fg
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeBase
            font.weight: Font.DemiBold
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight
            verticalAlignment: Text.AlignTop
        }

        Text {
            visible: root.caption !== ""
            Layout.fillWidth: true
            text: root.caption
            color: Colors.subtext
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeXs
            elide: Text.ElideRight
        }
    }
}
