// components/ColorRow.qml — label, colour swatch and an editable hex code.
// Type a hex like #77B0A8 (6 digits, or 8 with alpha) and press Enter or click away to apply.
// Anything that isn't a valid hex snaps back to the current value.
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"

Item {
    id: root

    property string label: ""
    property var value: "#000000"       // a hex string (a QML colour also works)
    property bool showDivider: true
    signal committed(string hex)

    readonly property string _hex: String(root.value).toUpperCase()

    function _commit() {
        let t = hexInput.text.trim()
        if (t.length > 0 && t[0] !== "#") t = "#" + t
        if (/^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$/.test(t)) {
            if (t.toUpperCase() !== root._hex) root.committed(t)
        } else {
            hexInput.text = root._hex
        }
    }

    Layout.fillWidth: true
    implicitHeight: 54

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        spacing: Dimens.spacingMedium

        Text {
            Layout.fillWidth: true
            text: root.label
            color: Colors.fg
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeBase
            elide: Text.ElideRight
        }

        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: 7
            color: root.value
            border.color: Colors.border
            border.width: 1
        }

        Rectangle {
            Layout.preferredWidth: 104
            Layout.preferredHeight: 34
            radius: Dimens.settingsControlRadius
            color: Colors.elevatedBg
            border.width: 1
            border.color: hexInput.activeFocus ? Colors.accent : "transparent"

            Behavior on border.color {
                ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
            }

            TextInput {
                id: hexInput
                anchors.fill: parent
                anchors.leftMargin: Dimens.paddingMedium
                anchors.rightMargin: Dimens.paddingMedium
                verticalAlignment: TextInput.AlignVCenter
                color: Colors.fg
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
                maximumLength: 9
                selectByMouse: true
                clip: true
                onEditingFinished: root._commit()
                Keys.onEscapePressed: {
                    hexInput.text = root._hex
                    hexInput.focus = false
                }
            }

            // Show the real value whenever the box is not being edited.
            Binding {
                target: hexInput
                property: "text"
                value: root._hex
                when: !hexInput.activeFocus
            }
        }
    }

    Rectangle {
        visible: root.showDivider
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        height: 1
        color: Colors.border
        opacity: 0.35
    }
}
