// features/theme/components/MotionPresetCard.qml — one card in Settings > Motion > Presets.
import QtQuick
import "../../../core/shell"
import "../../../core/styles"

Rectangle {
    id: root

    property string presetName: ""
    property string description: ""
    property string detail: ""
    property string detailExtra: ""
    property bool isActive: false
    property real cardWidth: 184

    signal clicked()

    // Every line below has a reserved height, so all cards are the same height
    // whatever their text.
    implicitWidth: cardWidth
    implicitHeight: content.implicitHeight + Dimens.paddingMedium * 2
    radius: Dimens.radiusMedium
    color: (mouse.containsMouse && root.enabled) ? Colors.elevatedBg : Colors.subBgMica
    border.width: root.isActive ? 2 : 1
    border.color: root.isActive ? Colors.accent : Colors.border
    opacity: root.enabled ? 1.0 : 0.5

    Behavior on color {
        ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
    }
    Behavior on border.color {
        ColorAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: ShellState.motionDuration(Motion.fadeMs)
            easing.type: Easing.OutCubic
        }
    }

    FontMetrics {
        id: nameMetrics
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeMd
        font.weight: Font.DemiBold
    }
    FontMetrics {
        id: descMetrics
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeSm
    }
    FontMetrics {
        id: detailMetrics
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeXs
    }

    Column {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Dimens.paddingMedium
        spacing: Dimens.spacingSmall

        Text {
            width: parent.width
            height: nameMetrics.height
            text: root.presetName
            color: root.isActive ? Colors.accent : Colors.fg
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeMd
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            height: descMetrics.height * 2
            text: root.description
            color: Colors.fgMuted
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeSm
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            height: detailMetrics.height
            text: root.detail
            color: Colors.fgMuted
            opacity: 0.8
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeXs
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            height: detailMetrics.height
            text: root.detailExtra
            color: Colors.fgMuted
            opacity: 0.8
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeXs
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}