// settings/common/SettingsSliderRow.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../styles"

Item {
    id: root
    property string label: ""
    property real from: 0
    property real to: 100
    property real stepSize: 1
    property real value: 0
    property string unit: ""
    property int decimals: 0
    property bool showDivider: true

    signal moved(real value)

    Layout.fillWidth: true
    implicitHeight: 56

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        spacing: 4

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: root.label
                color: Colors.fg
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
                Layout.fillWidth: true
            }

            // Interactive Value Box
            Rectangle {
                implicitWidth: Math.max(50, valInput.implicitWidth + 16)
                implicitHeight: 24
                radius: Dimens.radiusSmall
                color: valInput.activeFocus ? Colors.mainBgMica : Colors.elevatedBg
                border.color: valInput.activeFocus ? Colors.accent : Colors.border
                border.width: 1

                TextInput {
                    id: valInput
                    anchors.centerIn: parent
                    text: root.value.toFixed(root.decimals) + root.unit
                    color: valInput.activeFocus ? Colors.fg : Colors.subtext
                    font.family: Fonts.mono
                    font.pixelSize: Dimens.fontSizeSm
                    selectByMouse: true

                    // Sync slider value when text input is committed
                    onEditingFinished: {
                        var cleaned = text.replace(root.unit, "").trim();
                        var num = parseFloat(cleaned);
                        if (!isNaN(num)) {
                            var clamped = Math.max(root.from, Math.min(root.to, num));
                            root.moved(clamped);
                        }
                        // Re-format display text
                        text = root.value.toFixed(root.decimals) + root.unit;
                    }

                    // Keep text in sync when slider moves
                    Connections {
                        target: root
                        function onValueChanged() {
                            if (!valInput.activeFocus) {
                                valInput.text = root.value.toFixed(root.decimals) + root.unit;
                            }
                        }
                    }
                }
            }
        }

        Slider {
            Layout.fillWidth: true
            from: root.from
            to: root.to
            stepSize: root.stepSize
            value: root.value
            onMoved: root.moved(value)

            background: Rectangle {
                x: parent.leftPadding
                y: parent.topPadding + parent.availableHeight / 2 - height / 2
                implicitWidth: 200
                implicitHeight: 4
                width: parent.availableWidth
                height: implicitHeight
                radius: 2
                color: Colors.elevatedBg

                Rectangle {
                    width: parent.parent.visualPosition * parent.width
                    height: parent.height
                    color: Colors.accent
                    radius: 2
                }
            }

            handle: Rectangle {
                x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                y: parent.topPadding + parent.availableHeight / 2 - height / 2
                implicitWidth: 16
                implicitHeight: 16
                radius: 8
                color: Colors.fg
                border.color: Colors.fg
                border.width: 1
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