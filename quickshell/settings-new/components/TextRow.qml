// components/TextRow.qml — label (+ optional description) with a text field.
// Press Enter or click away to apply; Escape puts the current value back.
// clearOnCommit: for "add" fields. The text is cleared after it is applied and empty text is ignored.
import QtQuick
import QtQuick.Layouts
import "../../styles"
import "../../services"

Item {
    id: root

    property string label: ""
    property string description: ""
    property string value: ""
    property string placeholderText: ""
    property bool monospace: false
    property int fieldWidth: 200
    property int maximumLength: 256
    property bool clearOnCommit: false
    property bool placeholder: false
    property bool showDivider: true
    signal committed(string value)
    signal edited(string text)

    function _commit() {
        const t = field.text.trim()
        if (root.clearOnCommit) {
            if (t.length > 0) root.committed(t)
            field.text = ""
        } else if (t !== root.value) {
            root.committed(t)
        }
    }

    Layout.fillWidth: true
    implicitHeight: root.description !== "" ? 62 : 54
    enabled: !root.placeholder
    opacity: root.enabled ? 1.0 : 0.4

    Behavior on opacity {
        NumberAnimation { duration: ShellState.motionDuration(Motion.fadeMs) }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Dimens.paddingMedium
        anchors.rightMargin: Dimens.paddingMedium
        spacing: Dimens.spacingMedium

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.label
                color: Colors.fg
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeBase
                elide: Text.ElideRight
            }

            Text {
                visible: root.description !== ""
                Layout.fillWidth: true
                text: root.description
                color: Colors.subtext
                font.family: Fonts.text
                font.pixelSize: Dimens.fontSizeXs
                elide: Text.ElideRight
            }
        }

        ComingSoonTag {
            visible: root.placeholder
        }

        Rectangle {
            Layout.preferredWidth: root.fieldWidth
            Layout.preferredHeight: 34
            radius: Dimens.settingsControlRadius
            color: Colors.elevatedBg
            border.width: 1
            border.color: field.activeFocus ? Colors.accent : "transparent"

            Behavior on border.color {
                ColorAnimation { duration: ShellState.motionDuration(Motion.hoverMs) }
            }

            TextInput {
                id: field
                anchors.fill: parent
                anchors.leftMargin: Dimens.paddingMedium
                anchors.rightMargin: Dimens.paddingMedium
                verticalAlignment: TextInput.AlignVCenter
                color: Colors.fg
                font.family: root.monospace ? Fonts.mono : Fonts.text
                font.pixelSize: Dimens.fontSizeBase
                maximumLength: root.maximumLength
                selectByMouse: true
                clip: true
                onEditingFinished: root._commit()
                onTextEdited: root.edited(field.text)
                Keys.onEscapePressed: {
                    field.text = root.clearOnCommit ? "" : root.value
                    field.focus = false
                }

                Text {
                    visible: field.text.length === 0
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.placeholderText
                    color: Colors.subtext
                    font: field.font
                }
            }

            // Show the real value whenever the box is not being edited.
            Binding {
                target: field
                property: "text"
                value: root.value
                when: !field.activeFocus
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