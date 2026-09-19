// settings/common/SettingsButton.qml — themed replacement for QtQuick.Controls.Button.
// Rounded-rect shape (radius follows Dimens.settingsControlRadius, same as the
// update cards), tinted-accent "primary" style and neutral outline "secondary"
// style, disabled/hover/pressed states. No native OS widget chrome.
import QtQuick
import "../../styles"

Rectangle {
    id: root

    property string text: ""
    property bool primary: false
    property bool busy: false

    signal clicked()

    readonly property color _tint: Colors.accent ? Colors.accent : Colors.fg

    implicitWidth: label.implicitWidth + Dimens.paddingLarge * 2
    implicitHeight: label.implicitHeight + Dimens.paddingSmall * 2
    radius: Dimens.settingsControlRadius

    color: !root.enabled
        ? Colors.elevatedBg
        : root.primary
            ? Qt.rgba(_tint.r, _tint.g, _tint.b, mouseArea.pressed ? 0.30 : (mouseArea.containsMouse ? 0.22 : 0.16))
            : (mouseArea.pressed ? Colors.border : (mouseArea.containsMouse ? Qt.lighter(Colors.mainBgMica, 1.25) : Colors.subBgMica))

    border.width: 0
    border.color: root.primary ? Qt.rgba(_tint.r, _tint.g, _tint.b, 0.4) : Colors.border

    opacity: root.enabled ? 1.0 : 0.45

    Behavior on color { ColorAnimation { duration: 120 } }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.busy ? "Working..." : root.text
        color: root.primary ? Colors.accent : Colors.fg
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeSm
        font.weight: Font.Medium
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled && !root.busy
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}