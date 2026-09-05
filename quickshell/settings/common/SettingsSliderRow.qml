// settings/common/SettingsSliderRow.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../styles"
import "../../components/common"

ColumnLayout {
    id: root
    property string label: ""
    property real from: 0
    property real to: 100
    property real value: 0
    property real stepSize: 1
    property string unit: ""
    property int decimals: 0
    signal moved(real value)

    Layout.fillWidth: true
    Layout.bottomMargin: Dimens.spacingMedium
    spacing: Dimens.spacingSmall

    RowLayout {
        Layout.fillWidth: true

        Text {
            text: root.label
            color: Colors.fg
            font.family: Fonts.text
            font.pixelSize: Dimens.fontSizeBase
            Layout.fillWidth: true
        }

        Rectangle {
            id: inputContainer
            implicitWidth: Math.max(56, inputRow.implicitWidth + 16)
            implicitHeight: 28
            color: inputField.activeFocus 
                   ? Qt.rgba(1, 1, 1, 0.08) 
                   : (inputMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(1, 1, 1, 0.03))
            radius: Dimens.radiusSmall
            border.color: inputField.activeFocus ? Colors.accent : Qt.rgba(1, 1, 1, 0.12)
            border.width: 1

            MouseArea {
                id: inputMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: inputField.forceActiveFocus()
            }

            RowLayout {
                id: inputRow
                anchors.centerIn: parent
                spacing: 2

                TextInput {
                    id: inputField
                    color: activeFocus ? Colors.fg : Colors.subtext
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeBase
                    horizontalAlignment: Text.AlignHCenter
                    selectByMouse: true
                    text: root.decimals > 0 ? root.value.toFixed(root.decimals) : Math.round(root.value).toString()

                    onAccepted: root.forceActiveFocus()
                    Keys.onEscapePressed: root.forceActiveFocus()

                    onEditingFinished: {
                        let raw = text.trim()
                        let parsed = parseFloat(raw)

                        if (!isNaN(parsed)) {
                            if (root.to <= 1.0 && parsed > 1.0) {
                                let digitsOnly = raw.replace(/[^0-9]/g, "")
                                let converted = parseFloat("0." + digitsOnly)
                                if (!isNaN(converted)) {
                                    parsed = converted
                                }
                            }

                            let clamped = Math.max(root.from, Math.min(root.to, parsed))
                            root.moved(clamped)
                        }

                        text = Qt.binding(() => root.decimals > 0 ? root.value.toFixed(root.decimals) : Math.round(root.value).toString())
                    }
                }

                Text {
                    visible: root.unit !== ""
                    text: root.unit.trim()
                    color: Colors.subtext
                    font.family: Fonts.text
                    font.pixelSize: Dimens.fontSizeBase
                }
            }
        }
    }

    SliderControl {
        Layout.fillWidth: true
        from: root.from
        to: root.to
        stepSize: root.stepSize
        value: root.value
        onMoved: (val) => root.moved(val)
    }
}