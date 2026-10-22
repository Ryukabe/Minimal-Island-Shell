// One-line text field for Dashboard components: underline turns accent on focus, red when invalid.
import QtQuick
import "../../../core/styles"

Item {
    id: root

    property alias text: input.text
    property string placeholder: ""
    property bool invalid: false
    signal accepted()

    function focusInput() { input.forceActiveFocus() }
    function clear() { input.text = "" }

    implicitWidth: 120
    implicitHeight: Dimens.fontSizeMd * 1.8

    TextInput {
        id: input
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        clip: true
        selectByMouse: true
        inputMethodHints: Qt.ImhNoPredictiveText
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeSm
        color: Colors.fg
        selectionColor: Colors.accent
        selectedTextColor: Colors.bg

        onAccepted: root.accepted()
        onTextChanged: root.invalid = false

        Text {
            visible: input.text === ""
            text: root.placeholder
            font: input.font
            color: Colors.fgMuted
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: root.invalid ? Colors.red : (input.activeFocus ? Colors.accent : Colors.border)
    }
}