// settings/common/SettingsColorRow.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../styles"

Item {
    id: root

    property string label: ""
    property color value: "#000000"
    property bool showDivider: true

    signal committed(string hex)

    implicitHeight: 56

    function toHex(c) {
        function h(v) { var s = Math.round(v * 255).toString(16); return s.length < 2 ? "0" + s : s; }
        return "#" + h(c.r) + h(c.g) + h(c.b);
    }

    function isValidHex(s) {
        return /^#([0-9a-fA-F]{6})$/.test(s);
    }

    Rectangle {
        anchors.fill: parent
        radius: Dimens.radiusMedium
        color: "transparent"
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        spacing: Dimens.spacingMedium

        Text {
            text: root.label
            color: Colors.fg
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeMd
            Layout.fillWidth: true
        }

        Rectangle {
            id: swatch
            width: 28
            height: 28
            radius: Dimens.radiusSmall
            color: root.value
            border.width: 1
            border.color: Colors.border
        }

        Rectangle {
            width: 100
            height: 32
            radius: Dimens.radiusSmall
            color: Colors.elevatedBg
            border.width: hexField.activeFocus ? 1 : 0
            border.color: Colors.accent

            TextField {
                id: hexField
                anchors.fill: parent
                anchors.margins: 1
                text: root.toHex(root.value)
                color: Colors.fg
                font.family: Fonts.mono
                font.pixelSize: Dimens.fontSizeSm
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                background: null
                selectByMouse: true
                maximumLength: 7

                onEditingFinished: {
                    var v = text.trim();
                    if (!v.startsWith("#")) v = "#" + v;
                    if (root.isValidHex(v)) {
                        root.committed(v);
                    } else {
                        // revert to last valid value on bad input
                        text = root.toHex(root.value);
                    }
                }

                // Keep field in sync if value changes externally
                // (e.g. theme switch flips which mode is active).
                Connections {
                    target: root
                    function onValueChanged() {
                        if (!hexField.activeFocus) hexField.text = root.toHex(root.value);
                    }
                }
            }
        }
    }

    Rectangle {
        visible: root.showDivider
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        height: 1
        color: Colors.border
        opacity: 0.5
    }
}