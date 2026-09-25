// settings/common/SettingsPathRow.qml — a labeled path field with an
// "Open folder" button next to it.
import QtQuick
import QtQuick.Layouts
import "../../styles"

ColumnLayout {
    id: root
    spacing: 4

    property string label: ""
    property string value: ""
    property bool showDivider: true

    signal committed(string value)
    signal openRequested()

    Layout.fillWidth: true

    Text {
        Layout.leftMargin: Dimens.paddingMedium
        Layout.rightMargin: Dimens.paddingMedium
        text: root.label
        color: Colors.fg
        font.family: Fonts.text
        font.pixelSize: Dimens.fontSizeBase
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Dimens.paddingMedium
        Layout.rightMargin: Dimens.paddingMedium
        Layout.bottomMargin: Dimens.spacingSmall
        spacing: Dimens.spacingSmall

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 32
            radius: Dimens.settingsControlRadius
            color: pathInput.activeFocus ? Colors.mainBgMica : Colors.elevatedBg
            border.color: pathInput.activeFocus ? Colors.accent : Colors.border
            border.width: 1

            TextInput {
                id: pathInput
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                verticalAlignment: TextInput.AlignVCenter
                text: root.value
                color: Colors.fg
                font.family: Fonts.mono
                font.pixelSize: Dimens.fontSizeSm
                clip: true
                selectByMouse: true

                // The parent decides whether the new path is accepted. Either
                // way, re-sync the box to the real value afterwards.
                onEditingFinished: {
                    root.committed(text)
                    text = root.value
                }
            }
        }

        SettingsButton {
            text: "Open folder"
            onClicked: root.openRequested()
        }
    }

    Rectangle {
        visible: root.showDivider
        Layout.fillWidth: true
        Layout.leftMargin: Dimens.paddingMedium
        Layout.rightMargin: Dimens.paddingMedium
        height: 1
        color: Colors.border
        opacity: 0.35
    }
}